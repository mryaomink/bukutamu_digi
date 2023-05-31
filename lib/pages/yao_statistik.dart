import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfWidgets;
import 'package:printing/printing.dart';

class YaoStatistik extends StatefulWidget {
  const YaoStatistik({super.key});

  @override
  State<YaoStatistik> createState() => _YaoStatistikState();
}

class _YaoStatistikState extends State<YaoStatistik> {
  List<DocumentSnapshot> _filteredData = [];
  int _totalDataCount = 0;

  Future<void> filterData(
      {required DateTime startDate, required DateTime endDate}) async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('visitor');
    Timestamp startTime = Timestamp.fromDate(startDate);
    Timestamp endTime = Timestamp.fromDate(endDate);

    Query query = collectionReference
        .where('tanggal', isGreaterThanOrEqualTo: startTime)
        .where('tanggal', isLessThanOrEqualTo: endTime);
    QuerySnapshot querySnapshot = await query.get();
    setState(() {
      _filteredData = querySnapshot.docs;
      _totalDataCount = querySnapshot.size;
    });
  }

  Future<void> generatePdf() async {
    final pdf = pdfWidgets.Document();

    pdf.addPage(
      pdfWidgets.Page(
        build: (context) {
          return pdfWidgets.ListView.builder(
            itemCount: _filteredData.length,
            itemBuilder: (context, index) {
              DocumentSnapshot doc = _filteredData[index];
              return pdfWidgets.Container(
                padding: const pdfWidgets.EdgeInsets.all(10),
                child: pdfWidgets.Column(
                  crossAxisAlignment: pdfWidgets.CrossAxisAlignment.start,
                  children: [
                    pdfWidgets.Text(doc['name']),
                    pdfWidgets.Text(doc['instansi']),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
    final pdfBytes = await pdf.save();
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes);

    // final output = await getTemporaryDirectory();
    // final outputFile = File('${output.path}/filtered_data.pdf');

    // await outputFile.writeAsBytes(await pdf.save());

    // Show the PDF document to the user
    // (You can use any package or method to display the PDF here)
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () {
                generatePdf;
              },
              icon: const Icon(Icons.picture_as_pdf))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardCard(
                title: 'Jumlah Tamu: ',
                value: '$_totalDataCount',
                backgroundColor: Colors.green),
            const SizedBox(
              height: 20,
            ),
            Wrap(
              spacing: 8.0,
              runSpacing: 10.0,
              runAlignment: WrapAlignment.spaceAround,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  onPressed: () {
                    DateTime yesterday =
                        today.subtract(const Duration(days: 1));
                    filterData(startDate: yesterday, endDate: today);
                  },
                  child: const Text('Last Day'),
                ),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: () {
                    DateTime startOfTheDay =
                        DateTime(today.year, today.month, today.day);
                    DateTime lastWeek =
                        startOfTheDay.subtract(const Duration(days: 7));
                    filterData(startDate: lastWeek, endDate: startOfTheDay);
                  },
                  child: const Text('Last Week'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple),
                  onPressed: () {
                    DateTime firstDayOfCurrentMonth =
                        DateTime(today.year, today.month, 1);
                    DateTime lastmonth =
                        DateTime(today.year, today.month - 1, 1);
                    DateTime lastDaysOfTheLastMonth = firstDayOfCurrentMonth
                        .subtract(const Duration(days: 1));
                    filterData(
                        startDate: lastmonth, endDate: lastDaysOfTheLastMonth);
                  },
                  child: const Text('Last Month'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () {
                    DateTime firstDayOfTheYear = DateTime(today.year, 1, 1);
                    DateTime lastYear = DateTime(
                      today.year - 1,
                      1,
                    );
                    DateTime lastDaysOfYear =
                        firstDayOfTheYear.subtract(const Duration(days: 1));
                    filterData(startDate: lastYear, endDate: lastDaysOfYear);
                  },
                  child: const Text('Last Year'),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredData.length,
                physics: const ScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  DocumentSnapshot doc = _filteredData[index];
                  return Card(
                    elevation: 5,
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.supervised_user_circle_rounded),
                      ),
                      title: Text(
                        doc['keperluan'],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc['instansi'],
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            DateFormat('HH:mm:ss')
                                .format(doc['tanggal'].toDate()),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final Color backgroundColor;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
