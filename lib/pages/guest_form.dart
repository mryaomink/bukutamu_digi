import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter_flushbar/flutter_flushbar.dart';
import 'package:google_fonts/google_fonts.dart';

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
      duration: const Duration(seconds: 6),
      titleText: Text("Data Berhasil Disimpan",
          style: GoogleFonts.spaceGrotesk(fontSize: 20, color: Colors.white)),
      messageText: Text(
          "Terima Kasih Atas kunjungannya,Semoga Hari anda Menyenangkan",
          style: GoogleFonts.spaceGrotesk(fontSize: 16, color: Colors.white)),
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        elevation: 7,
        backgroundColor: Colors.grey,
        title: Text(
          "Buku Tamu",
          style: GoogleFonts.spaceGrotesk(),
        ),
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Tanggal:',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2023),
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
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year},',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const Text(
                    'Jam:',
                    style: TextStyle(color: Colors.white),
                  ),
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
                      style: const TextStyle(color: Colors.white),
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
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 4,
                        ),
                      ),
                      labelText: 'Nama',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  )),
              Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(),
                  child: TextField(
                    controller: instansiC,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 4,
                        ),
                      ),
                      labelText: 'Instansi',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  )),
              Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(),
                  child: TextField(
                    controller: keperluanC,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 4, style: BorderStyle.solid),
                      ),
                      labelText: 'Keperluan',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  )),
              Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(),
                  child: TextField(
                    controller: kontakC,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 4,
                        ),
                      ),
                      labelText: 'Kontak',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  )),
              Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(),
                  child: TextField(
                    controller: ditemuiC,
                    decoration: const InputDecoration(
                        labelText: 'Yang Ditemui',
                        labelStyle: TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 4,
                          ),
                        )),
                  )),
              Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(),
                  child: TextField(
                    controller: jumlahC,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 4,
                        ),
                      ),
                      labelText: 'Jumlah Tamu',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  )),
              Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(),
                  child: TextField(
                    maxLines: 2,
                    controller: keteranganC,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                        width: 4,
                      )),
                      labelText: 'Keterangan',
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  )),
              const SizedBox(
                height: 20.0,
              ),
              // ElevatedButton(
              //   onPressed: ambilGambar,
              //   child: const Text('Pilih File'),
              // ),
              // const SizedBox(
              //   height: 20.0,
              // ),
              InkWell(
                onTap: ambilGambar,
                child: _buildBrutalism('Pilih File'),
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
              // SizedBox(
              //   width: double.infinity,
              //   height: 50.0,
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.green,
              //     ),
              //     onPressed: simpan,
              //     child: const Text("Simpan"),
              //   ),
              // ),
              InkWell(
                onTap: simpan,
                child: _buildBrutalism('Simpan'),
              ),
              const SizedBox(
                height: 20.0,
              ),
              // SizedBox(
              //   width: double.infinity,
              //   height: 50.0,
              //   child: ElevatedButton(
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.blueGrey,
              //     ),
              //     onPressed: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => const YaoFilter(),
              //         ),
              //       );
              //     },
              //     child: const Text("Tampilkan Data"),
              //   ),
              // ),
              _buildBrutalism('Lihat Data'),
              const SizedBox(
                height: 20.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrutalism(final String judul) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20.0),
          bottomLeft: Radius.circular(20.0),
        ),
        boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(7, 7))],
        border: Border.all(color: Colors.black, width: 4),
      ),
      child: Text(
        judul,
        style: GoogleFonts.spaceGrotesk(fontSize: 16.0),
      ),
    );
  }
}
