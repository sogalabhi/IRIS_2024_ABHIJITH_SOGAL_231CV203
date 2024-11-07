import 'package:cloud_firestore/cloud_firestore.dart';

import 'getuserbyuid.dart';
import 'send_fcm.dart';

Future<void> updateHostelData(Map<String, dynamic> hostels, String hostelId,
      String wingId, String floorId, String userId, String statusmsg) async {
    //firestore init
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get the updated hostel data
    Map<String, dynamic> updatedHostelData = hostels;
    WriteBatch batch = firestore.batch();
    try {
      updatedHostelData.forEach((hostelId, hostelInfo) {
        DocumentReference docRef =
            firestore.collection('hostels').doc(hostelId);
        batch.set(
            docRef, hostelInfo); // Use set to overwrite the entire document
      });
      await batch.commit();

      print('Hostels updated successfully.');
      // Update the current hostel in the user's document
      await firestore.collection('users').doc(userId).update({
        'currentHostel': {
          'hostelId': hostelId,
          'hostelName': updatedHostelData[hostelId]['name'],
          'wingId': wingId,
          'wingName': updatedHostelData[hostelId]['floors'][floorId]['wings']
              [wingId]['name'],
          'floorId': floorId,
          'floorNumber': updatedHostelData[hostelId]['floors'][floorId]['name'],
        },
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
          "Admin has approved the hostel change to ${updatedHostelData[hostelId]['name']}",
      deviceToken: fcmToken,
    );
  }