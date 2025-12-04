import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../auth/controllers/auth_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GetStorage storage = GetStorage();
    final AuthController authController = Get.find<AuthController>();
    final userData = storage.read('user_data') ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
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
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              userData['email'] ?? 'No email',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
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
                    const Text(
                      'Account Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    _buildInfoRow(Icons.phone, 'Phone', userData['phone'] ?? 'Not set'),
                    _buildInfoRow(Icons.badge, 'User ID', userData['_id']?.toString() ?? 'N/A'),
                    _buildInfoRow(Icons.verified, 'Status', userData['status'] ?? 'Unknown'),
                    _buildInfoRow(Icons.email, 'Email Verified', 
                        (userData['email_verified'] ?? false) ? 'Yes' : 'No'),
                    _buildInfoRow(Icons.date_range, 'Member Since', 
                        userData['created_at']?.toString().split('T').first ?? 'N/A'),
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
                    Get.snackbar('Coming Soon', 'Profile editing feature');
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
                      'Debug Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Token Present: ${storage.read('auth_token') != null ? 'Yes' : 'No'}',
                      style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                   Text(
  'Storage Keys: ${storage.getKeys().toList().where((key) => key.toString().contains('user')).join(', ')}',
  style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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