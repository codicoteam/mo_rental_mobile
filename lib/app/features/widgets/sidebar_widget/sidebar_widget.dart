import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_routes.dart';

class SidebarWidget extends StatefulWidget {
  final Widget child;
  final bool initiallyOpen;

  const SidebarWidget({
    super.key,
    required this.child,
    this.initiallyOpen = false,
  });

  @override
  State<SidebarWidget> createState() => _SidebarWidgetState();
}

class _SidebarWidgetState extends State<SidebarWidget>
    with SingleTickerProviderStateMixin {
  final GetStorage storage = GetStorage();
  bool _isSidebarOpen = false;
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<SidebarItem> _sidebarItems = [
    SidebarItem(
      icon: Icons.home_rounded,
      title: 'Home',
      route: '/home',
    ),
    SidebarItem(
      icon: Icons.directions_car_rounded,
      title: 'Vehicle Models',
      route: '/vehicles/models',
    ),
    SidebarItem(
      icon: Icons.local_shipping_rounded,
      title: 'Vehicle Fleet',
      route: '/vehicles/fleet',
    ),
    SidebarItem(
      icon: Icons.drive_eta_rounded,
      title: 'Available Drivers',
      route: '/drivers/public',
    ),
    SidebarItem(
      icon: Icons.person_rounded,
      title: 'My Driver Profile',
      route: '/drivers/my-profile',
    ),
    SidebarItem(
      icon: Icons.business_rounded,
      title: 'Branch Locations',
      route: '/branches',
    ),
    SidebarItem(
      icon: Icons.near_me_rounded,
      title: 'Nearby Branches',
      route: '/branches/nearby',
    ),
    SidebarItem(
      icon: Icons.search_rounded,
      title: 'Check Availability',
      route: '/reservations/availability',
    ),
    SidebarItem(
      icon: Icons.add_circle_rounded,
      title: 'Create Reservation',
      route: '/reservations/create',
    ),
    SidebarItem(
      icon: Icons.calendar_today_rounded,
      title: 'My Bookings',
      route: '/reservations/list',
    ),
    SidebarItem(
      icon: Icons.chat_bubble_rounded,
      title: 'Messages',
      route: '/chat/conversations',
      badgeCount: 0,
    ),
    SidebarItem(
      icon: Icons.local_offer_rounded,
      title: 'Promo Codes',
      route: '/promo-codes',
      badgeCount: 0,
    ),
    SidebarItem(
      icon: Icons.favorite_rounded,
      title: 'Favorites',
      route: '/favorites',
    ),
    SidebarItem(
      icon: Icons.history_rounded,
      title: 'History',
      route: '/history',
    ),
    SidebarItem(
      icon: Icons.payment_rounded,
      title: 'Payments',
      route: '/payments',
    ),
    SidebarItem(
      icon: Icons.settings_rounded,
      title: 'Settings',
      route: '/settings',
    ),
    SidebarItem(
      icon: Icons.help_rounded,
      title: 'Help & Support',
      route: '/support',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _isSidebarOpen = widget.initiallyOpen;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    if (_isSidebarOpen) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
      if (_isSidebarOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final item = _sidebarItems[index];

    _toggleSidebar();

    Future.delayed(const Duration(milliseconds: 200), () {
      _handleNavigation(item);
    });
  }

  void _handleNavigation(SidebarItem item) {
    try {
      switch (item.route) {
        case '/reservations/list':
          Get.toNamed(AppRoutes.reservationList);
          break;
        case '/reservations/detail':
          Get.toNamed(AppRoutes.reservationDetail);
          break;
        case '/reservations/availability':
          Get.toNamed(AppRoutes.checkAvailability);
          break;
        case '/reservations/create':
          Get.toNamed(AppRoutes.createReservation);
          break;
        case '/promo-codes':
          Get.toNamed(AppRoutes.promoCodes);
          break;
        case '/chat/conversations':
          Get.toNamed(AppRoutes.chatConversations);
          break;
        case '/home':
          Get.offAllNamed('/');
          break;
        case '/branches':
          Get.toNamed(AppRoutes.branches);
          break;
        case '/branches/nearby':
          Get.toNamed(AppRoutes.nearbyBranches);
          break;
        case '/vehicles/models':
          Get.toNamed(AppRoutes.vehicleModels);
          break;
        case '/vehicles/fleet':
          Get.toNamed(AppRoutes.vehicleFleet);
          break;
        case '/drivers/public':
          Get.toNamed(AppRoutes.publicDrivers);
          break;
        case '/drivers/my-profile':
          Get.toNamed(AppRoutes.myDriverProfile);
          break;
        case '/favorites':
        case '/history':
        case '/payments':
        case '/settings':
        case '/support':
          Get.snackbar(
            'Coming Soon',
            '${item.title} feature is under development',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
          break;
        default:
          debugPrint('Route not handled: ${item.route}');
          Get.snackbar(
            'Coming Soon',
            '${item.title} feature is under development',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
      }
    } catch (e) {
      debugPrint('❌ Navigation error for ${item.route}: $e');
      Get.snackbar(
        'Navigation Error',
        'Could not load ${item.title}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = storage.read('user_data') ?? {};
    final userName = userData['full_name'] ?? 'Guest';
    final userEmail = userData['email'] ?? 'guest@example.com';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: widget.child,
            ),
          ),

          // Overlay when sidebar is open
          if (_isSidebarOpen)
            GestureDetector(
              onTap: _toggleSidebar,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    color: Colors.black.withOpacity(0.65 * _animation.value),
                  );
                },
              ),
            ),

          // Premium Sidebar
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(-320 * (1 - _animation.value), 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 320,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF047BC1).withOpacity(0.15),
                          blurRadius: 30,
                          spreadRadius: 0,
                          offset: const Offset(8, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Scrollable Content
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Premium Header with Gradient
                                Container(
                                  padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).padding.top + 24,
                                    left: 24,
                                    right: 24,
                                    bottom: 28,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF047BC1),
                                        Color(0xFF4F46E5),
                                        Color(0xFF3730A3),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // Avatar with Premium Ring
                                      Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.9),
                                              Colors.white.withOpacity(0.4),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.4),
                                              blurRadius: 16,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                          ),
                                          child: CircleAvatar(
                                            radius: 42,
                                            backgroundColor: Colors.white,
                                            child: Text(
                                              userName[0].toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF047BC1),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 18),
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: -0.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 7),
                                      Text(
                                        userEmail,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.9),
                                          letterSpacing: 0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 9,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.22),
                                          borderRadius: BorderRadius.circular(22),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.35),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.star_rounded,
                                              size: 17,
                                              color: Colors.amber.shade200,
                                            ),
                                            const SizedBox(width: 7),
                                            const Text(
                                              'Premium Member',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Menu Items
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20,
                                    horizontal: 16,
                                  ),
                                  itemCount: _sidebarItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _sidebarItems[index];
                                    final isSelected = _selectedIndex == index;

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _navigateTo(index),
                                          borderRadius: BorderRadius.circular(16),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              gradient: isSelected
                                                  ? LinearGradient(
                                                      colors: [
                                                        Color(0xFF047BC1).withOpacity(0.15),
                                                        Color(0xFF4F46E5).withOpacity(0.12),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    )
                                                  : null,
                                              borderRadius: BorderRadius.circular(16),
                                              border: isSelected
                                                  ? Border.all(
                                                      color: Color(0xFF047BC1).withOpacity(0.25),
                                                      width: 1.5,
                                                    )
                                                  : null,
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 18,
                                                vertical: 16,
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      gradient: isSelected
                                                          ? LinearGradient(
                                                              colors: [
                                                                Color(0xFF047BC1).withOpacity(0.25),
                                                                Color(0xFF4F46E5).withOpacity(0.2),
                                                              ],
                                                              begin: Alignment.topLeft,
                                                              end: Alignment.bottomRight,
                                                            )
                                                          : null,
                                                      color: isSelected
                                                          ? null
                                                          : Colors.grey.withOpacity(0.08),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Icon(
                                                      item.icon,
                                                      color: isSelected
                                                          ? Color(0xFF047BC1)
                                                          : Colors.grey.shade700,
                                                      size: 23,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 18),
                                                  Expanded(
                                                    child: Text(
                                                      item.title,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w600
                                                            : FontWeight.w500,
                                                        color: isSelected
                                                            ? Color(0xFF047BC1)
                                                            : Color(0xFF1A1A1A),
                                                        letterSpacing: isSelected ? 0.1 : 0,
                                                      ),
                                                    ),
                                                  ),
                                                  if (item.badgeCount != null && item.badgeCount! > 0)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            Color(0xFF047BC1),
                                                            Color(0xFF4F46E5),
                                                          ],
                                                        ),
                                                        borderRadius: BorderRadius.circular(12),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Color(0xFF047BC1).withOpacity(0.3),
                                                            blurRadius: 8,
                                                            offset: Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Text(
                                                        item.badgeCount.toString(),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // Premium Logout Button
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.red.shade50,
                                          Colors.red.shade100.withOpacity(0.5),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.25),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.1),
                                          blurRadius: 12,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          storage.remove('user_data');
                                          storage.remove('auth_token');
                                          Get.offAllNamed('/login');
                                        },
                                        borderRadius: BorderRadius.circular(16),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 18),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.logout_rounded,
                                                color: Colors.red.shade700,
                                                size: 23,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Logout',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.red.shade700,
                                                  letterSpacing: 0.3,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Premium Menu Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF047BC1),
                    Color(0xFF4F46E5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF047BC1).withOpacity(0.35),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleSidebar,
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.all(13),
                    child: AnimatedRotation(
                      turns: _isSidebarOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        _isSidebarOpen ? Icons.close_rounded : Icons.menu_rounded,
                        size: 26,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarItem {
  final IconData icon;
  final String title;
  final String route;
  final int? badgeCount;

  SidebarItem({
    required this.icon,
    required this.title,
    required this.route,
    this.badgeCount,
  });
}