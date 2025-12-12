import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // Logo fade and scale animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Shimmer animation
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _logoController.forward();

    Timer(const Duration(seconds: 90), () {
      Get.offNamed(AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Custom painted background
          CustomPaint(
            painter: EconetBackgroundPainter(),
            child: Container(),
          ),

          // Animated gradient overlay
          AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF047BC1).withOpacity(0.1),
                      const Color(0xFF4F46E5).withOpacity(0.05),
                      const Color(0xFF3730A3).withOpacity(0.1),
                    ],
                    stops: [
                      (_shimmerAnimation.value - 1).clamp(0.0, 1.0),
                      _shimmerAnimation.value.clamp(0.0, 1.0),
                      (_shimmerAnimation.value + 1).clamp(0.0, 1.0),
                    ],
                  ),
                ),
              );
            },
          ),

          // Main content
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([_logoController, _pulseController]),
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo container with glassmorphism
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF047BC1).withOpacity(0.3),
                                blurRadius: 60,
                                spreadRadius: 20,
                              ),
                              BoxShadow(
                                color: const Color(0xFF4F46E5).withOpacity(0.2),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFF047BC1)
                                            .withOpacity(0.3),
                                        const Color(0xFF4F46E5)
                                            .withOpacity(0.2),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Image.asset(
                                    'assets/images/imaage(1).png',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 48),

                        // App name with shimmer effect
                        Stack(
                          children: [
                            // Shadow text
                            Text(
                              "MO_RENTAL",
                              style: TextStyle(
                                color: Colors.black.withOpacity(0.3),
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3.0,
                              ),
                            ),
                            // Main text with gradient
                            ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: [
                                    Colors.white,
                                    Colors.white.withOpacity(0.95),
                                    Colors.white,
                                  ],
                                ).createShader(bounds);
                              },
                              child: const Text(
                                "MO_RENTAL",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 3.0,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Tagline
                        Text(
                          "Your Journey Starts Here",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.2,
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Loading indicator
                        SizedBox(
                          width: 200,
                          child: Column(
                            children: [
                              // Animated loading bar
                              AnimatedBuilder(
                                animation: _shimmerController,
                                builder: (context, child) {
                                  return Container(
                                    height: 3,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Colors.white.withOpacity(0.1),
                                          Colors.white.withOpacity(0.6),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                        stops: [
                                          (_shimmerAnimation.value - 0.5)
                                              .clamp(0.0, 1.0),
                                          _shimmerAnimation.value
                                              .clamp(0.0, 1.0),
                                          (_shimmerAnimation.value + 0.5)
                                              .clamp(0.0, 1.0),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 16),

                              // Loading text
                              Text(
                                "Loading...",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom branding
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF047BC1),
                                    Color(0xFF4F46E5),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF047BC1)
                                        .withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Powered by Codico Solutions",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Version 1.0.0",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

///----------------------
///   CUSTOM BACKGROUND
///----------------------
class EconetBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Deep Econet-style blue background
    paint.color = const Color(0xFF001A72);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Concentric circular rings
    paint
      ..color = Colors.white.withOpacity(0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const int ringCount = 12;
    final Offset center = Offset(size.width * 0.7, size.height * 0.45);
    final double maxRadius = size.width * 0.9;

    for (int i = 1; i <= ringCount; i++) {
      canvas.drawCircle(center, (maxRadius / ringCount) * i, paint);
    }

    // Faded corner circle (top-left)
    paint
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.06);
    canvas.drawCircle(
        Offset(size.width * 0.1, size.height * 0.1), size.width * 0.25, paint);

    // Faded corner circle (bottom-right)
    canvas.drawCircle(
        Offset(size.width * 0.9, size.height * 0.95), size.width * 0.35, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
