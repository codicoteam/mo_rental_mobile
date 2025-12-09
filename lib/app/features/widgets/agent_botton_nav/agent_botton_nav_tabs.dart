import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../modules/agent/views/agent_home_screen.dart';
import '../../modules/auth/controllers/auth_controller.dart';
import '../../modules/bindings/rate_plan_binding.dart';
import '../../modules/car_listing/views/car_listing_screen.dart';
import '../../modules/profile/views/profile_screen.dart';
import '../../modules/rate_plans/views/rate_plans_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final GetStorage _storage = GetStorage();
  final AuthController _authController = Get.find<AuthController>();
  final RatePlanBinding _ratePlanBinding = RatePlanBinding();

  late AnimationController _fadeController;

  final List<Widget> _screens = [
    HomeScreen(),
    CarListingScreen(),
    RatePlansScreen(),
    ProfileScreen(),
  ];

  final List<String> _appBarTitles = [
    'Home',
    'Cars',
    'Rate Plans',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _checkAuth();

    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
          ..forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ratePlanBinding.dependencies();
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
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = _storage.read('user_data') ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),

      // ----------------------
      //      Modern AppBar
      // ----------------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF047BC1).withOpacity(0.3),
                const Color(0xFF4F46E5).withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF047BC1).withOpacity(0.2),
                blurRadius: 12,
              )
            ],
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _appBarTitles[_currentIndex],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            if (_currentIndex == 0 && userData['full_name'] != null)
              Text(
                "Welcome, ${userData['full_name']}!",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
        actions: [
          if (_currentIndex != 3)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _authController.logout(),
            ),
        ],
      ),

      // ----------------------
      //         BODY
      // ----------------------
      body: FadeTransition(
        opacity: _fadeController,
        child: _screens[_currentIndex],
      ),

      // ----------------------
      //     Glass BottomNav
      // ----------------------
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.25),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF047BC1).withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFF047BC1),
              unselectedItemColor: Colors.white70,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                  _fadeController.forward(from: 0);
                });
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.directions_car),
                  label: "Cars",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.monetization_on),
                  label: "Rates",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
