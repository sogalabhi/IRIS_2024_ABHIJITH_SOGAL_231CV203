// Card Widget for Pending Requests
import 'package:flutter/material.dart';

import '../utils/hostel_change_approve.dart';
import '../utils/hostel_change_reject.dart';

Widget buildRequestCard(
    {required Map request,
    required String userName,
    required String currentHostel,
    required String requestedHostel,
    required String requestedWing,
    required String requestedFloor,
    required int availableVacancies,
    required Map allHostels,
    required BuildContext context}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 10),
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Name: $userName',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text('Current Hostel: $currentHostel'),
          Text('Requested Hostel: $requestedHostel'),
          Text('Requested Wing: $requestedWing'),
          Text('Requested Floor: $requestedFloor'),
          const SizedBox(height: 8),
          Text(
            'Available Vacancies: $availableVacancies',
            style: const TextStyle(
                color: Colors.green, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (availableVacancies > 0) {
                    String newhostelId = request['request']['hostelId'];
                    String oldhostelId =
                        request['user']['currentHostel']['hostelId'];
                    String newfloorId = request['request']['floorId'];
                    String oldfloorId =
                        request['user']['currentHostel']['floorId'];
                    String newwingId = request['request']['wingId'];
                    String oldwingId =
                        request['user']['currentHostel']['wingId'];

                    //Decrease vacancy in new hostel
                    //1. total vacancies
                    allHostels[newhostelId]['totalVacancies']--;
                    //2. floor vacancy
                    allHostels[newhostelId]['floors'][newfloorId]
                        ['vacancies']--;
                    //3. wing vacancy
                    allHostels[newhostelId]['floors'][newfloorId]['wings']
                        [newwingId]['vacancies']--;

                    //Increase vacancy in old hostel
                    //1. total vacancies
                    allHostels[oldhostelId]['totalVacancies']++;
                    //2. floor vacancy
                    allHostels[oldhostelId]['floors'][oldfloorId]
                        ['vacancies']++;
                    // //3. wing vacancy
                    allHostels[oldhostelId]['floors'][oldfloorId]['wings']
                        [oldwingId]['vacancies']++;
                    print("Update hostel data: ${allHostels[oldhostelId]}");
                    String uid = request['request']['userId'];
                    //   print('uid $selectedHostel $selectedWing $selectedFloor');
                    updateHostelData(allHostels as Map<String, dynamic>,
                        newhostelId, newwingId, newfloorId, uid, "approved");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Application approved'),
                      ),
                    );

                    Navigator.pop(context);
                  }
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.green),
                ),
                child: const Text('Approve'),
              ),
              ElevatedButton(
                onPressed: () {
                  rejectHostel(request['request']['userId'], "rejected");
                  Navigator.pop(context);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                ),
                child: const Text('Reject'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
