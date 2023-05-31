import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class YaoFilter extends StatefulWidget {
  const YaoFilter({super.key});

  @override
  State<YaoFilter> createState() => _YaoFilterState();
}

class _YaoFilterState extends State<YaoFilter> {
  late Stream<QuerySnapshot> _dataSnap;
  late DateTime _selectedDate;
  late DateTime _selectedStartDate;
  late DateTime _selectedEndDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _dataSnap = getData(_selectedDate);
    _selectedStartDate = DateTime.now();
    _selectedEndDate = DateTime.now();
  }

  void _showDatePicker(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: isStartDate ? _selectedStartDate : _selectedEndDate,
        firstDate: DateTime(2023),
        lastDate: DateTime(2025));
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _selectedStartDate = picked;
        } else {
          _selectedEndDate = picked;
        }
        _dataSnap = getData(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: const [],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                  onPressed: () => _showDatePicker(context, false),
                  child: Text(
                      "Start Date: ${_selectedStartDate.toString().substring(0, 10)}"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                  onPressed: () => _showDatePicker(context, false),
                  child: Text(
                      "End Date: ${_selectedEndDate.toString().substring(0, 10)}"),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: _fetchFilterList(),
          ),
        ],
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> _fetchFilterList() {
    return StreamBuilder<QuerySnapshot>(
        stream: _dataSnap,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Recieve Data Has been Error'),
            );
          }
          List<QueryDocumentSnapshot> data = snapshot.data!.docs;
          return ListView.builder(
              shrinkWrap: true,
              itemCount: data.length,
              itemBuilder: (context, index) {
                Map<String, dynamic>? documentData =
                    data[index].data() as Map<String, dynamic>?;
                String name = documentData!['name'];
                String instansi = documentData['instansi'];
                Timestamp timestamp = documentData['tanggal'];
                DateTime date = timestamp.toDate();
                return ListTile(
                  title: Text(name),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(instansi),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Text(
                        'Tanggal: $date',
                        style: const TextStyle(
                            fontSize: 16.0,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              });
        });
  }
}

Stream<QuerySnapshot> getData(DateTime selectedDate) {
  DateTime startDate =
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
  DateTime endDate =
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day + 1);

  return FirebaseFirestore.instance
      .collection('visitor')
      .where('tanggal', isGreaterThanOrEqualTo: startDate)
      .where('tanggal', isLessThan: endDate)
      .orderBy('tanggal', descending: true)
      .snapshots();
}
