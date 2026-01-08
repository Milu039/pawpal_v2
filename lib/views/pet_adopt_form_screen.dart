import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pawpal_v2/models/user.dart';
import 'package:pawpal_v2/models/pet.dart';
import 'package:pawpal_v2/myconfig.dart';
import 'package:http/http.dart' as http;

class PetAdoptFormScreen extends StatefulWidget {
  final User? user;
  final Pet? pet;
  const PetAdoptFormScreen({super.key, required this.user, required this.pet});

  @override
  State<PetAdoptFormScreen> createState() => _PetAdoptFormScreenState();
}

class _PetAdoptFormScreenState extends State<PetAdoptFormScreen> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController reasonController = TextEditingController();

  late double screenWidth;
  late double screenHeight;

  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill user details
    fullNameController.text = widget.user?.name ?? "";
    emailController.text = widget.user?.email ?? "";
    phoneController.text = widget.user?.phone ?? "";
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    reasonController.dispose();
    super.dispose();
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
      appBar: AppBar(title: Text('Pet Adoption Form')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${widget.pet?.petName} Adoption Form',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              // PET IMAGE
              SizedBox(
                width: screenWidth * 0.5,
                height: 200,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                  child: Image.network(
                    '${MyConfig.baseUrl}/pawpal/assets/pets/pet_${widget.pet?.petId}_0.png',
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: fullNameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: reasonController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Why do you want to adopt this pet?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value ?? false;
                      });
                    },
                  ),
                  const Text("Are you sure to adopt this pet?"),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitAdoptionForm,
                child: const Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submitAdoptionForm() {
    String fullName = fullNameController.text;
    String email = emailController.text;
    String phone = phoneController.text;
    String reason = reasonController.text;
    //validate the empty field
    if (fullName.isEmpty || email.isEmpty || phone.isEmpty || reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }
    //validate checkbox
    if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please confirm to adopt the pet')),
      );
      return;
    }
    http
        .post(
          Uri.parse('${MyConfig.baseUrl}/pawpal/api/submit_adoption_form.php'),
          body: {
            'user_id': widget.user?.user_id.toString(),
            'pet_id': widget.pet?.petId.toString(),
            'full_name': fullName,
            'email': email,
            'phone': phone,
            'reason': reason,
            'is_checked': isChecked ? '1' : '0',
          },
        )
        .then((response) {
          if (response.statusCode == 200) {
            var jsonResponse = json.decode(response.body);
            if (jsonResponse['status'] == 'success') {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Adoption application submitted successfully!',
                    ),
                  ),
                );
              }
            } else {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${jsonResponse['message']}',
                    ),
                  ),
                );
              }
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Server error: ${response.statusCode}')),
              );
            }
          }
        })
        .catchError((error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error submitting application: $error')),
            );
          }
        });
  }
}
