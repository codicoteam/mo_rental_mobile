import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../routes/app_routes.dart';
import '../../../../widgets/onboardpage_widget/onboardpage_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController controller = PageController();
  int currentPage = 0;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  
  final pages = [
    OnboardPage(
        title: "",
        subtitle: "Rent any car fast and easy",
        image: "assets/images/onboarding1.jpg"),
    OnboardPage(
        title: "",
        subtitle: "Best rental prices in your area",
        image: "assets/images/a5e4711f-153e-4c25-a526-97f6aaa25b80.jpg"),
    OnboardPage(
        title: "",
        subtitle: "",
        image: "assets/images/onboarding44.jpeg"),
    OnboardPage(
        title: "",
        subtitle: "Create your account now",
        image: "assets/images/image(2).jpg"),
  ];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PAGE VIEW
          PageView.builder(
            controller: controller,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() => currentPage = index);
              _fadeController.reset();
              _fadeController.forward();
            },
            itemBuilder: (context, i) => pages[i],
          ),
          
          // ENHANCED GRADIENT OVERLAY - Multi-layered for depth
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 350,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),
          
          // Subtle gradient from top for skip button visibility
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // DOT INDICATORS - Enhanced with brand colors and animations
          Positioned(
            bottom: 130,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    height: currentPage == i ? 12 : 10,
                    width: currentPage == i ? 36 : 10,
                    decoration: BoxDecoration(
                      gradient: currentPage == i
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF047BC1),
                                Color(0xFF4F46E5),
                              ],
                            )
                          : null,
                      color: currentPage == i ? null : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: currentPage == i
                          ? [
                              BoxShadow(
                                color: const Color(0xFF047BC1).withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // NEXT / GET STARTED BUTTON - Glassmorphic with brand colors
          Positioned(
            bottom: 40,
            right: 24,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: () {
                  if (currentPage == pages.length - 1) {
                    Get.offNamed(AppRoutes.login);
                  } else {
                    controller.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: currentPage == pages.length - 1 ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF047BC1).withOpacity(0.9),
                              const Color(0xFF4F46E5).withOpacity(0.9),
                            ],
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF047BC1).withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 3,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                            ),
                            child: Center(
                              child: currentPage == pages.length - 1
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    )
                                  : const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // SKIP BUTTON - Glassmorphic with brand colors
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.25),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Get.offNamed(AppRoutes.login);
                    },
                    borderRadius: BorderRadius.circular(24),
                    splashColor: const Color(0xFF047BC1).withOpacity(0.2),
                    highlightColor: const Color(0xFF047BC1).withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentPage == pages.length - 1 ? "Done" : "Skip",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            currentPage == pages.length - 1
                                ? Icons.check_circle_outline_rounded
                                : Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // PAGE COUNTER - Minimalist design
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.25),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
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
                            color: const Color(0xFF047BC1).withOpacity(0.6),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${currentPage + 1}/${pages.length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // SWIPE HINT - Enhanced with animation
          if (currentPage == 0)
            Positioned(
              bottom: 200,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: currentPage == 0 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.1,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.08),
                              Colors.white.withOpacity(0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swipe_rounded,
                              color: Colors.white.withOpacity(0.9),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Swipe to explore",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white.withOpacity(0.9),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          
          // DECORATIVE ELEMENTS - Subtle brand color accents
          Positioned(
            bottom: 80,
            left: 24,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF047BC1),
                      Color(0xFF4F46E5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF047BC1).withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}