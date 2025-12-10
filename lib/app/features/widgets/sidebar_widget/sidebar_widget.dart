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
        case '/reservations/availability':
          Get.toNamed(AppRoutes.checkAvailability);
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
        case '/reservations/list':
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
        case '/reservations/create':
          Get.toNamed(
            AppRoutes.createReservation,
          );
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

    // Get colors from theme
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final surfaceColor = colorScheme.surface;
    final onSurfaceColor = colorScheme.onSurface;
    final secondaryColor = colorScheme.secondary;

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Positioned.fill(
            child: Container(
              color: Colors.white, // White background
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
                    color: Colors.black.withOpacity(0.6 * _animation.value),
                  );
                },
              ),
            ),

          // Sidebar - Everything scrollable
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(-300 * (1 - _animation.value), 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 300,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: surfaceColor, // Use theme surface color
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(4, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Menu Items with scroll - including header
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // Header (moved here to be scrollable)
                                Container(
                                  padding: const EdgeInsets.only(
                                    top: 20,
                                    left: 20,
                                    right: 20,
                                    bottom: 24,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        primaryColor,
                                        secondaryColor,
                                        primaryColor.withOpacity(0.8),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  primaryColor.withOpacity(0.3),
                                              blurRadius: 10,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 38,
                                          backgroundColor:
                                              Colors.white.withOpacity(0.9),
                                          child: CircleAvatar(
                                            radius: 35,
                                            backgroundColor: Colors.white,
                                            child: Text(
                                              userName[0].toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: primaryColor,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        userName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        userEmail,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 14),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 18,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color:
                                                Colors.white.withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.star_rounded,
                                              size: 16,
                                              color: Colors.amber.shade300,
                                            ),
                                            const SizedBox(width: 6),
                                            const Text(
                                              'Premium Member',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Menu items
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 12,
                                  ),
                                  itemCount: _sidebarItems.length,
                                  itemBuilder: (context, index) {
                                    final item = _sidebarItems[index];
                                    final isSelected = _selectedIndex == index;

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () => _navigateTo(index),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? primaryColor
                                                      .withOpacity(0.15)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 14,
                                              ),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: isSelected
                                                          ? primaryColor
                                                              .withOpacity(0.2)
                                                          : onSurfaceColor
                                                              .withOpacity(
                                                                  0.05),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Icon(
                                                      item.icon,
                                                      color: isSelected
                                                          ? primaryColor
                                                          : onSurfaceColor
                                                              .withOpacity(0.7),
                                                      size: 22,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Text(
                                                      item.title,
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: isSelected
                                                            ? FontWeight.w600
                                                            : FontWeight.w400,
                                                        color: isSelected
                                                            ? primaryColor
                                                            : onSurfaceColor
                                                                .withOpacity(
                                                                    0.8),
                                                      ),
                                                    ),
                                                  ),
                                                  if (item.badgeCount != null &&
                                                      item.badgeCount! > 0)
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10,
                                                        vertical: 5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: primaryColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      child: Text(
                                                        item.badgeCount
                                                            .toString(),
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.bold,
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

                                // Logout Button
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.red.withOpacity(0.1),
                                      border: Border.all(
                                        color: Colors.red.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {
                                          storage.remove('user_data');
                                          storage.remove('auth_token');
                                          Get.offAllNamed('/login');
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.logout_rounded,
                                                color: Colors.red,
                                                size: 22,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Logout',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
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

          // Menu Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleSidebar,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: AnimatedRotation(
                      turns: _isSidebarOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        _isSidebarOpen
                            ? Icons.close_rounded
                            : Icons.menu_rounded,
                        size: 24,
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
