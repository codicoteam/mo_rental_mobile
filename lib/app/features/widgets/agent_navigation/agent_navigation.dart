// lib/app/features/modules/agent/views/agent_navigation.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';

import '../../modules/agent/views/agent_home_screen.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/car_listing/views/car_listing_screen.dart';
import '../../modules/profile/views/profile_screen.dart';
import '../../modules/rate_plans/views/rate_plans_screen.dart';

class AgentNavigation extends StatefulWidget {
  const AgentNavigation({super.key});

  @override
  State<AgentNavigation> createState() => _AgentNavigationState();
}

class _AgentNavigationState extends State<AgentNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final GetStorage _storage = GetStorage();
  final AuthController _authController = Get.find<AuthController>();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Widget> _screens = [
    AgentHomeScreen(),           // Agent Dashboard
    CarListingScreen(),          // Cars
    RatePlansScreen(),           // Rate Plans  
    ProfileScreen(),             // Profile
  ];

  final List<String> _appBarTitles = [
    'Agent Dashboard',
    'Cars',
    'Rate Plans',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _checkAuth();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeOutBack,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  void _checkAuth() {
    if (!_authController.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/login');
        Get.snackbar(
          'Session Expired',
          'Please login again',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.all(20),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = _storage.read('user_data') ?? {};

    return Scaffold(
      backgroundColor: Colors.white,

      // ----------------------
      //      Agent Glass AppBar
      // ----------------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF10B981).withOpacity(0.15), // Emerald green
                const Color(0xFF0EA5E9).withOpacity(0.15), // Sky blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ),
        ),
        title: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _appBarTitles[_currentIndex],
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF10B981),
                    letterSpacing: -0.5,
                  ),
                ),
                if (_currentIndex == 0 && userData['full_name'] != null)
                  const SizedBox(height: 4),
                if (_currentIndex == 0 && userData['full_name'] != null)
                  Text(
                    "Agent ${userData['full_name']}",
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF10B981).withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          if (_currentIndex != 3)
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.1),
                    const Color(0xFF0EA5E9).withOpacity(0.1),
                  ],
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.logout_rounded, color: Color(0xFF10B981)),
                onPressed: () => _authController.logout(),
                splashRadius: 20,
                tooltip: 'Logout',
              ),
            ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),

      // ----------------------
      //         Animated Body
      // ----------------------
      body: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _screens[_currentIndex],
        ),
      ),

      // ----------------------
      //     Agent Glass BottomNav
      // ----------------------
      bottomNavigationBar: Container(
        height: 84,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.grey.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 15,
              spreadRadius: 0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(28),
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: const Color(0xFF10B981),
                unselectedItemColor: Colors.grey.shade600,
                selectedLabelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
                unselectedLabelStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
                showSelectedLabels: true,
                showUnselectedLabels: true,
                type: BottomNavigationBarType.fixed,
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                    _fadeController.forward(from: 0);
                    _slideController.forward(from: 0);
                  });
                },
                items: [
                  BottomNavigationBarItem(
  icon: Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: _currentIndex == 0
          ? const Color(0xFF10B981).withOpacity(0.15)
          : Colors.transparent,
    ),
    child: Icon(
      Iconsax.home, // or Iconsax.home_2
      size: _currentIndex == 0 ? 24 : 22,
      color: _currentIndex == 0
          ? const Color(0xFF10B981)
          : Colors.grey.shade600,
    ),
  ),
  label: "Dashboard",
),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == 1
                            ? const Color(0xFF10B981).withOpacity(0.15)
                            : Colors.transparent,
                      ),
                      child: Icon(
                        Iconsax.car,
                        size: _currentIndex == 1 ? 24 : 22,
                        color: _currentIndex == 1
                            ? const Color(0xFF10B981)
                            : Colors.grey.shade600,
                      ),
                    ),
                    label: "Cars",
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == 2
                            ? const Color(0xFF10B981).withOpacity(0.15)
                            : Colors.transparent,
                      ),
                      child: Icon(
                        Iconsax.money,
                        size: _currentIndex == 2 ? 24 : 22,
                        color: _currentIndex == 2
                            ? const Color(0xFF10B981)
                            : Colors.grey.shade600,
                      ),
                    ),
                    label: "Rates",
                  ),
                  BottomNavigationBarItem(
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == 3
                            ? const Color(0xFF10B981).withOpacity(0.15)
                            : Colors.transparent,
                    ),
                      child: Icon(
                        Iconsax.profile_circle,
                        size: _currentIndex == 3 ? 24 : 22,
                        color: _currentIndex == 3
                            ? const Color(0xFF10B981)
                            : Colors.grey.shade600,
                      ),
                    ),
                    label: "Profile",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}