import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iris_app/pages/admin/hostelchangerequests.dart';
import 'package:iris_app/pages/admin/manageHostels.dart';
import 'package:iris_app/pages/admin/usermanagement.dart';
import 'package:iris_app/pages/admin/usersonleave.dart';
import 'package:iris_app/pages/login.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    void _signout() async {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          ElevatedButton(
            onPressed: _signout,
            child: const Icon(Icons.logout),
          ),
        ],
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview section
            const Text(
              "Overview",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildOverviewCard("Total Hostels", "5", Icons.home),
                  buildOverviewCard(
                      "Total hostellites", "780", Icons.location_city),
                  buildOverviewCard(
                      "Available Vacancies", "200", Icons.event_seat),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Notifications section
            const Text(
              "Notifications",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.orange[50],
              child: ListTile(
                leading: const Icon(Icons.notification_important,
                    color: Colors.orange),
                title: const Text("Pending Hostel Change Requests"),
                subtitle: const Text("3 requests awaiting approval"),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HostelChangeRequestsPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),

            // Quick Links section
            const Text(
              "Quick Links",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildQuickLinkButton("Manage Hostels", Icons.manage_accounts,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HostelManagementPage(),
                      ),
                    );
                  }),
                  const SizedBox(width: 10),
                  buildQuickLinkButton("Users on Leave", Icons.person_off, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeaveApplicationsList(),
                      ),
                    );
                  }),
                  const SizedBox(width: 10),
                  buildQuickLinkButton("Process Requests", Icons.assignment,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HostelChangeRequestsPage(),
                      ),
                    );
                  }),
                  const SizedBox(width: 10),
                  buildQuickLinkButton("Manage Users", Icons.assignment, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UserManagementPage(),
                      ),
                    );
                  }),
                  const SizedBox(width: 10),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Current Hostel Status
            const Text(
              "Current Hostel Status",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.blue[50],
              child: const ListTile(
                leading: Icon(Icons.info, color: Colors.blue),
                title: Text("Vacancies: 42 / Total Capacity: 60"),
                subtitle: Text("Hostel 1 - Wing A, Wing B, Wing C"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build overview cards
  Widget buildOverviewCard(String title, String count, IconData icon) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              count,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build quick link buttons
  Widget buildQuickLinkButton(String title, IconData icon, Function onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(100, 80),
      ),
      onPressed: () {
        onPressed();
      },
      icon: Icon(icon, size: 30),
      label: Text(
        title,
        textAlign: TextAlign.center,
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: AdminDashboardPage(),
  ));
}
