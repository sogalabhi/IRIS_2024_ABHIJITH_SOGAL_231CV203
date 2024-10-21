import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:iris_app/models/user_model.dart';
import 'package:iris_app/pages/login.dart';

import 'hostelchange.dart';
import 'hostelregisteration.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String name = "";
  String email = "";
  String rollNumber = "";
  String hostel = ""; // Empty or null if no hostel registration yet
  late Map<dynamic, dynamic> userData;
  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  @override
  void initState() {
    // loadUserData();
    getData();

    super.initState();
  }

  void getData() async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    try {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (documentSnapshot.exists) {
        setState(() {
          userData = documentSnapshot.data() as Map<String, dynamic>;
        });
      } else {
        print("User document does not exist.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  void loadUserData() async {
    var userBox = Hive.box('userBox');
    UserModel? user = await userBox.get('user');
    if (user != null) {
      // Display or use user information
      print(user.name);
    }
  }

  void _signout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Dashboard"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Name
              _buildInfoTile("Name", userData['name']),
              const SizedBox(height: 10),

              // Email
              _buildInfoTile("Email", userData['email']),
              const SizedBox(height: 10),

              // Roll Number
              _buildInfoTile("Roll Number", userData['rollNumber']),
              const SizedBox(height: 10),

              // Hostel Info
              if (userData['currentHostel']['hostelName'].isNotEmpty)
                _buildInfoTile(
                    "Hostel", userData['currentHostel']['hostelName']),

              const SizedBox(height: 10),
              if (userData['currentHostel']['wingName'].isNotEmpty)
                _buildInfoTile("Wing", userData['currentHostel']['wingName']),

              const SizedBox(height: 10),
              if (userData['currentHostel']['floorNumber']!=null)
                _buildInfoTile(
                    "Floor", '${userData['currentHostel']['floorNumber']}'),

              if (userData['currentHostel']['hostelName'].isEmpty)
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
                  if (userData['currentHostel']['hostelName'].isEmpty) {
                    // Navigate to the registration page
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HostelRegistrationPage()),
                    );
                    if (result != null) {
                      setState(() {
                        userData['currentHostel']['hostelName'] =
                            result; // Update hostel after registration
                      });
                    }
                  } else {
                    // Navigate to the hostel change application page
                    print("currenthostel $userData");
                    final newHostel = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HostelChangePage(
                              currentHostel: userData)),
                    );
                    if (newHostel != null) {
                      setState(() {
                        userData['currentHostel']['hostelName'] =
                            newHostel['hostel']; // Update hostel after change
                        userData['currentHostel']['wingName'] =
                            newHostel['wing']; // Update hostel after change
                        userData['currentHostel']['floorNumber'] =
                            newHostel['floor']; // Update hostel after change
                      });
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(userData['currentHostel']['hostelName'].isEmpty
                    ? "Register for Hostel"
                    : "Apply for Hostel Change"),
              ),
              ElevatedButton(
                onPressed: _signout,
                child: const Text('Log Out'),
              ),
            ],
          ),
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
