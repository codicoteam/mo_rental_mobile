import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_routes.dart';

class AgentSidebarWidget extends StatefulWidget {
  final Widget child;
  final bool initiallyOpen;

  const AgentSidebarWidget({
    super.key,
    required this.child,
    this.initiallyOpen = false,
  });

  @override
  State<AgentSidebarWidget> createState() => _AgentSidebarWidgetState();
}

class _AgentSidebarWidgetState extends State<AgentSidebarWidget>
    with SingleTickerProviderStateMixin {
  final GetStorage storage = GetStorage();
  bool _isSidebarOpen = false;
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<SidebarItem> _sidebarItems = [
    SidebarItem(
      icon: Icons.dashboard_rounded,
      title: 'Dashboard',
      route: '/agent/home',
    ),
    SidebarItem(
      icon: Icons.drive_eta_rounded,
      title: 'Manage Drivers',
      route: '/agent/drivers',
    ),
    SidebarItem(
      icon: Icons.directions_car_rounded,
      title: 'Vehicle Inventory',
      route: '/agent/vehicles',
    ),
    SidebarItem(
      icon: Icons.calendar_month_rounded,
      title: 'Reservations',
      route: '/agent/reservations',
    ),
    SidebarItem(
      icon: Icons.business_rounded,
      title: 'My Branch',
      route: '/agent/branch',
    ),
    SidebarItem(
      icon: Icons.receipt_long_rounded,
      title: 'Billing',
      route: '/agent/billing',
    ),
    SidebarItem(
      icon: Icons.analytics_rounded,
      title: 'Analytics',
      route: '/agent/analytics',
    ),
    SidebarItem(
      icon: Icons.support_agent_rounded,
      title: 'Customer Support',
      route: '/agent/support',
    ),
    SidebarItem(
      icon: Icons.settings_rounded,
      title: 'Settings',
      route: '/agent/settings',
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
        case '/agent/home':
          Get.offAllNamed('/agent/home');
          break;
        case '/agent/reservations':
          // Navigate to agent reservations list
          Get.offAllNamed('/agent/reservations');
          break;
        case '/agent/support':
          Get.toNamed(AppRoutes.chatConversations);
          break;
        default:
          // For other routes that aren't implemented yet
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
    final userName = userData['full_name'] ?? 'Agent';
    final userEmail = userData['email'] ?? 'agent@example.com';
    final branchName = userData['branch_name'] ?? 'Main Branch';

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

          // Sidebar
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
                          color: const Color(0xFF10B981).withOpacity(0.15),
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
                                // Header
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
                                        const Color(0xFF10B981),
                                        const Color(0xFF0EA5E9),
                                        const Color(0xFF6366F1),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
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
                                            child: Icon(
                                              Icons.person_outline_rounded,
                                              size: 38,
                                              color: const Color(0xFF10B981),
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
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.35),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.business_rounded,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              branchName,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 12),
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
                                              Icons.verified_rounded,
                                              size: 17,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(width: 7),
                                            const Text(
                                              'Verified Agent',
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
                                                        const Color(0xFF10B981).withOpacity(0.15),
                                                        const Color(0xFF0EA5E9).withOpacity(0.12),
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    )
                                                  : null,
                                              borderRadius: BorderRadius.circular(16),
                                              border: isSelected
                                                  ? Border.all(
                                                      color: const Color(0xFF10B981).withOpacity(0.25),
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
                                                                const Color(0xFF10B981).withOpacity(0.25),
                                                                const Color(0xFF0EA5E9).withOpacity(0.2),
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
                                                          ? const Color(0xFF10B981)
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
                                                            ? const Color(0xFF10B981)
                                                            : const Color(0xFF1A1A1A),
                                                        letterSpacing: isSelected ? 0.1 : 0,
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
                                          offset: const Offset(0, 4),
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

          // Menu Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 12,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981),
                    const Color(0xFF0EA5E9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.35),
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