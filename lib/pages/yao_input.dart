import 'package:buku_tamudigi/pages/yao_chart.dart';
import 'package:buku_tamudigi/pages/yao_statistik.dart';
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

class _YaoInputState extends State<YaoInput> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _uploadController;
  late Animation<double> _animation;
  late Animation<double> _uploadAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _uploadController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _uploadAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _uploadController, curve: Curves.easeInOut),
    );
  }

  void _startButtonAnim(AnimationController controller) {
    controller.reset();
    controller.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _uploadController.dispose();
    super.dispose();
  }

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

  double _uploadProgress = 0.0;
  bool _uploadComplete = false;

  Future<void> _uploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final platformFile = result.files.first;
      final task = storage
          .ref()
          .child('images/${DateTime.now()}.${platformFile.extension}')
          .putData(
            platformFile.bytes!,
          );

      task.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
          if (_uploadProgress == 1.0) {
            _uploadComplete = true;
          }
        });
      });
      final snapshot = await task.whenComplete(() => {});
      if (snapshot.state == TaskState.success) {
        final downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          _url = downloadUrl;
          _uploadComplete = true;
          _uploadProgress = 0.0;
        });
        // ignore: use_build_context_synchronously
        // showDialog(
        //     context: context,
        //     builder: (BuildContext context) {
        //       return AlertDialog(
        //         title: const Center(child: Text('Upload Progress')),
        //         content: const Text('Gambar Berhasil di Upload'),
        //         actions: [
        //           TextButton(
        //             onPressed: () {
        //               Navigator.pop(context);
        //             },
        //             child: Text('Ok'),
        //           ),
        //         ],
        //       );
        //     });
        // ignore: use_build_context_synchronously
        Flushbar(
          flushbarPosition: FlushbarPosition.TOP,
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          titleText: Text("Gambar Berhasil Di Upload",
              style:
                  GoogleFonts.spaceGrotesk(fontSize: 20, color: Colors.white)),
          messageText: Text("Upload Gambar Sukses",
              style:
                  GoogleFonts.spaceGrotesk(fontSize: 16, color: Colors.white)),
        ).show(context);
      }
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
      'tanggal': _selectedDate,
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
      _selectedDate;
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
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Tanggal:',
                      style: GoogleFonts.spaceGrotesk(color: Colors.black),
                    ),
                    Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year},',
                        style: GoogleFonts.spaceGrotesk(color: Colors.black)),
                    const SizedBox(
                      width: 8.0,
                    ),
                    Text(
                      'Jam:',
                      style: GoogleFonts.spaceGrotesk(color: Colors.black),
                    ),
                    Text(
                      '${_selectedDate.hour}:${_selectedDate.minute}',
                      style: GoogleFonts.spaceGrotesk(color: Colors.black),
                    ),
                  ],
                ),
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
                          border: OutlineInputBorder(),
                          labelText: 'Nama',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
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
                          border: OutlineInputBorder(),
                          labelText: 'Instansi',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
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
                          border: OutlineInputBorder(),
                          labelText: 'Keperluan',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
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
                          border: OutlineInputBorder(),
                          labelText: 'No.Telp (WA)',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
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
                          border: OutlineInputBorder(),
                          labelText: 'Yang Ditemui',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
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
                          border: OutlineInputBorder(),
                          labelText: 'Jumlah Tamu',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
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
                          border: OutlineInputBorder(),
                          labelText: 'Keterangan',
                          labelStyle: TextStyle(
                            color: Colors.blueGrey,
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
                          AnimatedBuilder(
                              animation: _uploadAnimation,
                              builder: (BuildContext context, Widget? child) {
                                return GestureDetector(
                                  onTapDown: (_) =>
                                      _startButtonAnim(_uploadController),
                                  onTap: () {
                                    _uploadFile();
                                    _uploadController.reverse();
                                  },
                                  child: Transform.scale(
                                    scale: _uploadAnimation.value,
                                    child: _buildBrutalism('Upload file'),
                                  ),
                                );
                              }),
                          const SizedBox(
                            height: 16.0,
                          ),
                          _buildUploadProgress(),
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

                          // InkWell(
                          //   onTap: _saveData,
                          //   child: _buildBrutalism('Simpan'),
                          // ),
                          AnimatedBuilder(
                              animation: _animation,
                              builder: (BuildContext context, Widget? child) {
                                return GestureDetector(
                                  onTapDown: (_) =>
                                      _startButtonAnim(_animationController),
                                  onTap: () {
                                    _animationController.reverse();
                                    _saveData();
                                  },
                                  child: Transform.scale(
                                    scale: _animation.value,
                                    child: _buildBrutalism('Simpan'),
                                  ),
                                );
                              }),
                          const SizedBox(
                            height: 20.0,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const YaoStatistik(),
                                ),
                              );
                            },
                            child: _buildBrutalism('Dashboard'),
                          ),
                          const SizedBox(
                            height: 20.0,
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

  Widget _buildUploadProgress() {
    if (_uploadComplete) {
      return Text(
        'Upload Berhasil',
        style: GoogleFonts.spaceGrotesk(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      return LinearProgressIndicator(
        minHeight: 8,
        value: _uploadProgress,
        color: Colors.greenAccent,
      );
    }
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
