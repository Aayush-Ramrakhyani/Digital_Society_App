import 'package:digital_society/LoginPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Digital_Society());
}

class Digital_Society extends StatelessWidget {
  const Digital_Society({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyLoginPage(),
    );
  }
}