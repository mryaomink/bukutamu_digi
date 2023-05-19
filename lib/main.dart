import 'package:buku_tamudigi/pages/yao_input.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: 'AIzaSyC-hMxnqODgctfolgYspQXNMn0N5GPZ9GA',
        appId: '1:417612277147:web:a7a51bc48af076a2ebed3e',
        messagingSenderId: '417612277147',
        projectId: 'bukutamu-diskominfo-31e3c',
        storageBucket: 'bukutamu-diskominfo-31e3c.appspot.com'),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buku Tamu Digital',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.grey,
      ),
      home: const YaoInput(),
    );
  }
}
