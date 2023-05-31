import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataFilteringPage extends StatefulWidget {
  @override
  _DataFilteringPageState createState() => _DataFilteringPageState();
}

class _DataFilteringPageState extends State<DataFilteringPage> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Filtering'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Text('Start Date:'),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    _selectStartDate(context);
                  },
                  child: Text(
                      _startDate != null ? _formatDate(_startDate!) : 'Select'),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text('End Date:'),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    _selectEndDate(context);
                  },
                  child: Text(
                      _endDate != null ? _formatDate(_endDate!) : 'Select'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _filterData();
              },
              child: Text('Filter'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _buildQuery().snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final documents = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      final data = documents[index];
                      return ListTile(
                        title: Text(data['name']),
                        subtitle: Text(data['instansi']),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2025),
    );
    if (pickedDate != null) {
      setState(() {
        _endDate = pickedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Query _buildQuery() {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('visitor');
    Query query = collectionRef.orderBy('timestamp', descending: true);

    if (_startDate != null && _endDate != null) {
      query = query
          .where('timestamp', isGreaterThanOrEqualTo: _startDate)
          .where('timestamp', isLessThanOrEqualTo: _endDate);
    }

    return query;
  }

  void _filterData() {
    setState(() {});
  }
}
