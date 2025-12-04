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

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final GetStorage _storage = GetStorage();
  final AuthController _authController = Get.find<AuthController>();
  
  // Create instance of RatePlanBinding
  final RatePlanBinding _ratePlanBinding = RatePlanBinding();

  final List<Widget> _screens = [
    HomeScreen(),
    CarListingScreen(),
    RatePlansScreen(),
    ProfileScreen(),
  ];

  // AppBar titles for each tab
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
    
    // Initialize rate plan dependencies when MainNavigation starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 Initializing RatePlan dependencies in MainNavigation');
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
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_appBarTitles[_currentIndex]),
            if (_currentIndex == 0 && userData['full_name'] != null)
              Text(
                "Welcome, ${userData['full_name']}!",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        actions: [
          if (_currentIndex != 3) // Don't show logout on Profile tab (it has its own)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _authController.logout();
              },
              tooltip: 'Logout',
            ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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
    );
  }
}