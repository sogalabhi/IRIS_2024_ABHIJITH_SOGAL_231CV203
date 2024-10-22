import 'package:flutter/material.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add user functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search/Filter Section
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Select Hostel'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Hostel 1', child: Text('Hostel 1')),
                      DropdownMenuItem(
                          value: 'Hostel 2', child: Text('Hostel 2')),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Wing'),
                    items: const [
                      DropdownMenuItem(value: 'Wing A', child: Text('Wing A')),
                      DropdownMenuItem(value: 'Wing B', child: Text('Wing B')),
                    ],
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Select Floor'),
                    items: const [
                      DropdownMenuItem(
                          value: 'Floor 1', child: Text('Floor 1')),
                      DropdownMenuItem(
                          value: 'Floor 2', child: Text('Floor 2')),
                    ],
                    onChanged: (value) {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Leave Status'),
                    items: const [
                      DropdownMenuItem(
                          value: 'On Leave', child: Text('On Leave')),
                      DropdownMenuItem(
                          value: 'Present', child: Text('Present')),
                    ],
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User List Section
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Replace with your user count
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User details
                          Text('Name: User $index',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Email: user@example.com'),
                          const Text('Roll No: 123456'),
                          const Text('Hostel: Hostel 1'),
                          const Text('Wing: Wing A'),
                          const Text('Floor: Floor 1'),
                          const SizedBox(height: 8),

                          // Leave Status
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Status: Present'),
                              Row(
                                children: [
                                  // Reallocate Button
                                  TextButton(
                                    onPressed: () {
                                      // Reallocate user logic
                                    },
                                    child: const Text('Reallocate'),
                                  ),
                                  // Deallocate Button
                                  TextButton(
                                    onPressed: () {
                                      // Deallocate user logic
                                    },
                                    child: const Text('Deallocate'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // Floating Action Button for any extra actions (e.g., add user)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add user functionality
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
