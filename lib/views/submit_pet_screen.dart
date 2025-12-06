import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pawpal_v2/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal_v2/myconfig.dart';

class SubmitPetScreen extends StatefulWidget {
  final User? user;
  const SubmitPetScreen({super.key, required this.user});

  @override
  State<SubmitPetScreen> createState() => _SubmitPetScreenState();
}

class _SubmitPetScreenState extends State<SubmitPetScreen> {
  //text controller
  TextEditingController petname = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController location = TextEditingController();
  bool isLoading = false;
  //list for drop down
  List<String> petType = ['Dog', 'Cat', 'Rabbit', 'Other'];
  List<String> category = [
    'Adoption',
    'Donation Request',
    'Help/Rescue',
    'Other',
  ];

  String? selectedPetType;
  String? selectedCategory;

  //image
  final int maxImage = 3;
  List<XFile> selectedImages = [];

  //location
  late Position mypostion;
  String address = "";

  late double height, width;
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    if (width > 600) {
      width = 600;
    } else {
      width = width;
    }
    return Scaffold(
      appBar: AppBar(title: Text('Pet Submit Form')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SizedBox(
            width: width,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text('Upload Image (max 3 images)'),
                  SizedBox(height: 10),
                  //image preview
                  GestureDetector(
                    onTap: multipleGallery,
                    child: Container(
                      width: width / 2,
                      height: height / 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey.shade400),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        itemCount: selectedImages.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Image.file(
                            File(selectedImages[index].path),
                            width: width / 3,
                            height: height / 4,
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: petname,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(labelText: 'Pet Name'),
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Pet Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: petType.map((String selectpet) {
                      return DropdownMenuItem<String>(
                        value: selectpet,
                        child: Text(selectpet),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPetType = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: category.map((String selectcate) {
                      return DropdownMenuItem<String>(
                        value: selectcate,
                        child: Text(selectcate),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: description,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    maxLines: 3,
                    controller: location,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () async {
                          mypostion = await _determinePosition();
                          List<Placemark> placemarks =
                              await placemarkFromCoordinates(
                                mypostion.latitude,
                                mypostion.longitude,
                              );
                          Placemark place = placemarks[0];
                          location.text =
                              "${place.name},\n${place.street},\n${place.postalCode},${place.locality},\n${place.administrativeArea},${place.country}";
                          setState(() {});
                        },
                        icon: Icon(Icons.location_on),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: submitDialog,
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //select multiple image
  Future<void> multipleGallery() async {
    final picker = ImagePicker();
    final List<XFile> selectedImage = await picker.pickMultiImage(
      limit: maxImage,
    );

    if (selectedImages.length > maxImage) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can only select a maximum of 3 images.'),
          ),
        );
      }
      selectedImages = selectedImage.sublist(0, maxImage);
    } else {
      selectedImages = selectedImage;
    }
    setState(() {});
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  void submitDialog() {
    String pet_name = petname.text.trim();
    String petdescription = description.text.trim();

    if (selectedImages.isEmpty) {
      SnackBar snackBar = const SnackBar(
        content: Text('Please upload at least 1 image'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (selectedPetType == null || selectedCategory == null) {
      SnackBar snackBar = const SnackBar(
        content: Text('Please select pet type and category'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (pet_name.isEmpty || petdescription.isEmpty) {
      SnackBar snackBar = const SnackBar(
        content: Text('Please fill in all fields'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (location.text.isEmpty) {
      SnackBar snackBar = const SnackBar(
        content: Text('Please select an address using the GPS icon'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    if (mypostion.latitude.isNaN || mypostion.longitude.isNaN) {
      SnackBar snackBar = const SnackBar(
        content: Text('Please select an address'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Submit the form?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              //submit
              submitForm();
            },
            child: Text('Submit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
        content: Text('Are you sure to submit this form?'),
      ),
    );
  }

void submitForm() async {
    // 1. SHOW LOADING DIALOG
    showDialog(
      context: context,
      barrierDismissible: false, // User cannot click outside to close
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Uploading... Please wait"),
              ],
            ),
          ),
        );
      },
    );

    try {
      // 2. PREPARE DATA
      List<String> base64List = [];
      
      // Loop through images and convert to Base64
      for (var image in selectedImages) {
        List<int> imageBytes = await image.readAsBytes();
        String base64Image = base64Encode(imageBytes);
        base64List.add(base64Image);
      }

      String pet_name = petname.text.trim();
      String petdescription = description.text.trim();

      // 3. SEND TO SERVER
      var response = await http.post(
        Uri.parse('${MyConfig.baseUrl}/pawpal/api/submit_pet.php'),
        body: {
          'user_id': widget.user?.user_id,
          'pet_name': pet_name,
          'pet_type': selectedPetType ?? '',
          'category': selectedCategory ?? '',
          'description': petdescription,
          'image_paths': jsonEncode(base64List), // Convert List to JSON String
          'lat': mypostion.latitude.toString(),
          'lng': mypostion.longitude.toString(),
        },
      );

      // 4. CLOSE LOADING DIALOG
      Navigator.pop(context); 

      // 5. CHECK RESPONSE
      if (response.statusCode == 200) {
        var jsonResponse = response.body;
        print("Server Response: $jsonResponse"); // Debug print

        var resarray = jsonDecode(jsonResponse);
        if (resarray['status'] == 'success') {
          // Success: Show Green SnackBar and Close Screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Form submitted successfully"),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Close the SubmitPetScreen
        } else {
          // Server Error: Show Red SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed: ${resarray['message']}"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Server Error: ${response.statusCode}"), backgroundColor: Colors.red),
        );
      }

    } catch (e) {
      // 6. CATCH ERRORS (Crash prevention)
      // Close loading dialog if it's still open
      if (Navigator.canPop(context)) { 
         Navigator.pop(context); 
      }
      
      print("Error in submitForm: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }
}
