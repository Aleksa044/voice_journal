import 'package:flutter/material.dart';
import 'speech_to_text.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Journal',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SpeechText(), // početna stranica
      debugShowCheckedModeBanner: false,
    );
  }
}
