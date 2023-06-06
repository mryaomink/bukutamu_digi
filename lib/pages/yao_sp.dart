import 'dart:ui';

import 'package:buku_tamudigi/pages/yao_input.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rive/rive.dart';

class YaoSp extends StatefulWidget {
  const YaoSp({super.key});

  @override
  State<YaoSp> createState() => _YaoSpState();
}

class _YaoSpState extends State<YaoSp> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
          context,
          (MaterialPageRoute(
            builder: (context) => const YaoInput(),
          )));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        alignment: Alignment.center,
        children: [
          const RiveAnimation.asset('assets/images/spyao.riv',
              fit: BoxFit.cover),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40.0, sigmaY: 40.0),
            ),
          ),
          Text(
            "Selamat Datang Di Aplikasi\nBuku Tamu Digital\nDiskominfo Kota Banjarbaru",
            style: GoogleFonts.poppins(
                height: 1.4,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22.0),
          )
        ],
      ),
    );
  }
}
