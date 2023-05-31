import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// ignore: library_prefixes
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

  Future<void> reportPdf(List<DocumentSnapshot> data) async {
    final pdf = pdfWidgets.Document();
    final font = await PdfGoogleFonts.nunitoExtraLight();
    pdf.addPage(
      pdfWidgets.Page(
        build: (pdfWidgets.Context context) {
          return pdfWidgets.Center(
            child: pdfWidgets.Text('Buku Tamu Report',
                style: pdfWidgets.TextStyle(font: font)),
          );
        },
      ),
    );
    pdf.addPage(
      pdfWidgets.Page(
        build: (pdfWidgets.Context context) {
          return pdfWidgets.Center(
            // ignore: deprecated_member_use
            child: pdfWidgets.Table.fromTextArray(
              headerStyle: pdfWidgets.TextStyle(
                fontWeight: pdfWidgets.FontWeight.bold,
              ),
              cellAlignment: pdfWidgets.Alignment.center,
              data: [
                ['Tanggal', 'Nama', 'Instansi', 'No.Telp'],
                ...data.map(
                  (snapshot) => [
                    snapshot['tanggal'].toDate().toString(),
                    snapshot['name'].toString(),
                    snapshot['instansi'].toString(),
                    snapshot['kontak'].toString(),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    final pdfBytes = await pdf.save();

    // Create a blob from the PDF bytes
    final blob = html.Blob([pdfBytes], 'application/pdf');

    // Create a download URL
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create a download anchor element
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = 'guest_book_report.pdf';

    // Append the anchor element to the body
    html.document.body!.children.add(anchor);

    // Trigger a click event on the anchor element
    anchor.click();

    // Remove the anchor element from the body
    html.document.body!.children.remove(anchor);

    // Revoke the download URL
    html.Url.revokeObjectUrl(url);
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
                reportPdf(_filteredData);
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
                        doc['name'],
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
                          const SizedBox(height: 8.0),
                          // Text(
                          //   doc['kontak'],
                          //   style: const TextStyle(color: Colors.lightBlue),
                          // ),
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
