import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> userData = storage.read('user_data') ?? {};

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue,
                      child: Text(
                        userData['full_name'] != null
                            ? userData['full_name'][0].toUpperCase()
                            : 'G',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userData['full_name'] ?? 'Guest User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userData['email'] ?? 'Not logged in',
                            style:
                                const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          if (userData['status'] != null)
                            Text(
                              'Status: ${userData['status']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: userData['status'] == 'active'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Get.to(() => const ConversationsListScreen());
                          },
                          icon: const Icon(Icons.chat, color: Colors.purple),
                          tooltip: 'Messages',
                        ),
                        IconButton(
                          onPressed: () {
                            Get.to(() => const PromoCodeScreen());
                          },
                          icon: const Icon(Icons.local_offer, color: Colors.orange),
                          tooltip: 'View Promo Codes',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Find your perfect ride",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _carCard(context,
                      "assets/images/campbell-3ZUsNJhi_Ik-unsplash.jpg", "BMW M4"),
                  _carCard(context,
                      "assets/images/joshua-koblin-eqW1MPinEV4-unsplash.jpg",
                      "Mercedes AMG"),
                  _carCard(context,
                      "assets/images/peter-broomfield-m3m-lnR90uM-unsplash.jpg",
                      "Audi R8"),
                ],
              ),
            ),

            const SizedBox(height: 30),
            const Text(
              "Quick Stats",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildStatCard(
                  icon: Icons.calendar_today,
                  title: "Bookings",
                  value: "0",
                  color: Colors.blue,
                ),
                _buildStatCard(
                  icon: Icons.chat,
                  title: "Messages",
                  value: "0",
                  color: Colors.purple,
                  onTap: () => Get.to(() => const ConversationsListScreen()),
                ),
                _buildStatCard(
                  icon: Icons.local_offer,
                  title: "Active Promos",
                  value: "0",
                  color: Colors.orange,
                  onTap: () => Get.to(() => const PromoCodeScreen()),
                ),
                _buildStatCard(
                  icon: Icons.favorite,
                  title: "Favorites",
                  value: "0",
                  color: Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 30),
            _buildPromoBanner(),

            const SizedBox(height: 20),
            _buildChatBanner(),

            const SizedBox(height: 30),
            _buildRecentActivity(),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Get.to(() => const PromoCodeScreen());
        },
        icon: const Icon(Icons.local_offer),
        label: const Text('Promo Codes'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        tooltip: 'View all promo codes',
      ),
    );
  }

  Widget _carCard(BuildContext context, String img, String name) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => CarDetailsScreen(carName: name, image: img),
        );
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover),
        ),
        child: Container(
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
          child: Text(
            name,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade100, Colors.orange.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_offer_outlined,
            size: 40,
            color: Colors.orange,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Special Offers Available!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Check out our active promo codes for exclusive discounts on your next rental.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              Get.to(() => const PromoCodeScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('View Offers'),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade100, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.support_agent,
            size: 40,
            color: Colors.purple,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '24/7 Chat Support',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Need help? Chat with our support team anytime.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              Get.to(() => const ConversationsListScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Chat Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Recent Activity",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.local_offer, color: Colors.green),
                  title: const Text('Promo Code Applied'),
                  subtitle: const Text('SUMMER25 - 25% off'),
                  trailing: Text(
                    'Just now',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.car_rental, color: Colors.blue),
                  title: const Text('Car Booking'),
                  subtitle: const Text('BMW M4 - 2 days'),
                  trailing: Text(
                    '2 hours ago',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.payment, color: Colors.purple),
                  title: const Text('Payment Received'),
                  subtitle: const Text('Booking #ORD-12345'),
                  trailing: Text(
                    '1 day ago',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}