import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class VisitorData {
  final DateTime date;
  final int count;

  VisitorData(this.date, this.count);
}

class YaoChart extends StatefulWidget {
  const YaoChart({super.key});

  @override
  State<YaoChart> createState() => _YaoChartState();
}

class _YaoChartState extends State<YaoChart> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('visitor').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final documents = snapshot.data!.docs;
          final visitorDataList = documents.map((doc) {
            final date = (doc['tanggal'] as Timestamp).toDate();
            final count = doc['jumlah tamu'] as int;
            return VisitorData(date, count);
          }).toList();
          return Center(
            child: Container(
              margin: const EdgeInsets.all(16.0),
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(),
                series: <ChartSeries>[
                  LineSeries<VisitorData, DateTime>(
                    dataSource: visitorDataList,
                    xValueMapper: (VisitorData data, _) => data.date,
                    yValueMapper: (VisitorData data, _) => data.count,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
