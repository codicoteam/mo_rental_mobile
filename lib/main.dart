// main.dart
import 'package:flutter/material.dart';
import 'features/agent/checkout/checkout_screen.dart';
import 'features/agent/views/agent_dashboard.dart';
import 'features/auth/views/agent_auth_screen.dart';
import 'features/onboarding/views/onboarding_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mo_Rental',
      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.light(primary: Colors.blue),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => OnboardingScreen(),
        '/agent-auth': (context) => AgentAuthScreen(),
        '/agent-dashboard': (context) => AgentDashboard(),
        '/checkout': (context) => CheckoutScreen(
          bookingId: 'BK001',
          customerName: 'John Doe',
          vehicleInfo: 'Toyota Corolla - ABC123',
        ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}