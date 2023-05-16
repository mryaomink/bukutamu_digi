import 'package:buku_tamudigi/pages/guest_data.dart';
import 'package:buku_tamudigi/pages/yao_filter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter_flushbar/flutter_flushbar.dart';

Future<void> simpanData(String nama, imgUrl, instansi, keperluan, kontak,
    ditemui, jumlah, keterangan, DateTime tanggal) async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  DocumentReference myRef = firestore.collection('myguest').doc();
  await myRef.set(
    {
      'name': nama,
      'imgUrl': imgUrl,
      'instansi': instansi,
      'keperluan': keperluan,
      'No.Telp': kontak,
      'ditemui': ditemui,
      'jumlah tamu': jumlah,
      'keterangan': keterangan,
      'tanggal': Timestamp.fromDate(tanggal),
    },
  );
}

Future<String> uploadImage(html.File imgFile) async {
  FirebaseStorage storage = FirebaseStorage.instance;
  Reference ref = storage.ref().child('gambar/${DateTime.now().toString()}');
  UploadTask uploadTask = ref.putBlob(imgFile);
  TaskSnapshot taskSnapshot = await uploadTask;
  String imgUrl = await taskSnapshot.ref.getDownloadURL();
  return imgUrl;
}

class GuestForm extends StatefulWidget {
  const GuestForm({super.key});

  @override
  State<GuestForm> createState() => _GuestFormState();
}

class _GuestFormState extends State<GuestForm> {
  html.File? _imageFile;
  TextEditingController namaC = TextEditingController();
  TextEditingController instansiC = TextEditingController();
  TextEditingController keperluanC = TextEditingController();
  TextEditingController kontakC = TextEditingController();
  TextEditingController ditemuiC = TextEditingController();
  TextEditingController jumlahC = TextEditingController();
  TextEditingController keteranganC = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  Future<void> ambilGambar() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files!.first;
      setState(() {
        _imageFile = file;
      });
    });
  }

  Future<void> simpan() async {
    String nama = namaC.text;
    String instansi = instansiC.text;
    String keperluan = keperluanC.text;
    String kontak = kontakC.text;
    String ditemui = ditemuiC.text;
    String jumlah = jumlahC.text;
    String keterangan = keteranganC.text;
    String imgUrl = await uploadImage(_imageFile!);
    await simpanData(nama, imgUrl, instansi, keperluan, kontak, ditemui, jumlah,
        keterangan, _selectedDate);
    namaC.clear();
    instansiC.clear();
    keperluanC.clear();
    kontakC.clear();
    ditemuiC.clear();
    jumlahC.clear();
    keteranganC.clear();

    setState(() {
      _imageFile = null;
    });
    _showSuccessNotification();
  }

  void _showSuccessNotification() {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 3),
      titleText: const Text(
        "Data Berhasil Disimpan",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: Colors.white,
            fontFamily: "ShadowsIntoLightTwo"),
      ),
      messageText: const Text(
        "Terima Kasih Atas kunjungannya,Semoga Hari anda Menyenangkan",
        style: TextStyle(
            fontSize: 16.0,
            color: Colors.white,
            fontFamily: "ShadowsIntoLightTwo"),
      ),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Guest CRUD"),
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('Tanggal:'),
                  const SizedBox(width: 16.0),
                  TextButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = DateTime(
                            picked.year,
                            picked.month,
                            picked.day,
                            _selectedDate.hour,
                            _selectedDate.minute,
                          );
                        });
                      }
                    },
                    child: Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                  ),
                  const Text('Jam:'),
                  const SizedBox(width: 16.0),
                  TextButton(
                    onPressed: () async {
                      TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_selectedDate),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            picked.hour,
                            picked.minute,
                          );
                        });
                      }
                    },
                    child: Text(
                      '${_selectedDate.hour}:${_selectedDate.minute}',
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(),
                  child: TextField(
                    controller: namaC,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                    ),
                  )),
              Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(),
                  child: TextField(
                    controller: instansiC,
                    decoration: const InputDecoration(
                      labelText: 'Instansi',
                    ),
                  )),
              Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(),
                  child: TextField(
                    controller: keperluanC,
                    decoration: const InputDecoration(
                      labelText: 'Keperluan',
                    ),
                  )),
              Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(),
                  child: TextField(
                    controller: kontakC,
                    decoration: const InputDecoration(
                      labelText: 'Kontak',
                    ),
                  )),
              Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(),
                  child: TextField(
                    controller: ditemuiC,
                    decoration: const InputDecoration(
                      labelText: 'Yang Ditemui',
                    ),
                  )),
              Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(),
                  child: TextField(
                    controller: jumlahC,
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Tamu',
                    ),
                  )),
              Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(),
                  child: TextField(
                    controller: keteranganC,
                    decoration: const InputDecoration(
                      labelText: 'Keterangan',
                    ),
                  )),
              const SizedBox(
                height: 20.0,
              ),
              ElevatedButton(
                onPressed: ambilGambar,
                child: const Text('Pilih File'),
              ),
              const SizedBox(
                height: 20.0,
              ),
              _imageFile != null
                  ? Image.network(html.Url.createObjectUrlFromBlob(_imageFile!))
                  : const Placeholder(
                      fallbackHeight: 200.0,
                    ),
              const SizedBox(
                height: 16.0,
              ),
              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: simpan,
                  child: const Text("Simpan"),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              SizedBox(
                width: double.infinity,
                height: 50.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const YaoFilter(),
                      ),
                    );
                  },
                  child: const Text("Tampilkan Data"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
