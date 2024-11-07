  // Card Widget for Request History
  import 'package:flutter/material.dart';

Widget buildHistoryCard({
    required String userName,
    required String action,
    required String rollNumber,
    required String toHostel,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: $userName',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text('Action: $action'),
            Text('Roll Number: $rollNumber'),
            Text('To Hostel: $toHostel'),
          ],
        ),
      ),
    );
  }