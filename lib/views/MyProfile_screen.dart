import 'package:flutter/material.dart';
import 'package:pawpal_v2/models/user.dart';
import 'package:pawpal_v2/myconfig.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pawpal_v2/shared/mydrawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyprofileScreen extends StatefulWidget {
  final User? user;
  const MyprofileScreen({super.key, required this.user});

  @override
  State<MyprofileScreen> createState() => _MyprofileScreenState();
}

class _MyprofileScreenState extends State<MyprofileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  File? image;
  late double screenWidth;
  late double screenHeight;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.user!.name!;
    emailController.text = widget.user!.email!;
    phoneController.text = widget.user!.phone!;
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    if (screenWidth > 600) {
      screenWidth = 600;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: previewImage(),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.user?.name}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.user?.email}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.all(16.0),
                width: screenWidth,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.person),
                      ),
                      controller: nameController,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.email),
                      ),
                      controller: emailController,
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.phone),
                      ),
                      controller: phoneController,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateProfile,
                      child: const Text('Save Changes'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: MyDrawer(user: widget.user),
    );
  }

  void _updateProfile() {
    String base64Image = "";
    String name = nameController.text.trim();
    String phone = phoneController.text.trim();

    if (image == null) {
      base64Image = "NA";
    } else {
      base64Image = base64Encode(image!.readAsBytesSync());
    }

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    http.post(
      Uri.parse('${MyConfig.baseUrl}/pawpal/api/edit_profile.php'),
      body: {
        'user_id': widget.user?.user_id.toString(),
        'name': name,
        'phone': phone,
        'image': base64Image,
      },
    ).then((response) {
      Navigator.pop(context); // Close loading dialog
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status'] == "success") {
          // UPDATE LOCAL SESSION AND UI
          _saveSession(name, phone);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: ${data['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to connect to server')));
      }
    }).catchError((error) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')));
    });
  }

  // HELPER FUNCTION TO UPDATE LOCAL STORAGE AND CURRENT OBJECT
  Future<void> _saveSession(String name, String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Update SharedPreferences
    await prefs.setString('name', name);
    await prefs.setString('phone', phone);
    
    // Update the actual object in the current widget state
    // This makes sure 'MyDrawer' and the header on this page update immediately
    setState(() {
      widget.user?.name = name;
      widget.user?.phone = phone;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera); 

    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

  Widget previewImage() {
    if (image != null) {
      return ClipOval(
        child: Image.file(
          image!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    } else if (widget.user!.profile_image != null && widget.user!.profile_image != "NA") {
      return ClipOval(
        child: Image.network(
          '${MyConfig.baseUrl}/pawpal/assets/user_profile/user_profile_${widget.user?.user_id}.png',
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 80),
        ),
      );
    } else {
      return const ClipOval(
        child: Icon(Icons.person, size: 80),
      );
    }
  }
}