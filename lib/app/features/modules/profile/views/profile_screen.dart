import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find<AuthController>();
  final GetStorage storage = GetStorage();

  @override
  void initState() {
    super.initState();
    // Fetch fresh user profile when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authController.isAuthenticated) {
        authController.getUserProfile();
      }
    });
  }

  Future<void> _refreshProfile() async {
    if (authController.isAuthenticated) {
      await authController.getUserProfile();
      Get.snackbar(
        'Refreshed',
        'Profile data updated',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProfile,
            tooltip: 'Refresh Profile',
          ),
        ],
      ),
      body: Obx(() {
        if (authController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Use the reactive currentUserProfile if available, otherwise fallback to stored data
        final userProfile = authController.currentUserProfile.value;
        final storedUserData = storage.read('user_data') ?? {};

        final userData = userProfile != null
            ? {
                '_id': userProfile.id,
                'email': userProfile.email,
                'phone': userProfile.phone,
                'full_name': userProfile.fullName,
                'roles': userProfile.roles,
                'status': userProfile.status,
                'email_verified': userProfile.emailVerified,
                'created_at': userProfile.createdAt,
                'updated_at': userProfile.updatedAt,
              }
            : storedUserData;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Header
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.blue.shade100,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                userData['full_name'] ?? 'Guest User',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              Text(
                userData['email'] ?? 'No email',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),

              // Indicate if data is fresh or from storage
              if (userProfile != null)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 14, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'Live data',
                        style: TextStyle(fontSize: 12, color: Colors.green),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              // User Info Card
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Account Information',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.verified,
                            color: (userData['email_verified'] ?? false)
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildInfoRow(
                          Icons.phone, 'Phone', userData['phone'] ?? 'Not set'),
                      _buildInfoRow(Icons.badge, 'User ID',
                          userData['_id']?.toString().substring(0, 8) ?? 'N/A'),
                      _buildInfoRow(Icons.badge, 'Status',
                          userData['status'] ?? 'Unknown'),
                      _buildInfoRow(
                          Icons.verified,
                          'Email Verified',
                          (userData['email_verified'] ?? false)
                              ? 'Verified'
                              : 'Not Verified'),
                      _buildInfoRow(
                          Icons.people,
                          'Roles',
                          (userData['roles'] as List<dynamic>?)?.join(', ') ??
                              'No roles'),
                      _buildInfoRow(
                          Icons.date_range,
                          'Member Since',
                          userData['created_at']?.toString().split('T').first ??
                              'N/A'),
                      _buildInfoRow(
                          Icons.update,
                          'Last Updated',
                          userData['updated_at']?.toString().split('T').first ??
                              'N/A'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Actions
              Column(
                children: [
                  _buildActionButton(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: () {
                      Get.toNamed(AppRoutes.editProfile);
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.security,
                    title: 'Change Password',
                    onTap: () {
                      Get.snackbar('Coming Soon', 'Password change feature');
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.history,
                    title: 'Booking History',
                    onTap: () {
                      Get.snackbar('Coming Soon', 'Booking history feature');
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.help,
                    title: 'Help & Support',
                    onTap: () {
                      Get.snackbar('Coming Soon', 'Support feature');
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.logout,
                    title: 'Logout',
                    color: Colors.red,
                    onTap: () {
                      authController.logout();
                    },
                  ),
                ],
              ),

              // Debug Info (optional)
              const SizedBox(height: 30),
              Card(
                color: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Session Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Token Present: ${storage.read('auth_token') != null ? 'Yes' : 'No'}',
                        style: const TextStyle(
                            fontSize: 12, fontFamily: 'monospace'),
                      ),
                      Text(
                        'Profile Source: ${userProfile != null ? 'API (Fresh)' : 'Storage (Cached)'}',
                        style: const TextStyle(
                            fontSize: 12, fontFamily: 'monospace'),
                      ),
                      Text(
                        'Last Updated: ${userData['updated_at'] ?? 'Unknown'}',
                        style: const TextStyle(
                            fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
              ),

              // Error message if any
              if (authController.errorMessage.value.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          authController.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.blue,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
