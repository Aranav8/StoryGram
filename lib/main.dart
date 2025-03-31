import 'package:collabwrite/views/home/home_screen.dart';
import 'package:collabwrite/views/splash/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(nextScreen: HomeScreen()),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
