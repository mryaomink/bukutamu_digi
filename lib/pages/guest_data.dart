import 'package:buku_tamudigi/pages/guest_dash.dart';
import 'package:buku_tamudigi/pages/yao_filter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GuestData extends StatefulWidget {
  const GuestData({super.key});

  @override
  State<GuestData> createState() => _GuestDataState();
}

class _GuestDataState extends State<GuestData> {
  late Stream<QuerySnapshot> _dataList;
  @override
  void initState() {
    super.initState();
    _dataList = FirebaseFirestore.instance
        .collection('myguest')
        .orderBy('tanggal', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guest Data"),
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const YaoFilter(),
            const SizedBox(
              height: 20.0,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _dataList,
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
                List<QueryDocumentSnapshot> data = snapshot.data!.docs;
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic>? documentData =
                          data[index].data() as Map<String, dynamic>?;
                      String nama = documentData!['name'];
                      String asal = documentData['instansi'];
                      String img = documentData['imgUrl'];
                      Timestamp timestamp = documentData['tanggal'];
                      DateTime date = timestamp.toDate();
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(nama),
                        ),
                        title: Text(
                          nama,
                          style: const TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                        subtitle: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(asal),
                            Text(
                              date.toString(),
                            ),
                          ],
                        ),
                      );
                    });
              },
            ),
          ],
        ),
      ),
    );
  }
}
