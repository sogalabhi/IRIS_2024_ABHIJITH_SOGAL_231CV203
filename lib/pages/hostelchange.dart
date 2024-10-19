import 'package:flutter/material.dart';

class HostelChangePage extends StatefulWidget {
  final String currentHostel;

  const HostelChangePage({super.key, required this.currentHostel});
  @override
  State<HostelChangePage> createState() => _HostelChangePageState();
}

class _HostelChangePageState extends State<HostelChangePage> {
  final _hostelOptions = ["Hostel 1", "Hostel 2", "Hostel 3", "Hostel 4"];
  String? _newHostel;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Apply for Hostel Change"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Current Hostel: ${widget.currentHostel}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Dropdown to select new hostel
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: _newHostel,
              hint: const Text("Select New Hostel"),
              items: _hostelOptions
                  .where((hostel) => hostel != widget.currentHostel)
                  .map((hostel) {
                return DropdownMenuItem<String>(
                  value: hostel,
                  child: Text(hostel),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _newHostel = value;
                });
              },
            ),
            const SizedBox(height: 30),

            // Submit button
            ElevatedButton(
              onPressed: () {
                if (_newHostel != null) {
                  // Handle hostel change logic here
                  Navigator.pop(context, _newHostel); // Return to dashboard
                } else {
                  // Show error if no new hostel selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a new hostel!")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                child: Text("Apply for Change"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
