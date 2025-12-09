// features/modules/branches/views/branch_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/branch_models/branch_models.dart';
import '../controllers/branch_controller.dart';

class BranchDetailScreen extends StatelessWidget {
  final Branch branch;

  const BranchDetailScreen({super.key, required this.branch});

  @override
  Widget build(BuildContext context) {
    final BranchController controller = Get.find<BranchController>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(branch.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final isOpen = await controller.checkBranchOpen(branch.id);
              Get.snackbar(
                'Status Updated',
                'Branch is ${isOpen ? "OPEN" : "CLOSED"}',
                backgroundColor: isOpen ? Colors.green : Colors.red,
                colorText: Colors.white,
              );
            },
            tooltip: 'Check Status',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Branch Header
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: branch.active ? Colors.blue : Colors.grey,
                          child: Icon(
                            Icons.business,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                branch.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                branch.code,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Obx(() {
                          final isOpen = controller.isBranchOpenNow(branch.id);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isOpen ? Colors.green[50] : Colors.red[50],
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isOpen ? Colors.green : Colors.red,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isOpen ? Icons.circle : Icons.circle_outlined,
                                  size: 12,
                                  color: isOpen ? Colors.green : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isOpen ? 'OPEN NOW' : 'CLOSED',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isOpen ? Colors.green[800] : Colors.red[800],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              branch.active ? Icons.check_circle : Icons.cancel,
                              color: branch.active ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              branch.active ? 'Active Branch' : 'Inactive Branch',
                              style: TextStyle(
                                color: branch.active ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Updated: ${DateFormat('MMM dd, yyyy').format(branch.updatedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Address Section
            _buildSection(
              title: 'Location & Address',
              icon: Icons.location_on,
              color: Colors.blue,
              children: [
                _buildDetailItem(
                  label: 'Address Line 1',
                  value: branch.address.line1,
                ),
                if (branch.address.line2 != null && branch.address.line2!.isNotEmpty)
                  _buildDetailItem(
                    label: 'Address Line 2',
                    value: branch.address.line2!,
                  ),
                _buildDetailItem(
                  label: 'City',
                  value: branch.address.city,
                ),
                _buildDetailItem(
                  label: 'Region',
                  value: branch.address.region,
                ),
                _buildDetailItem(
                  label: 'Postal Code',
                  value: branch.address.postalCode,
                ),
                _buildDetailItem(
                  label: 'Country',
                  value: branch.address.country,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final url = 'https://www.google.com/maps/search/?api=1&query=${branch.geo.latitude},${branch.geo.longitude}';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          } else {
                            Get.snackbar(
                              'Error',
                              'Could not open maps',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('Open in Maps'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Contact Section
            _buildSection(
              title: 'Contact Information',
              icon: Icons.contact_phone,
              color: Colors.green,
              children: [
                _buildContactItem(
                  icon: Icons.phone,
                  label: 'Phone',
                  value: branch.phone,
                  onTap: () async {
                    final url = 'tel:${branch.phone}';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    } else {
                      Get.snackbar(
                        'Error',
                        'Could not make call',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  buttonText: 'Call',
                  buttonColor: Colors.green,
                ),
                _buildContactItem(
                  icon: Icons.email,
                  label: 'Email',
                  value: branch.email,
                  onTap: () async {
                    final url = 'mailto:${branch.email}';
                    if (await canLaunchUrl(Uri.parse(url))) {
                      await launchUrl(Uri.parse(url));
                    } else {
                      Get.snackbar(
                        'Error',
                        'Could not open email',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                  buttonText: 'Email',
                  buttonColor: Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Opening Hours Section
            _buildSection(
              title: 'Opening Hours',
              icon: Icons.access_time,
              color: Colors.purple,
              children: [
                _buildOpeningHours(branch),
              ],
            ),

            const SizedBox(height: 24),

            // Branch Info Section
            _buildSection(
              title: 'Branch Information',
              icon: Icons.info,
              color: Colors.amber,
              children: [
                _buildDetailItem(
                  label: 'Branch ID',
                  value: branch.id,
                  copyable: true,
                ),
                _buildDetailItem(
                  label: 'Created',
                  value: DateFormat('MMMM dd, yyyy').format(branch.createdAt),
                ),
                _buildDetailItem(
                  label: 'Last Updated',
                  value: DateFormat('MMMM dd, yyyy').format(branch.updatedAt),
                ),
                if (branch.imageLoc != null && branch.imageLoc!.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Image Location',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () async {
                          if (await canLaunchUrl(Uri.parse(branch.imageLoc!))) {
                            await launchUrl(Uri.parse(branch.imageLoc!));
                          }
                        },
                        child: Text(
                          branch.imageLoc!,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Back to List'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Share functionality
                      Get.snackbar(
                        'Share',
                        'Share feature coming soon!',
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    bool copyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (copyable)
                IconButton(
                  icon: const Icon(Icons.content_copy, size: 20),
                  onPressed: () {
                    // Copy to clipboard
                    Get.snackbar(
                      'Copied',
                      '$label copied to clipboard',
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required String buttonText,
    required Color buttonColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: Text(buttonText),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOpeningHours(Branch branch) {
    final days = [
      {'name': 'Monday', 'hours': branch.openingHours.monday},
      {'name': 'Tuesday', 'hours': branch.openingHours.tuesday},
      {'name': 'Wednesday', 'hours': branch.openingHours.wednesday},
      {'name': 'Thursday', 'hours': branch.openingHours.thursday},
      {'name': 'Friday', 'hours': branch.openingHours.friday},
      {'name': 'Saturday', 'hours': branch.openingHours.saturday},
      {'name': 'Sunday', 'hours': branch.openingHours.sunday},
    ];

    return Column(
      children: days.map((day) {
        final hours = day['hours'] as List<OpeningHour>?;
        final isToday = _isToday(day['name'] as String);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isToday ? Colors.blue[50] : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isToday ? Colors.blue : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  day['name'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isToday ? Colors.blue : Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  hours == null || hours.isEmpty
                      ? 'Closed'
                      : hours.map((h) => h.formattedTime).join(', '),
                  style: TextStyle(
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    color: isToday ? Colors.blue : Colors.black,
                  ),
                ),
              ),
              if (isToday)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'TODAY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  bool _isToday(String dayName) {
    final now = DateTime.now();
    final currentDay = now.weekday;
    
    switch (dayName) {
      case 'Monday':
        return currentDay == DateTime.monday;
      case 'Tuesday':
        return currentDay == DateTime.tuesday;
      case 'Wednesday':
        return currentDay == DateTime.wednesday;
      case 'Thursday':
        return currentDay == DateTime.thursday;
      case 'Friday':
        return currentDay == DateTime.friday;
      case 'Saturday':
        return currentDay == DateTime.saturday;
      case 'Sunday':
        return currentDay == DateTime.sunday;
      default:
        return false;
    }
  }
}