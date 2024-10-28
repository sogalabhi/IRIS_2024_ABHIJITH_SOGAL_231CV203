import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>?> getUserDetails(String uid) async {
  try {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.exists ? userDoc.data() : null;
  } catch (e) {
    print("Error fetching user details: $e");
    return null;
  }
}
