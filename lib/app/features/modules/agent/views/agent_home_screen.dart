import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import '../../../data/services/rate_plan_service.dart';
import '../../../widgets/sidebar_widget/sidebar_widget.dart';
import '../../car_details/views/car_detail_screen.dart';
import '../../promo_code/views/promo_code_screen.dart';
import '../../chat/views/conversations_list_screen.dart';
import '../../rate_plans/controllers/rate_plan_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

    return SidebarWidget(
      initiallyOpen: false,
      child: _HomeContent(),
    );
  }
}

class _HomeContent extends StatelessWidget {
  _HomeContent();

  final GetStorage storage = GetStorage();

  final List<HomeNavItem> _navItems = [
    HomeNavItem(
      icon: Iconsax.driving,
      title: 'Available Drivers',
      route: '/drivers/public',
      color: Color(0xFF047BC1),
      gradient: [Color(0xFF047BC1), Color(0xFF0A9FE8)],
    ),
    HomeNavItem(
      icon: Iconsax.profile_2user,
      title: 'My Driver Profile',
      route: '/drivers/my-profile',
      color: Color(0xFF4F46E5),
      gradient: [Color(0xFF4F46E5), Color(0xFF6366F1)],
    ),
    HomeNavItem(
      icon: Iconsax.car,
      title: 'Vehicle Models',
      route: '/vehicles/models',
      color: Color(0xFF3730A3),
      gradient: [Color(0xFF3730A3), Color(0xFF4F46E5)],
    ),
    HomeNavItem(
      icon: Iconsax.ship,
      title: 'Vehicle Fleet',
      route: '/vehicles/fleet',
      color: Color(0xFF047BC1),
      gradient: [Color(0xFF047BC1), Color(0xFF06A8E8)],
    ),
    HomeNavItem(
      icon: Iconsax.building,
      title: 'Branches',
      route: '/branches',
      color: Color(0xFF4F46E5),
      gradient: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    ),
    HomeNavItem(
      icon: Iconsax.location,
      title: 'Nearby Branches',
      route: '/branches/nearby',
      color: Color(0xFF3730A3),
      gradient: [Color(0xFF3730A3), Color(0xFF4F46E5)],
    ),
    HomeNavItem(
      icon: Iconsax.search_status,
      title: 'Check Availability',
      route: '/reservations/availability',
      color: Color(0xFF047BC1),
      gradient: [Color(0xFF047BC1), Color(0xFF0891D1)],
    ),
    HomeNavItem(
      icon: Iconsax.add_square,
      title: 'Create Reservation',
      route: '/reservations/create',
      color: Color(0xFF4F46E5),
      gradient: [Color(0xFF4F46E5), Color(0xFF6366F1)],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> userData = storage.read('user_data') ?? {};
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Header with Glassmorphism
            Container(
              width: double.infinity,
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
              child: Stack(
                children: [
                  // Animated Background Pattern
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _CirclePatternPainter(),
                    ),
                  ),
                  
                  Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 20,
                      right: 20,
                      bottom: 32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Glass Welcome Card
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 30,
                                spreadRadius: 0,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Gradient Avatar Ring
                              Container(
                                padding: EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withOpacity(0.8),
                                      Colors.white.withOpacity(0.3),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF047BC1).withOpacity(0.3),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      userData['full_name'] != null
                                          ? userData['full_name'][0].toUpperCase()
                                          : 'G',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF047BC1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back,',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.white.withOpacity(0.8),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      userData['full_name'] ?? 'Guest User',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    if (userData['status'] != null)
                                      Container(
                                        margin: EdgeInsets.only(top: 8),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: userData['status'] == 'active'
                                              ? Colors.green.withOpacity(0.2)
                                              : Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: userData['status'] == 'active'
                                                ? Colors.greenAccent
                                                : Colors.orangeAccent,
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          userData['status'].toString().toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: userData['status'] == 'active'
                                                ? Colors.greenAccent
                                                : Colors.orangeAccent,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              
                              // Quick Actions
                              Column(
                                children: [
                                  _buildQuickActionButton(
                                    icon: Iconsax.message,
                                    onTap: () => Get.to(() => ConversationsListScreen()),
                                  ),
                                  SizedBox(height: 12),
                                  _buildQuickActionButton(
                                    icon: Iconsax.ticket_discount,
                                    onTap: () => Get.to(() => PromoCodeScreen()),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // Premium Search Bar
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.search_normal,
                                color: Colors.white.withOpacity(0.8),
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Find your perfect ride...",
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 15,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Iconsax.filter,
                                  color: Colors.white,
                                  size: 18,
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

            SizedBox(height: 28),

            // Featured Cars Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
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
                            "Featured Cars",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Premium selection just for you",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF047BC1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "View All",
                                style: TextStyle(
                                  color: Color(0xFF047BC1),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Iconsax.arrow_right_3,
                                size: 16,
                                color: Color(0xFF047BC1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: 240,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCarCard(
                          context,
                          "assets/images/campbell-3ZUsNJhi_Ik-unsplash.jpg",
                          "BMW M4",
                          "\$129/day",
                          rating: 4.8,
                        ),
                        SizedBox(width: 16),
                        _buildCarCard(
                          context,
                          "assets/images/joshua-koblin-eqW1MPinEV4-unsplash.jpg",
                          "Mercedes AMG",
                          "\$149/day",
                          rating: 4.9,
                        ),
                        SizedBox(width: 16),
                        _buildCarCard(
                          context,
                          "assets/images/peter-broomfield-m3m-lnR90uM-unsplash.jpg",
                          "Audi R8",
                          "\$199/day",
                          rating: 4.7,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Quick Navigation Grid
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Quick Navigation",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Access all features",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.85,
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

            SizedBox(height: 32),

            // Premium Promo Banner
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF047BC1),
                      Color(0xFF4F46E5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF047BC1).withOpacity(0.4),
                      blurRadius: 25,
                      spreadRadius: 0,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Iconsax.ticket_discount,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exclusive Offer!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Get 25% off on your first booking',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.9),
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              'WELCOME25',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Get.to(() => PromoCodeScreen()),
                        icon: Icon(
                          Iconsax.arrow_right_3,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32),

            // Recent Activity with Glass Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recent Activity",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Your latest transactions",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark 
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                          blurRadius: 25,
                          spreadRadius: 0,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildActivityItem(
                          icon: Iconsax.car,
                          title: "BMW M4 Booked",
                          subtitle: "2 days • \$258 total",
                          time: "2 hours ago",
                          color: Color(0xFF047BC1),
                        ),
                        SizedBox(height: 20),
                        Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                        SizedBox(height: 20),
                        _buildActivityItem(
                          icon: Iconsax.ticket_discount,
                          title: "Promo Applied",
                          subtitle: "SUMMER25 - 25% off",
                          time: "Yesterday",
                          color: Color(0xFF4F46E5),
                        ),
                        SizedBox(height: 20),
                        Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
                        SizedBox(height: 20),
                        _buildActivityItem(
                          icon: Iconsax.message,
                          title: "Support Chat",
                          subtitle: "Resolved: Payment issue",
                          time: "2 days ago",
                          color: Color(0xFF3730A3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 50),
          ],
        ),
      ),

      // Premium FAB with Glow
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF047BC1).withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () {
            Get.toNamed(
              '/reservations/create',
              arguments: {
                'vehicleId': 'featured_car_001',
                'vehicleName': 'Featured Vehicle',
                'dailyRate': 99.0,
                'startDate': DateTime.now(),
                'endDate': DateTime.now().add(Duration(days: 2)),
              },
            );
          },
          backgroundColor: Color(0xFF047BC1),
          foregroundColor: Colors.white,
          elevation: 0,
          icon: Icon(Iconsax.add, size: 22),
          label: Text(
            'Book Now',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildCarCard(
    BuildContext context,
    String image,
    String name,
    String price, {
    double rating = 4.5,
  }) {
    return GestureDetector(
      onTap: () {
        Get.to(() => CarDetailsScreen(carName: name, image: image));
      },
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 0,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
              
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.9),
                      ],
                      stops: [0.4, 0.7, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Premium Badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.gas_station, size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        "Premium",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Car Info
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Iconsax.star1, size: 14, color: Colors.amber),
                                SizedBox(width: 5),
                                Text(
                                  rating.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            price,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavCard(HomeNavItem item) {
    return GestureDetector(
      onTap: () {
        if (item.route == '/chat/conversations') {
          Get.to(() => ConversationsListScreen());
        } else if (item.route == '/promo-codes') {
          Get.to(() => PromoCodeScreen());
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
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.35),
              blurRadius: 12,
              spreadRadius: 0,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, size: 26, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Icon(icon, size: 22, color: color),
        ),
        SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// Add these missing classes at the end of the file
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
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Draw multiple circles in a pattern
    for (int i = 0; i < 15; i++) {
      final x = size.width * (i % 5) / 4;
      final y = size.height * (i ~/ 5) / 3;
      final radius = 20 + i * 2;
      
      canvas.drawCircle(Offset(x, y), radius.toDouble(), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}