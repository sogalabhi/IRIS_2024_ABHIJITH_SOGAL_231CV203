import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iris_app/pages/homepage.dart';
import 'package:iris_app/pages/login.dart';

import '../models/user_model.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _rollNoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String uid = "";
  void _chkUserStatus() {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      print(user);
      // User is already signed in, redirect to home page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        String name = _nameController.text.trim();
        String rollNumber = _rollNoController.text.trim();
        String email = _emailController.text.trim();
        // Register the user with Firebase Auth
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        String uid = userCredential.user!.uid;

        //  Store additional user details in Firestore if needed
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': name,
          'rollNumber': rollNumber,
          'email': email,
          'currentHostel': ""
        });

        // Show a success message or navigate to another page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$uid Registered successfully!')),
        );
        void saveUserData(UserModel user) async {
          var userBox = Hive.box('userBox');
          userBox.put('user', user);
        }

        saveUserData(UserModel(
            name: name,
            email: email,
            rollNumber: rollNumber,
            currentHostel: ''));

        void loadUserData() async {
          var userBox = Hive.box('userBox');
          print(userBox);
          UserModel? user = userBox.get('user');

          if (user != null) {
            print("Username ${user.name}");
          }
        }

        loadUserData();
        // Clear the fields
        // _nameController.clear();
        // _rollNoController.clear();
        // _emailController.clear();
        // _passwordController.clear();
        // Navigator.pushReplacement(
        //     context, MaterialPageRoute(builder: (context) => const HomePage()));
      } catch (e) {
        // Handle registration error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Account'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _rollNoController,
                  decoration: const InputDecoration(labelText: 'Roll Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your roll number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _register,
                  child: const Text('Register'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text('Go to login page'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
