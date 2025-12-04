// core/themes/app_palette.dart
import 'package:flutter/material.dart';

class AppPalette {
  // Primary Colors from your image
  static const Color primaryBlue = Color(0xFF047BC1);
  static const Color darkBlue = Color(0xFF3C425E);
  static const Color pureWhite = Color(0xFFF9FAFB);
  static const Color softGrey = Color(0xFFA3ABB5);
  
  // Additional Indigo shades for depth
  static const Color indigo = Color(0xFF4F46E5);
  static const Color deepIndigo = Color(0xFF3730A3);
  static const Color lightIndigo = Color(0xFF818CF8);
  
  // Semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Neutral shades
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF94A3B8);
  
  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, indigo],
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF1F5F9),
    ],
  );
  
  // Glassmorphism backgrounds
  static BoxDecoration glassDecoration = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color.fromRGBO(255, 255, 255, 0.1),
        Color.fromRGBO(255, 255, 255, 0.05),
      ],
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration glassCardDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.7),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withOpacity(0.3),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 30,
        offset: const Offset(0, 10),
      ),
    ],
  );
}     
