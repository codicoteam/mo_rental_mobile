import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../modules/promo_code/views/promo_code_screen.dart';

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

class _SidebarWidgetState extends State<SidebarWidget> {
  final GetStorage storage = GetStorage();
  bool _isSidebarOpen = false;
  int _selectedIndex = 0;

  final List<SidebarItem> _sidebarItems = [
    SidebarItem(
      icon: Icons.home,
      title: 'Home',
      route: '/home',
    ),
    SidebarItem(
      icon: Icons.local_offer,
      title: 'Promo Codes',
      route: '/promo-codes',
      badgeCount: 0,
    ),
    SidebarItem(
      icon: Icons.car_rental,
      title: 'My Bookings',
      route: '/bookings',
    ),
    SidebarItem(
      icon: Icons.favorite,
      title: 'Favorites',
      route: '/favorites',
    ),
    SidebarItem(
      icon: Icons.history,
      title: 'History',
      route: '/history',
    ),
    SidebarItem(
      icon: Icons.payment,
      title: 'Payments',
      route: '/payments',
    ),
    SidebarItem(
      icon: Icons.settings,
      title: 'Settings',
      route: '/settings',
    ),
    SidebarItem(
      icon: Icons.help,
      title: 'Help & Support',
      route: '/support',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _isSidebarOpen = widget.initiallyOpen;
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  void _navigateTo(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final item = _sidebarItems[index];
    
    if (item.route == '/promo-codes') {
      // Navigate to PromoCodeScreen
      Get.to(() => const PromoCodeScreen());
    } else if (item.route == '/home') {
      // If already on home, just close sidebar
      _toggleSidebar();
    } else {
      // Handle other routes
      Get.snackbar(
        'Coming Soon',
        '${item.title} feature is under development',
        snackPosition: SnackPosition.BOTTOM,
      );
      _toggleSidebar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = storage.read('user_data') ?? {};
    final userName = userData['full_name'] ?? 'Guest';
    final userEmail = userData['email'] ?? 'guest@example.com';

    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          Positioned.fill(
            child: widget.child,
          ),

          // Sidebar Overlay
          if (_isSidebarOpen)
            GestureDetector(
              onTap: _toggleSidebar,
              child: Container(
                color: Colors.black.withOpacity(0.5),
              ),
            ),

          // Sidebar Drawer
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: _isSidebarOpen ? 0 : -280,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 280,
              child: Drawer(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // User Profile Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue,
                              child: Text(
                                userName[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userEmail,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'Premium Member',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Menu Items
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          itemCount: _sidebarItems.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = _sidebarItems[index];
                            final isSelected = _selectedIndex == index;

                            return ListTile(
                              leading: Icon(
                                item.icon,
                                color: isSelected
                                    ? Colors.blue
                                    : Colors.grey.shade700,
                              ),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.black,
                                ),
                              ),
                              trailing: item.badgeCount != null &&
                                      item.badgeCount! > 0
                                  ? Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        item.badgeCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  : null,
                              onTap: () => _navigateTo(index),
                              tileColor: isSelected
                                  ? Colors.blue.shade50
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            );
                          },
                        ),
                      ),

                      // Promo Code Special Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.local_offer,
                                  color: Colors.orange.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Active Promo Codes',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                _toggleSidebar();
                                Get.to(() => const PromoCodeScreen());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade600,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                minimumSize: const Size(double.infinity, 40),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.visibility, size: 16),
                                  SizedBox(width: 8),
                                  Text('View All Promo Codes'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Logout Button
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            storage.remove('user_data');
                            storage.remove('auth_token');
                            Get.offAllNamed('/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            minimumSize: const Size(double.infinity, 50),
                            side: BorderSide(color: Colors.red.shade200),
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text('Logout'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Sidebar Toggle Button (Hamburger Menu)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 10,
            child: IconButton(
              onPressed: _toggleSidebar,
              icon: Icon(
                _isSidebarOpen ? Icons.close : Icons.menu,
                size: 28,
                color: Colors.blue,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 3,
                padding: const EdgeInsets.all(8),
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