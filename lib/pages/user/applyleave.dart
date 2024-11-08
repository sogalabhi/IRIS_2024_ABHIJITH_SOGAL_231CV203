import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:iris_app/utils/send_fcm.dart';

class LeaveApplicationForm extends StatefulWidget {
  const LeaveApplicationForm({super.key});

  @override
  State<LeaveApplicationForm> createState() => _LeaveApplicationFormState();
}

class _LeaveApplicationFormState extends State<LeaveApplicationForm> {
  DateTime? startDate;
  DateTime? endDate;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Function to pick date
  Future<void> _selectDate(BuildContext context,
      TextEditingController controller, String date) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (selectedDate != null) {
      setState(() {
        controller.text = "${selectedDate.toLocal()}".split(' ')[0];
        if (date == 'start') {
          startDate = selectedDate;
        } else {
          endDate = selectedDate;
        }
      });
    }
  }

  
  // Function to submit the form and upload data to Firestore
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Get the current user's UID
      final User? user = FirebaseAuth.instance.currentUser;
      final uid = user?.uid ??
          'default_uid'; // Replace 'default_uid' with actual logic as per your needs

      // Data to upload to Firestore
      final Map<String, dynamic> leaveApplication = {
        'fromDate': startDate,
        'toDate': endDate,
        'message': _messageController.text,
        'uid': uid,
      };

      try {
        // Upload to Firestore
        await FirebaseFirestore.instance
            .collection('leave_applications')
            .add(leaveApplication);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Leave Application Submitted')));
        String fcmToken = await getTokenByEmail("admin@gmail.com");
        //Send notification
        await sendNotificationV1(
          title: "New Leave Application",
          body:
              "User has applied for leave from ${startDate.toString().substring(0, 10)} to ${endDate.toString().substring(0, 10)}",
          deviceToken: fcmToken,
        );
      } catch (e) {
        // Handle Firestore errors
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leave Application Form',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff3b3e72),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // From Date Picker
              TextFormField(
                controller: _fromDateController,
                decoration: const InputDecoration(labelText: 'From Date'),
                readOnly: true,
                onTap: () => _selectDate(context, _fromDateController, 'start'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a from date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // To Date Picker
              TextFormField(
                controller: _toDateController,
                decoration: const InputDecoration(labelText: 'To Date'),
                readOnly: true,
                onTap: () => _selectDate(context, _toDateController, 'end'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a to date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Message Field
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: 'Message'),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  print(startDate);
                  if (startDate!.isAfter(endDate!)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid from to date')));
                  } else {
                    _submitForm();
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
