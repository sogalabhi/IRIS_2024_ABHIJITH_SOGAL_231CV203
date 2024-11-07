import 'package:cloud_firestore/cloud_firestore.dart';

Future<List<Map<String, dynamic>>> getAllHostels() async {
    List<Map<String, dynamic>> hostels = [];
    try {
      // Fetch all documents from the 'hostels' collection
      QuerySnapshot hostelChangeRequests = await FirebaseFirestore.instance
          .collection('hostel_change_requests')
          .where('status', isEqualTo: 'pending')
          .get();

      for (var doc in hostelChangeRequests.docs) {
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
        hostels.add({
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
    return hostels; // Return the hostels map
  }