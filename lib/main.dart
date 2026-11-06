/*
 * main.dart
 *
 * App entry point. Initialises the Flutter binding, locks the device to
 * portrait mode, and bootstraps the MaterialApp with the custom theme.
 * SplashScreen is set as the initial route.
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]); // society app is portrait-only
  runApp(const DigitalSocietyApp());
}

class DigitalSocietyApp extends StatelessWidget {
  const DigitalSocietyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Griha',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
