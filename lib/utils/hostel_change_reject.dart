 import 'package:cloud_firestore/cloud_firestore.dart';

import 'getuserbyuid.dart';
import 'send_fcm.dart';

Future<void> rejectHostel(String userId, String statusmsg) async {
    //firestore init
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      // Update the current hostel in the user's document
      await firestore.collection('users').doc(userId).update({
        'newHostel': FieldValue.delete(),
      });
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('hostel_change_requests')
          .doc(userId);

      // Update the 'vacancies' field
      await docRef.update({
        'status': statusmsg, // Set the field to the new value
      }).then((_) {
        print("Field updated successfully!");
      }).catchError((error) {
        print("Error updating field: $error");
      });
      print('Hostel data updated successfully');
    } catch (e) {
      print('Failed to update hostel data: $e');
    }
    var user = await getUserDetails(userId);
    String fcmToken = await getTokenByEmail(user?['email']);
    //Send notification
    await sendNotificationV1(
      title: "Update on hostel change request",
      body:
          "Admin has rejected the hostel change",
      deviceToken: fcmToken,
    );
  }