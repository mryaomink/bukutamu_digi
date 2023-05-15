import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';

class YaoInput extends StatefulWidget {
  const YaoInput({super.key});

  @override
  State<YaoInput> createState() => _YaoInputState();
}

class _YaoInputState extends State<YaoInput> {
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
    final imageFile = await ImagePickerWeb.getImageInfo;
    final task = storage
        .ref()
        .child('images/${DateTime.now()}.jpg')
        .putData(imageFile!.data!);
    task.snapshotEvents.listen((event) {
      final progress = event.bytesTransferred / event.totalBytes;
      setState(() {});
    });
    final snapshot = await task.whenComplete(() => {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      _url = downloadUrl;
    });
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

    print('Data saved successfully');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
      slivers: [
        const SliverAppBar(
          expandedHeight: 200.0,
          backgroundColor: Color(0xff244CDB),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                ),
                                onPressed: _uploadFile,
                                child: const Text("Upload File"),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  side: const BorderSide(
                                    color: Colors.black,
                                  ),
                                ),
                                onPressed: _saveData,
                                child: const Text("Simpan"),
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
