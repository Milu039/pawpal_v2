import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for input formatters
import 'package:pawpal_v2/models/pet.dart';
import 'package:pawpal_v2/myconfig.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pawpal_v2/models/user.dart';
import 'package:pawpal_v2/views/payment_screen.dart';

class MyDonationScreen extends StatefulWidget {
  final Pet? pet;
  final User? user;
  const MyDonationScreen({super.key, required this.pet, required this.user});

  @override
  State<MyDonationScreen> createState() => _MyDonationScreenState();
}

class _MyDonationScreenState extends State<MyDonationScreen> {
  TextEditingController foodDetailsController = TextEditingController();
  TextEditingController medicalDetailsController = TextEditingController();
  TextEditingController moneyAmountController = TextEditingController();

  late double screenWidth;
  late double screenHeight;

  String selectedDonationType = "Food";

  List<String> donationTypes = ["Food", "Medical", "Money"];

  @override
  void dispose() {
    foodDetailsController.dispose();
    medicalDetailsController.dispose();
    moneyAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    double layoutWidth = screenWidth > 600 ? 600 : screenWidth;

    return Scaffold(
      appBar: AppBar(title: const Text('Donations Page')),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Help ${widget.pet?.petName ?? "this pet"} by making a donation!',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // PET IMAGE
                SizedBox(
                  width: layoutWidth * 0.5,
                  height: 180,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    child: Image.network(
                      '${MyConfig.baseUrl}/pawpal/assets/pets/pet_${widget.pet?.petId}_0.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedDonationType,
                  decoration: _dropdownDecoration(
                    "Select Donation Type",
                    Icons.category,
                  ),
                  items: donationTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDonationType = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 20),
                donationForm(),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: submitDonation,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Donate Now', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submitDonation() {
    String foodDetail = foodDetailsController.text.trim();
    String medicalDetail = medicalDetailsController.text.trim();
    double moneyAmount = double.tryParse(moneyAmountController.text.trim()) ?? 0;
    String donated_item = "";
    int money = moneyAmount.toInt();

    // Validations
    if (selectedDonationType == "Food" && foodDetail.isEmpty) {
      _showSnack('Please enter food details.');
      return;
    } else if (selectedDonationType == "Medical" && medicalDetail.isEmpty) {
      _showSnack('Please enter medical details.');
      return;
    } else if (selectedDonationType == "Money" && moneyAmount <= 0) {
      _showSnack('Please enter a valid donation amount.');
      return;
    }

    if (foodDetail.isNotEmpty){
      donated_item = foodDetail;
    }else if(medicalDetail.isNotEmpty){
      donated_item = medicalDetail;
    }else if(!moneyAmount.isNaN){
      donated_item = moneyAmount.toString();
    }
    // API Check
    http.post(
      Uri.parse('${MyConfig.baseUrl}/pawpal/api/check_donation.php'),
      body: {
        'user_id': widget.user?.user_id.toString(),
        'pet_id': widget.pet?.petId.toString(),
        'category': selectedDonationType,
        'donate': donated_item,
      },
    ).then((response) {
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse['status'] == 'success') {
          if (!mounted) return;
          
          if (selectedDonationType == "Money") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentScreen(
                  user: widget.user!,
                  money: money, 
                  pet: widget.pet!, 
                  category: selectedDonationType, 
                ),
              ),
            );
          } else {
            _showSnack('Thank you for your contribution!');
            Navigator.pop(context);
          }
        } else {
          _showSnack(jsonResponse['message'] ?? 'Check failed');
        }
      } else {
        _showSnack('Server error: ${response.statusCode}');
      }
    }).catchError((error) {
      _showSnack('Connection error: $error');
    });
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration _dropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  Widget donationForm() {
    if (selectedDonationType == "Food") {
      return TextFormField(
        key: const ValueKey("food"),
        controller: foodDetailsController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: "Food Details",
          hintText: "Enter brand, weight, or type",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (selectedDonationType == "Medical") {
      return TextFormField(
        key: const ValueKey("med"),
        controller: medicalDetailsController,
        maxLines: 3,
        decoration: InputDecoration(
          labelText: "Medical Details",
          hintText: "Describe the medication or clinical support",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else if (selectedDonationType == "Money") {
      return TextFormField(
        key: const ValueKey("money"),
        controller: moneyAmountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        // Added inputFormatters to restrict to 2 decimal places
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        decoration: InputDecoration(
          labelText: "Amount (RM)",
          prefixText: "RM ",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}