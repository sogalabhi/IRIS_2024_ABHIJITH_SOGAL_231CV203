import 'package:flutter/material.dart';

import 'hostelchange.dart';
import 'hostelregisteration.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String name = "John Doe";
  final String email = "john.doe@example.com";
  final String rollNumber = "NITK123456";
  String hostel = ""; // Empty or null if no hostel registration yet
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Name
            _buildInfoTile("Name", name),
            const SizedBox(height: 10),

            // Email
            _buildInfoTile("Email", email),
            const SizedBox(height: 10),

            // Roll Number
            _buildInfoTile("Roll Number", rollNumber),
            const SizedBox(height: 10),

            // Hostel Info
            if (hostel.isNotEmpty) _buildInfoTile("Hostel", hostel),
            if (hostel.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  "No hostel registered yet.",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Button to Register or Apply for Hostel Change
            ElevatedButton(
              onPressed: () async {
                if (hostel.isEmpty) {
                  // Navigate to the registration page
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HostelRegistrationPage()),
                  );
                  if (result != null) {
                    setState(() {
                      hostel = result; // Update hostel after registration
                    });
                  }
                } else {
                  // Navigate to the hostel change application page
                  final newHostel = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            HostelChangePage(currentHostel: hostel)),
                  );
                  if (newHostel != null) {
                    setState(() {
                      hostel = newHostel; // Update hostel after change
                    });
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: Text(hostel.isEmpty
                  ? "Register for Hostel"
                  : "Apply for Hostel Change"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            data,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}
