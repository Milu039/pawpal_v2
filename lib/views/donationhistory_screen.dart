import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:pawpal_v2/models/user.dart';
import 'package:pawpal_v2/myconfig.dart';
import 'package:pawpal_v2/shared/mydrawer.dart';
import 'package:pawpal_v2/models/donation.dart'; 

class DonationHistoryScreen extends StatefulWidget {
  final User? user;
  const DonationHistoryScreen({super.key, required this.user});

  @override
  State<DonationHistoryScreen> createState() => DonationHistoryScreenState();
}

class DonationHistoryScreenState extends State<DonationHistoryScreen> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> listDonations = []; // Using dynamic if model isn't created yet
  String status = "Loading...";
  DateFormat formatter = DateFormat('dd/MM/yyyy hh:mm a');
  late double screenWidth, screenHeight;
  
  int numofpage = 1;
  int curpage = 1;
  int numofresult = 0;
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    loadDonations('');
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    if (screenWidth > 600) screenWidth = 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Donation History'),
        actions: [
          IconButton(
            onPressed: () => loadDonations(''), 
            icon: const Icon(Icons.refresh)
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // LIST VIEW AREA
            listDonations.isEmpty
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.history, size: 64, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(status, style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: listDonations.length,
                      itemBuilder: (context, index) {
                        var donation = listDonations[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(
                              children: [
                                // Image (Using pet_id for the thumbnail)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    '${MyConfig.baseUrl}/pawpal/assets/pets/pet_${donation['pet_id']}_0.png',
                                    width: 80, height: 80, fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => 
                                      const Icon(Icons.favorite, size: 40, color: Colors.redAccent),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Donation Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "To: ${donation['pet_name'] ?? 'Pet #' + donation['pet_id']}",
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Donated: RM ${donation['donate']}",
                                        style: const TextStyle(fontSize: 15, color: Colors.green, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Date: ${donation['reg_date']}",
                                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Chip(
                                  label: Text(donation['category'] ?? "General"),
                                  backgroundColor: Colors.blueAccent.withOpacity(0.1),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            // PAGINATION
            SizedBox(
              height: screenHeight * 0.05,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: numofpage,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return TextButton(
                    onPressed: () {
                      curpage = index + 1;
                      loadDonations(searchController.text);
                    },
                    child: Text(
                      (index + 1).toString(),
                      style: TextStyle(
                        color: (curpage - 1) == index ? Colors.red : Colors.black,
                        fontSize: 18,
                      ),
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

  void loadDonations(String searchQuery) {
    setState(() {
      status = "Loading...";
      listDonations.clear();
    });

    // We pass user_id to load ONLY this user's history
    http.get(
      Uri.parse(
        '${MyConfig.baseUrl}/pawpal/api/get_donation.php?user_id=${widget.user?.user_id}&search=$searchQuery&curpage=$curpage&category=$selectedCategory',
      ),
    ).then((response) {
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success' && jsonResponse['data'] != null) {
          setState(() {
            listDonations = jsonResponse['data'];
            numofpage = int.parse(jsonResponse['numofpage'].toString());
            status = "";
          });
        } else {
          setState(() {
            status = "No donations found";
          });
        }
      } else {
        setState(() => status = "Server Error: ${response.statusCode}");
      }
    });
  }
}