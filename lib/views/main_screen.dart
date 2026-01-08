import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:pawpal_v2/models/user.dart';
import 'package:pawpal_v2/models/pet.dart';
import 'package:pawpal_v2/myconfig.dart';
import 'package:pawpal_v2/shared/mydrawer.dart';
import 'package:pawpal_v2/views/my_donation_screen.dart';
import 'package:pawpal_v2/views/pet_adopt_form_screen.dart';

class MainScreen extends StatefulWidget {
  final User? user;
  const MainScreen({super.key, required this.user});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  TextEditingController searchController = TextEditingController();
  List<Pet> listpet = [];
  String status = "Loading...";
  DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');
  late double screenWidth, screenHeight;
  int numofpage = 1;
  int curpage = 1;
  int numofresult = 0;
  var color;

  String selectedPetType = '';

  @override
  void initState() {
    //TODO: implement initState
    super.initState();
    loadpet('');
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    if (screenWidth > 600) {
      screenWidth = 600;
    } else {
      screenWidth = screenWidth;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Main Page'),
        actions: [
          IconButton(onPressed: () => loadpet(''), icon: Icon(Icons.refresh)),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 12),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: screenWidth * 0.6,
                    child: SearchBar(
                      padding: const WidgetStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      controller: searchController,
                      keyboardType: TextInputType.text,
                      onSubmitted: (value) {
                        curpage = 1;
                        loadpet(value);
                      },
                      leading: Icon(Icons.search),
                    ),
                  ),
                ),
                DropdownMenu<String>(
                  initialSelection: selectedPetType,
                  onSelected: (String? value) {
                    setState(() {
                      selectedPetType = value!;
                      curpage = 1;
                      loadpet(searchController.text);
                    });
                  },
                  dropdownMenuEntries: [
                    DropdownMenuEntry(value: '', label: 'All'),
                    DropdownMenuEntry(value: 'Dog', label: 'Dog'),
                    DropdownMenuEntry(value: 'Cat', label: 'Cat'),
                    DropdownMenuEntry(value: 'Rabbit', label: 'Rabbit'),
                    DropdownMenuEntry(value: 'Other', label: 'Other'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            listpet.isEmpty
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.find_in_page_outlined, size: 64),
                          SizedBox(height: 12),
                          Text(
                            status,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: listpet.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: screenHeight * 0.1,
                                    height: screenWidth * 0.3,
                                    color: Colors.grey[200],
                                    child: Image.network(
                                      '${MyConfig.baseUrl}/pawpal/assets/pets/pet_${listpet[index].petId}_0.png',
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, StackTrace) {
                                            return const Icon(
                                              Icons.broken_image,
                                              size: 60,
                                              color: Colors.grey,
                                            );
                                          },
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                //TEXT AREA
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // TITLE
                                      Text(
                                        listpet[index].petName.toString(),
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      const SizedBox(height: 4),

                                      // DESCRIPTION
                                      Text(
                                        listpet[index].description.toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),

                                      const SizedBox(height: 6),

                                      // DISTRICT TAG
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey.withOpacity(
                                            0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          listpet[index].petType.toString(),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blueGrey.withOpacity(
                                            0.15,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          listpet[index].category.toString(),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.blueGrey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                IconButton(
                                  onPressed: () {
                                    _showPetDetails(listpet[index]);
                                  },
                                  icon: const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            //pagination builder
            SizedBox(
              height: screenHeight * 0.05,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: numofpage,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  color = (curpage - 1) == index ? Colors.red : Colors.black;
                  return TextButton(
                    onPressed: () {
                      curpage = index + 1;
                      loadpet('');
                    },
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(color: color, fontSize: 18),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      drawer: MyDrawer(user: widget.user),
    );
  }

  void loadpet(String searchQuery) {
    // TODO: implement loadServices
    listpet.clear();
    setState(() {
      status = "Loading...";
    });

    String type = selectedPetType;

    http
        .get(
          Uri.parse(
            '${MyConfig.baseUrl}/pawpal/api/get_my_pets.php?search=$searchQuery&curpage=$curpage&type=$type',
          ),
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsonResponse = jsonDecode(response.body);
            // log(jsonResponse.toString());
            if (jsonResponse['status'] == 'success' &&
                jsonResponse['data'] != null &&
                jsonResponse['data'].isNotEmpty) {
              // has data → load to list
              listpet.clear();
              for (var item in jsonResponse['data']) {
                listpet.add(Pet.fromJson(item));
              }
              numofpage = int.parse(jsonResponse['numofpage'].toString());
              numofresult = int.parse(
                jsonResponse['numberofresult'].toString(),
              );
              print(numofpage);
              print(numofresult);
              setState(() {
                status = "";
              });
            } else {
              // success but EMPTY data
              setState(() {
                listpet.clear();
                status = "No submissions yet";
              });
            }
          } else {
            // request failed
            setState(() {
              listpet.clear();
              status = "Failed to load services";
            });
          }
        });
  }

  //show pet details dialog
void _showPetDetails(Pet pet) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Determine what the button should say and do based on category
      String buttonText = "Contact Owner";
      VoidCallback? onButtonPressed;

      switch (pet.category) {
        case 'Adoption':
          buttonText = "Apply to Adopt";
          onButtonPressed = () {
            Navigator.pop(context); // Close dialog
            // Navigate to your Adoption Form Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (content) => PetAdoptFormScreen(user: widget.user, pet: pet),
              ),
            );
          };
          break;
        case 'Donation Request':
          buttonText = "Donate";
          onButtonPressed = () {
            Navigator.pop(context); // Close dialog
            // Navigate to your Donation Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (content) => MyDonationScreen(user: widget.user, pet: pet),
              ),
            );
          };
          break;
        case 'Help/Rescue':
          buttonText = "Volunteer to Help";
          onButtonPressed = null;
          break;
        case 'Other':
          buttonText = "No action available";
          onButtonPressed = null;
          break;
        default:
          buttonText = "View Details";
          onButtonPressed = null;
      }

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. IMAGE SECTION
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
                child: Image.network(
                  '${MyConfig.baseUrl}/pawpal/assets/pets/pet_${pet.petId}_0.png',
                  height: 200, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200, color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, size: 50),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pet.petName.toString(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const Divider(),

                    // SHARED DETAIL ROWS
                    _detailRow(Icons.person, "Owner", pet.username ?? "Unknown"),
                    _detailRow(Icons.pets, "Type", pet.petType ?? "N/A"),
                    _detailRow(Icons.category, "Category", pet.category ?? "General"),
                    _detailRow(Icons.location_on, "Location", "Lat: ${pet.lat}"),

                    const SizedBox(height: 24),

                    // DYNAMIC BUTTON BASED ON CATEGORY
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: onButtonPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(buttonText),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // SHARED CANCEL BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Close"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  // DETAIL ROW WIDGET
  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
