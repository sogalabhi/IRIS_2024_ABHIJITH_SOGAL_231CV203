// Page for Hostel Registration
import 'package:flutter/material.dart';

class HostelRegistrationPage extends StatefulWidget {
  const HostelRegistrationPage({super.key});

  @override
  State<HostelRegistrationPage> createState() => _HostelRegistrationPageState();
}

class _HostelRegistrationPageState extends State<HostelRegistrationPage> {
  final _hostelOptions = [
    {"name": "Hostel 1", "availableRooms": 10, "layout": "Layout A"},
    {"name": "Hostel 2", "availableRooms": 5, "layout": "Layout B"},
    {"name": "Hostel 3", "availableRooms": 3, "layout": "Layout C"},
    {"name": "Hostel 4", "availableRooms": 8, "layout": "Layout D"},
  ];

  String? _selectedHostel;
  Map<String, dynamic>? _hostelDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register for Hostel"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select a Hostel",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Dropdown to select hostel
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: _selectedHostel,
              hint: const Text("Choose a Hostel"),
              items: _hostelOptions.map((hostel) {
                return DropdownMenuItem<String>(
                  value: hostel["name"] as String?,
                  child: Text(hostel["name"] as String),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedHostel = value;
                  _hostelDetails = _hostelOptions.firstWhere(
                      (hostel) => hostel["name"] == _selectedHostel);
                });
              },
            ),
            const SizedBox(height: 20),

            if (_hostelDetails != null) ...[
              const Text(
                "Hostel Details:",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 10),
              Text("Available Rooms: ${_hostelDetails!["availableRooms"]}"),
              Text("Layout: ${_hostelDetails!["layout"]}"),
              const SizedBox(height: 30),
            ],

            // Submit button
            ElevatedButton(
              onPressed: () {
                if (_selectedHostel != null) {
                  Navigator.pop(
                      context, _selectedHostel); // Pass selected hostel
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a hostel!")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                child: Text("Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
