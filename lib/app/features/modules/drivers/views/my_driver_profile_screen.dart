// lib/features/modules/drivers/views/my_driver_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/driver_profile_controller.dart';
import 'driver_profile_form_screen.dart';

class MyDriverProfileScreen extends StatefulWidget {
  const MyDriverProfileScreen({super.key});

  @override
  State<MyDriverProfileScreen> createState() => _MyDriverProfileScreenState();
}

class _MyDriverProfileScreenState extends State<MyDriverProfileScreen> {
  final DriverProfileController controller = Get.find<DriverProfileController>();

  @override
  void initState() {
    super.initState();
    print('👤 MyDriverProfileScreen initialized');
  }

  void _refreshProfile() {
    print('🔄 Refreshing driver profile');
    controller.fetchMyDriverProfile();
  }

  void _toggleAvailability() {
    final currentProfile = controller.myDriverProfile.value;
    if (currentProfile != null) {
      print('🔄 Toggling availability from ${currentProfile.isAvailable} to ${!currentProfile.isAvailable}');
      controller.updateAvailability(!currentProfile.isAvailable);
    }
  }

  void _editProfile() {
    print('✏️ Navigating to edit profile');
    Get.to(() => DriverProfileFormScreen(isEditMode: true));
  }

  void _createProfile() {
    print('➕ Navigating to create profile');
    Get.to(() => const DriverProfileFormScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Driver Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshProfile,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingProfile.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading your driver profile...'),
              ],
            ),
          );
        }

        // No driver role
        if (!controller.hasDriverRole) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.warning, size: 64, color: Colors.orange),
                  const SizedBox(height: 24),
                  const Text(
                    'Driver Role Required',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'You need the "driver" role to create or manage a driver profile.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Regular users cannot become drivers without admin approval.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'Contact Support',
                        'Please contact support to request driver access',
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                      );
                    },
                    icon: const Icon(Icons.contact_support),
                    label: const Text('Request Driver Access'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('View Available Drivers Instead'),
                  ),
                ],
              ),
            ),
          );
        }

        // Has driver role but no profile
        if (controller.myDriverProfile.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.drive_eta, size: 64, color: Colors.blue),
                  const SizedBox(height: 24),
                  const Text(
                    'No Driver Profile Yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Create a driver profile to start accepting bookings and earning money.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _createProfile,
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Create Driver Profile'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('View Available Drivers Instead'),
                  ),
                ],
              ),
            ),
          );
        }

        // Has driver profile - show it
        final profile = controller.myDriverProfile.value!;
        final dateFormat = DateFormat('dd MMM yyyy');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Profile Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Avatar
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: profile.isAvailable 
                                ? Colors.green.shade100 
                                : Colors.grey.shade200,
                            child: Text(
                              profile.user.fullName[0].toUpperCase(),
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: profile.isAvailable ? Colors.green : Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.displayName,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profile.user.fullName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${profile.baseCity}, ${profile.baseCountry}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Status Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatCard(
                            'Status',
                            profile.status.toUpperCase(),
                            _getStatusColor(profile.status),
                          ),
                          _buildStatCard(
                            'Rate',
                            profile.hourlyRateFormatted,
                            Colors.green,
                          ),
                          _buildStatCard(
                            'Experience',
                            profile.experienceText,
                            Colors.blue,
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Availability Toggle
                      SwitchListTile(
                        title: const Text('Available for Bookings'),
                        subtitle: Text(profile.isAvailable 
                            ? 'You are currently accepting bookings'
                            : 'You are not available for bookings'),
                        value: profile.isAvailable,
                        onChanged: (value) => _toggleAvailability(),
                        secondary: Icon(
                          profile.isAvailable ? Icons.check_circle : Icons.cancel,
                          color: profile.isAvailable ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Bio Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.bio,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Details Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDetailCard(
                    'Rating',
                    '${profile.ratingAverage.toStringAsFixed(1)} ⭐ (${profile.ratingCount} reviews)',
                    Icons.star,
                    Colors.amber,
                  ),
                  _buildDetailCard(
                    'Languages',
                    profile.languagesText,
                    Icons.language,
                    Colors.blue,
                  ),
                  _buildDetailCard(
                    'Profile Created',
                    dateFormat.format(profile.createdAt),
                    Icons.calendar_today,
                    Colors.green,
                  ),
                  _buildDetailCard(
                    'Last Updated',
                    dateFormat.format(profile.updatedAt),
                    Icons.update,
                    Colors.orange,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // License Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'License Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildLicenseDetail('Number', profile.driverLicense.number),
                      _buildLicenseDetail('Class', profile.driverLicense.licenseClass),
                      _buildLicenseDetail('Country', profile.driverLicense.country),
                      _buildLicenseDetail('Expires', 
                        '${dateFormat.format(profile.driverLicense.expiresAt)} (in ${profile.driverLicense.expiresIn})',
                      ),
                      _buildLicenseDetail('Verified', 
                        profile.driverLicense.verified ? 'Yes' : 'No',
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _editProfile,
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profile'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.snackbar(
                          'Coming Soon',
                          'Booking analytics feature coming soon!',
                          backgroundColor: Colors.blue,
                          colorText: Colors.white,
                        );
                      },
                      icon: const Icon(Icons.analytics),
                      label: const Text('View Analytics'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'pending': return Colors.orange;
      case 'rejected': return Colors.red;
      case 'suspended': return Colors.red;
      default: return Colors.grey;
    }
  }
}