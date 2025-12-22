import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../routes/app_routes.dart';
import '../../../data/services/rate_plan_service.dart';
import '../../../widgets/agent_sidebar/agent_sidebar_widget.dart';
import '../../chat/views/conversations_list_screen.dart';
import '../../rate_plans/controllers/rate_plan_controller.dart';

class AgentHomeScreen extends StatelessWidget {
  const AgentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isRegistered<RatePlanService>()) {
        Get.put(RatePlanService());
      }
      if (!Get.isRegistered<RatePlanController>()) {
        Get.put(RatePlanController());
      }
    });

    return AgentSidebarWidget(
      initiallyOpen: false,
      child: _HomeContent(),
    );
  }
}

class _HomeContent extends StatelessWidget {
  _HomeContent();

  final GetStorage storage = GetStorage();

  // Method to get notification route
  String _getNotificationRoute() {
    final userData = storage.read('user_data') ?? {};
    final roles = userData['roles'] as List<dynamic>? ?? [];
    final isAgent = roles.any((role) => role.toString().contains('agent'));
    
    return isAgent 
        ? AppRoutes.agentNotifications 
        : AppRoutes.customerNotifications;
  }

  // MODIFIED: Agent-specific navigation items WITH NOTIFICATION
  final List<HomeNavItem> _navItems = [
    HomeNavItem(
      icon: Iconsax.driver,
      title: 'Manage Drivers',
      route: '/agent/drivers',
      color: Color(0xFF10B981),
      gradient: [Color(0xFF10B981), Color(0xFF34D399)],
    ),
    // NOTIFICATION ITEM - ADDED
    HomeNavItem(
      icon: Iconsax.notification,
      title: 'Notifications',
      route: AppRoutes.agentNotifications, // Use constant
      color: Color(0xFFEC4899),
      gradient: [Color(0xFFEC4899), Color(0xFFF472B6)],
    ),
    HomeNavItem(
      icon: Iconsax.car,
      title: 'Vehicle Inventory',
      route: '/agent/vehicles',
      color: Color(0xFF6366F1),
      gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    ),
    HomeNavItem(
      icon: Iconsax.calendar,
      title: 'Reservations',
      route: '/agent/reservations',
      color: Color(0xFFF59E0B),
      gradient: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    ),
    HomeNavItem(
      icon: Iconsax.building,
      title: 'My Branch',
      route: '/agent/branch',
      color: Color(0xFFEF4444),
      gradient: [Color(0xFFEF4444), Color(0xFFF87171)],
    ),
    HomeNavItem(
      icon: Iconsax.receipt,
      title: 'Billing',
      route: '/agent/billing',
      color: Color(0xFF8B5CF6),
      gradient: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    ),
    HomeNavItem(
      icon: Iconsax.chart,
      title: 'Analytics',
      route: '/agent/analytics',
      color: Color(0xFF0EA5E9),
      gradient: [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
    ),
    HomeNavItem(
      icon: Iconsax.message,
      title: 'Customer Support',
      route: '/agent/support',
      color: Color(0xFFEC4899),
      gradient: [Color(0xFFEC4899), Color(0xFFF472B6)],
    ),
    HomeNavItem(
      icon: Iconsax.setting,
      title: 'Settings',
      route: '/agent/settings',
      color: Color(0xFF6B7280),
      gradient: [Color(0xFF6B7280), Color(0xFF9CA3AF)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> userData = storage.read('user_data') ?? {};

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MODIFIED: Agent-specific header with different theme
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF10B981),
                    Color(0xFF0EA5E9),
                    Color(0xFF6366F1),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _CirclePatternPainter(),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 20,
                      left: 24,
                      right: 24,
                      bottom: 36,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Glass Welcome Card
                        Container(
                          padding: EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 35,
                                spreadRadius: 0,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Gradient Avatar Ring
                              Container(
                                padding: EdgeInsets.all(3.5),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.85),
                                      Colors.white.withOpacity(0.35),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF10B981).withOpacity(0.35),
                                        blurRadius: 14,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Iconsax.profile_tick,
                                      size: 32,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 18),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Agent Dashboard',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.85),
                                        letterSpacing: 0.4,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      userData['full_name'] ?? 'Agent',
                                      style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: -0.6,
                                        height: 1.1,
                                      ),
                                    ),
                                    if (userData['branch_name'] != null)
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(0xFF10B981).withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: Color(0xFF10B981).withOpacity(0.8),
                                            width: 1.2,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Iconsax.building,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 6),
                                            Text(
                                              userData['branch_name'].toString(),
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),

                              // MODIFIED: Agent Quick Actions
                              Column(
                                children: [
                                  _buildQuickActionButton(
                                    icon: Iconsax.notification,
                                    onTap: () => Get.toNamed(_getNotificationRoute()),
                                  ),
                                  SizedBox(height: 14),
                                  _buildQuickActionButton(
                                    icon: Iconsax.message,
                                    onTap: () => Get.to(() => ConversationsListScreen()),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 28),

                        // MODIFIED: Agent Search Bar
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 22, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.25),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.search_normal,
                                color: Colors.white.withOpacity(0.85),
                                size: 22,
                              ),
                              SizedBox(width: 14),
                              Expanded(
                                child: TextField(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Search reservations, vehicles...",
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.65),
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(11),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Iconsax.filter,
                                  color: Colors.white,
                                  size: 19,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 34),

            // MODIFIED: Today's Stats Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Overview",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.7,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Your daily performance metrics",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF10B981).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Color(0xFF10B981).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Get.toNamed('/agent/analytics'),
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              child: Row(
                                children: [
                                  Text(
                                    "Detailed View",
                                    style: TextStyle(
                                      color: Color(0xFF10B981),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Iconsax.arrow_right_3,
                                    size: 17,
                                    color: Color(0xFF10B981),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final stats = [
                        {'title': 'Active Rentals', 'value': '12', 'color': Color(0xFF10B981), 'icon': Iconsax.car},
                        {'title': 'Pending Approval', 'value': '5', 'color': Color(0xFFF59E0B), 'icon': Iconsax.clock},
                        {'title': 'Revenue Today', 'value': '\$2,450', 'color': Color(0xFF6366F1), 'icon': Iconsax.dollar_circle},
                        {'title': 'Available Cars', 'value': '18', 'color': Color(0xFF0EA5E9), 'icon': Iconsax.tick_circle},
                      ];
                      return _buildStatCard(stats[index]);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 38),

            // Quick Navigation Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Quick Actions",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.7,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Manage your rental operations",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.88,
                    ),
                    itemCount: _navItems.length,
                    itemBuilder: (context, index) {
                      final item = _navItems[index];
                      return _buildNavCard(item);
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 38),

            // MODIFIED: Pending Approvals Banner
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: EdgeInsets.all(26),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFF59E0B),
                      Color(0xFFEC4899),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFFF59E0B).withOpacity(0.45),
                      blurRadius: 28,
                      spreadRadius: 0,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.25),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Iconsax.clock,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pending Approvals',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            'You have 5 reservations waiting for your review',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.92),
                              letterSpacing: 0.2,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.35),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Iconsax.warning_2, size: 13, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'URGENT: 2 high priority',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        shape: BoxShape.circle,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Get.toNamed('/agent/reservations'),
                          borderRadius: BorderRadius.circular(100),
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Iconsax.arrow_right_3,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 38),

            // MODIFIED: Recent Bookings
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recent Bookings",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.7,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Latest customer reservations",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.12),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 28,
                          spreadRadius: 0,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildBookingItem(
                          customer: "John Smith",
                          vehicle: "BMW M4",
                          duration: "3 days",
                          amount: "\$387",
                          status: "active",
                          statusColor: Color(0xFF10B981),
                        ),
                        SizedBox(height: 22),
                        Divider(
                          height: 1,
                          color: Colors.grey.withOpacity(0.15),
                          thickness: 1,
                        ),
                        SizedBox(height: 22),
                        _buildBookingItem(
                          customer: "Sarah Johnson",
                          vehicle: "Mercedes AMG",
                          duration: "5 days",
                          amount: "\$745",
                          status: "pending",
                          statusColor: Color(0xFFF59E0B),
                        ),
                        SizedBox(height: 22),
                        Divider(
                          height: 1,
                          color: Colors.grey.withOpacity(0.15),
                          thickness: 1,
                        ),
                        SizedBox(height: 22),
                        _buildBookingItem(
                          customer: "Michael Chen",
                          vehicle: "Audi R8",
                          duration: "2 days",
                          amount: "\$398",
                          status: "completed",
                          statusColor: Color(0xFF6366F1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 60),
          ],
        ),
      ),

      // MODIFIED: Agent FAB
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF10B981).withOpacity(0.55),
              blurRadius: 24,
              spreadRadius: 2,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Get.toNamed('/agent/reservations/create');
          },
          backgroundColor: Color(0xFF10B981),
          foregroundColor: Colors.white,
          elevation: 0,
          icon: Icon(Iconsax.add, size: 23),
          label: Text(
            'New Rental',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              letterSpacing: 0.4,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.17),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.28),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Icon(icon, size: 21, color: Colors.white),
          ),
        ),
      )
    );
  }

  Widget _buildStatCard(Map<String, dynamic> stat) {
    return Container(
      padding: EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: stat['color'].withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: stat['color'].withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(stat['icon'], size: 22, color: stat['color']),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat['value'],
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  stat['title'],
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard(HomeNavItem item) {
    return GestureDetector(
      onTap: () {
        if (item.route == '/agent/support') {
          Get.to(() => ConversationsListScreen());
        } else if (item.route == AppRoutes.agentNotifications) {
          Get.toNamed(AppRoutes.agentNotifications);
        } else {
          try {
            Get.toNamed(item.route);
          } catch (e) {
            print('Error navigating to ${item.route}: $e');
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: item.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.38),
              blurRadius: 14,
              spreadRadius: 0,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.22),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Icon(item.icon, size: 27, color: Colors.white),
            ),
            SizedBox(height: 11),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                item.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.25,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItem({
    required String customer,
    required String vehicle,
    required String duration,
    required String amount,
    required String status,
    required Color statusColor,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(13),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withOpacity(0.18),
                statusColor.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: statusColor.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Icon(Iconsax.car, size: 23, color: statusColor),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                customer,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: -0.2,
                  color: Color(0xFF1A1A1A),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                "$vehicle • $duration",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1A1A1A),
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                status.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class HomeNavItem {
  final IconData icon;
  final String title;
  final String route;
  final Color color;
  final List<Color> gradient;

  HomeNavItem({
    required this.icon,
    required this.title,
    required this.route,
    required this.color,
    required this.gradient,
  });
}

class _CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      90,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.75),
      70,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 1.15, size.height * 0.55),
      110,
      paint,
    );
    canvas.drawCircle(
      Offset(-30, size.height * 0.35),
      80,
      paint,
    );
    
    paint.color = Colors.white.withOpacity(0.02);
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.4),
      120,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.3, size.height * 0.1),
      60,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}