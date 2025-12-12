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

    return Scaffold(
      backgroundColor: Colors.white,
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
                                        color: Color(0xFF047BC1).withOpacity(0.35),
                                        blurRadius: 14,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                    child: Text(
                                      userData['full_name'] != null
                                          ? userData['full_name'][0].toUpperCase()
                                          : 'G',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF047BC1),
                                      ),
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
                                      'Welcome back,',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.85),
                                        letterSpacing: 0.4,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      userData['full_name'] ?? 'Guest User',
                                      style: TextStyle(
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: -0.6,
                                        height: 1.1,
                                      ),
                                    ),
                                    if (userData['status'] != null)
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: userData['status'] == 'active'
                                              ? Colors.green.withOpacity(0.25)
                                              : Colors.orange.withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: userData['status'] == 'active'
                                                ? Colors.greenAccent.withOpacity(0.8)
                                                : Colors.orangeAccent.withOpacity(0.8),
                                            width: 1.2,
                                          ),
                                        ),
                                        child: Text(
                                          userData['status'].toString().toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: userData['status'] == 'active'
                                                ? Colors.greenAccent
                                                : Colors.orangeAccent,
                                            letterSpacing: 0.9,
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
                                  SizedBox(height: 14),
                                  _buildQuickActionButton(
                                    icon: Iconsax.ticket_discount,
                                    onTap: () => Get.to(() => PromoCodeScreen()),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 28),

                        // Premium Search Bar
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
                                    hintText: "Find your perfect ride...",
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

            // Featured Cars Section
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
                            "Featured Cars",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.7,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Premium selection just for you",
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
                          color: Color(0xFF047BC1).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Color(0xFF047BC1).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            borderRadius: BorderRadius.circular(14),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              child: Row(
                                children: [
                                  Text(
                                    "View All",
                                    style: TextStyle(
                                      color: Color(0xFF047BC1),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(
                                    Iconsax.arrow_right_3,
                                    size: 17,
                                    color: Color(0xFF047BC1),
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
                  SizedBox(
                    height: 250,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.only(right: 4),
                      children: [
                        _buildCarCard(
                          context,
                          "assets/images/campbell-3ZUsNJhi_Ik-unsplash.jpg",
                          "BMW M4",
                          "\$129/day",
                          rating: 4.8,
                        ),
                        SizedBox(width: 18),
                        _buildCarCard(
                          context,
                          "assets/images/joshua-koblin-eqW1MPinEV4-unsplash.jpg",
                          "Mercedes AMG",
                          "\$149/day",
                          rating: 4.9,
                        ),
                        SizedBox(width: 18),
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
                        "Quick Navigation",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.7,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Access all features",
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

            // Premium Promo Banner
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: EdgeInsets.all(26),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF047BC1),
                      Color(0xFF4F46E5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF047BC1).withOpacity(0.45),
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
                        Iconsax.ticket_discount,
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
                            'Exclusive Offer!',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.4,
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            'Get 25% off on your first booking',
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
                            child: Text(
                              'WELCOME25',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.3,
                              ),
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
                          onTap: () => Get.to(() => PromoCodeScreen()),
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

            // Recent Activity with Glass Card
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Recent Activity",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.7,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Your latest transactions",
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
                        _buildActivityItem(
                          icon: Iconsax.car,
                          title: "BMW M4 Booked",
                          subtitle: "2 days • \$258 total",
                          time: "2 hours ago",
                          color: Color(0xFF047BC1),
                        ),
                        SizedBox(height: 22),
                        Divider(
                          height: 1,
                          color: Colors.grey.withOpacity(0.15),
                          thickness: 1,
                        ),
                        SizedBox(height: 22),
                        _buildActivityItem(
                          icon: Iconsax.ticket_discount,
                          title: "Promo Applied",
                          subtitle: "SUMMER25 - 25% off",
                          time: "Yesterday",
                          color: Color(0xFF4F46E5),
                        ),
                        SizedBox(height: 22),
                        Divider(
                          height: 1,
                          color: Colors.grey.withOpacity(0.15),
                          thickness: 1,
                        ),
                        SizedBox(height: 22),
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

            SizedBox(height: 60),
          ],
        ),
      ),

      // Premium FAB with Glow
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Color(0xFF047BC1).withOpacity(0.55),
              blurRadius: 24,
              spreadRadius: 2,
              offset: Offset(0, 6),
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
          icon: Icon(Iconsax.add, size: 23),
          label: Text(
            'Book Now',
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
        width: 310,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 24,
              spreadRadius: 0,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
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
                        Colors.black.withOpacity(0.25),
                        Colors.black.withOpacity(0.88),
                      ],
                      stops: [0.35, 0.68, 1.0],
                    ),
                  ),
                ),
              ),
              
              // Premium Badge
              Positioned(
                top: 18,
                right: 18,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.gas_station, size: 15, color: Colors.white),
                      SizedBox(width: 7),
                      Text(
                        "Premium",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
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
                  padding: EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.6,
                        ),
                      ),
                      SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Iconsax.star1, size: 15, color: Colors.amber),
                                SizedBox(width: 6),
                                Text(
                                  rating.toString(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            price,
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.4,
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
          padding: EdgeInsets.all(13),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.18),
                color.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          child: Icon(icon, size: 23, color: color),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: -0.2,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 5),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.withOpacity(0.12),
              width: 1,
            ),
          ),
          child: Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
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

    // Draw decorative circles in pattern
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
    
    // Additional subtle circles for depth
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