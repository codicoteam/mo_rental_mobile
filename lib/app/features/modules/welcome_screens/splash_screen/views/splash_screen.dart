import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 30), () { // Changed from 30 to 3 seconds
      // Navigate to onboarding screen and remove splash from stack
      Get.offNamed(AppRoutes.onboarding);
    });
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.asset(
          'assets/images/onboarding.jpeg',
          fit: BoxFit.cover, // This makes image cover entire screen
        ),
      ),
    );
  }
}
