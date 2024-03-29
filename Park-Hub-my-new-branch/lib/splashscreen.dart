// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:smartparkin1/signup.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {



  @override
  void initState() {
    super.initState();
    _navigateToWelcomeScreen();
  }

  Future<void> _navigateToWelcomeScreen() async {
    // Add a delay of 2 seconds (adjust as needed)
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SignUpWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: YourWidget(),
    );
  }
}

class YourWidget extends StatelessWidget {
  const YourWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.asset(
              'assets/images/car.jpg',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
