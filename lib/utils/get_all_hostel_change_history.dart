import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> getAllRequestHIstory() async {
    List<Map<String, dynamic>> history = [];
    try {
      QuerySnapshot hostelChangeRequestshistory = await FirebaseFirestore
          .instance
          .collection('hostel_change_requests')
          .where('status', whereIn: ['approved', 'rejected']).get();
      // Loop through each document and store it in the map
      for (var doc in hostelChangeRequestshistory.docs) {
        Map requestData = doc.data() as Map;
        String uid = requestData['userId'];
        String hostelId = requestData['hostelId'];
        String floorId = requestData['floorId'];
        String wingId = requestData['wingId'];
        DocumentSnapshot userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(uid).get();
        Map userData = userSnapshot.data() as Map;
        DocumentSnapshot hostelSnapshot = await FirebaseFirestore.instance
            .collection('hostels')
            .doc(hostelId)
            .get();
        Map<String, dynamic> hostelData =
            hostelSnapshot.data() as Map<String, dynamic>;

        history.add({
          'request': requestData,
          'user': userData,
          'hostel': hostelData,
          'floorId': floorId,
          'wingId': wingId,
        });
      }
    } catch (e) {
      print("Error fetching hostels: $e");
    }
    return history; // Return the hostels map
  }