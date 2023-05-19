import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flushbar/flutter_flushbar.dart';
import 'package:google_fonts/google_fonts.dart';

class YaoInput extends StatefulWidget {
  const YaoInput({super.key});

  @override
  State<YaoInput> createState() => _YaoInputState();
}

class _YaoInputState extends State<YaoInput> {
  DateTime _selectedDate = DateTime.now();
  String _name = '';
  String _instansi = '';
  String _keperluan = '';
  String _kontak = '';
  String _ditemui = '';
  String _jumlahTamu = '';
  String _keterangan = '';
  String _url = '';

  final _formKey = GlobalKey<FormState>();

  final storage = FirebaseStorage.instance;
  final database = FirebaseFirestore.instance;
  final ref = FirebaseFirestore.instance.collection('visitor');

  Future<void> _uploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final platformFile = result.files.first;
      final task = storage
          .ref()
          .child('images/${DateTime.now()}.${platformFile.extension}')
          .putData(platformFile.bytes!);
      task.snapshotEvents.listen((event) {
        setState(() {});
      });
      final snapshot = await task.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _url = downloadUrl;
      });
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _formKey.currentState!.save();

    await ref.add({
      'name': _name,
      'instansi': _instansi,
      'keperluan': _keperluan,
      'kontak': _kontak,
      'ditemui': _ditemui,
      'jumlah tamu': _jumlahTamu,
      'keterangan': _keterangan,
      'photoUrl': _url,
    });

    _showSuccessNotification();
    _formKey.currentState!.reset();

    setState(() {
      _name = '';
      _instansi = '';
      _keperluan = '';
      _kontak = '';
      _ditemui = '';
      _jumlahTamu = '';
      _keterangan = '';
      _url = '';
    });
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
        body: CustomScrollView(
      slivers: [
        SliverAppBar(
          flexibleSpace: FlexibleSpaceBar(
            background: Image.network(
              'https://images.unsplash.com/photo-1509343256512-d77a5cb3791b?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80',
              fit: BoxFit.cover,
            ),
          ),
          expandedHeight: 200.0,
          backgroundColor: Colors.grey,
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Tanggal:',
                    style: TextStyle(color: Colors.black),
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
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  const Text(
                    'Jam:',
                    style: TextStyle(color: Colors.black),
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
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nama',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Harap isi Field ini";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _name = value!;
                        },
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Instansi',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Harap isi Field ini";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _instansi = value!;
                        },
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Keperluan',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Harap isi Field ini";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _keperluan = value!;
                        },
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'No.Telp (WA)',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Harap isi Field ini";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _kontak = value!;
                        },
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Yang Ditemui',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Harap isi Field ini";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _ditemui = value!;
                        },
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Tamu',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Harap isi Field ini";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _jumlahTamu = value!;
                        },
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      TextFormField(
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Keterangan',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Harap isi Field ini";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _keterangan = value!;
                        },
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ElevatedButton(
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: Colors.blue,
                          //   ),
                          //   onPressed: _uploadFile,
                          //   child: const Text("Upload File"),
                          // ),
                          InkWell(
                            onTap: _uploadFile,
                            child: _buildBrutalism('Upload File'),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          // OutlinedButton(
                          //   style: OutlinedButton.styleFrom(
                          //     foregroundColor: Colors.black,
                          //     side: const BorderSide(
                          //       color: Colors.black,
                          //     ),
                          //   ),
                          //   onPressed: _saveData,
                          //   child: const Text("Simpan"),
                          // ),

                          InkWell(
                            onTap: _saveData,
                            child: _buildBrutalism('Simpan'),
                          ),
                        ],
                      ),
                      // if (_url.isNotEmpty)
                      //   Image.network(
                      //     _url,
                      //     fit: BoxFit.cover,
                      //     width: 80,
                      //     height: 80,
                      //   ),
                      // LinearProgressIndicator(value: _uploadProgress),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
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
