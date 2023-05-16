import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GuestDash extends StatefulWidget {
  const GuestDash({super.key});

  @override
  State<GuestDash> createState() => _GuestDashState();
}

class _GuestDashState extends State<GuestDash> {
  late Future<int> _totalRecord;

  @override
  void initState() {
    super.initState();
    _totalRecord = getTotalRecord();
  }

  Future<int> getTotalRecord() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('myguest').get();
    return snapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _totalRecord,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error Mendapatkan Data'),
            );
          }
          Object? count = snapshot.data;
          return Container(
              padding: const EdgeInsets.all(8.0),
              margin:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.6),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                'Total Record: $count',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ));
        });
  }
}
