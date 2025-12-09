// lib/features/modules/drivers/views/public_drivers_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/drivers_models/driver_profile.dart';
import '../controllers/driver_profile_controller.dart';

class PublicDriversScreen extends StatefulWidget {
  const PublicDriversScreen({super.key});

  @override
  State<PublicDriversScreen> createState() => _PublicDriversScreenState();
}

class _PublicDriversScreenState extends State<PublicDriversScreen> {
  final DriverProfileController controller = Get.find<DriverProfileController>();
  final TextEditingController searchController = TextEditingController();
  String? selectedCity;
  String? selectedCountry;
  double? minRating;
  bool availableOnly = false;

  @override
  void initState() {
    super.initState();
    print('🚕 PublicDriversScreen initialized');
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = searchController.text;
    print('🔍 Driver search query changed: "$query"');
    controller.searchDrivers(query);
  }

  void _applyFilters() {
    print('🔍 Applying driver filters...');
    controller.filterDrivers(
      city: selectedCity,
      country: selectedCountry,
      minRating: minRating,
      availableOnly: availableOnly,
    );
  }

  void _clearFilters() {
    print('🧹 Clearing all driver filters');
    searchController.clear();
    selectedCity = null;
    selectedCountry = null;
    minRating = null;
    availableOnly = false;
    controller.clearFilters();
    setState(() {});
  }

  void _showDriverDetail(DriverProfile driver) {
    print('📱 Showing driver detail: ${driver.displayName}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(driver.displayName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Driver Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Profile Image Placeholder
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              driver.user.fullName[0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driver.user.fullName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${driver.baseCity}, ${driver.baseCountry}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${driver.ratingAverage.toStringAsFixed(1)} (${driver.ratingCount})',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Status Indicators
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildStatusChip(
                            driver.availabilityStatus,
                            driver.isAvailable ? Colors.green : Colors.red,
                          ),
                          _buildStatusChip(
                            driver.status.toUpperCase(),
                            _getStatusColor(driver.status),
                          ),
                          _buildStatusChip(
                            driver.hourlyRateFormatted,
                            Colors.blue,
                          ),
                          _buildStatusChip(
                            driver.experienceText,
                            Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Bio Section
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                driver.bio,
                style: const TextStyle(fontSize: 14),
              ),
              
              const SizedBox(height: 16),
              
              // Languages
              const Text(
                'Languages',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: driver.languages.map((language) {
                  return Chip(
                    label: Text(language),
                    backgroundColor: Colors.blue.shade50,
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 16),
              
              // License Info
              const Text(
                'License Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('License Number', driver.driverLicense.number),
                      _buildDetailRow('Class', driver.driverLicense.licenseClass),
                      _buildDetailRow('Country', driver.driverLicense.country),
                      _buildDetailRow('Expires', 
                        '${driver.driverLicense.expiresAt.year}-${driver.driverLicense.expiresAt.month}-${driver.driverLicense.expiresAt.day} (in ${driver.driverLicense.expiresIn})',
                      ),
                      _buildDetailRow('Verified', 
                        driver.driverLicense.verified ? 'Yes' : 'No',
                      ),
                    ],
                  ),
                ),
              ),
              
              // Contact/Book Button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    Get.snackbar(
                      'Booking',
                      'Driver booking feature coming soon!',
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.phone),
                  label: const Text('Contact Driver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'pending': return Colors.orange;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  // In lib/features/modules/drivers/views/public_drivers_screen.dart
void _showFiltersDialog() {
  print('🎯 Showing driver filters dialog');
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Filter Drivers'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // City Dropdown
                    Obx(() {
                      final cities = controller.getUniqueCities();
                      if (cities.isEmpty) {
                        return TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() => selectedCity = value);
                          },
                        );
                      }
                      
                      return DropdownButtonFormField<String>(
                        value: selectedCity,
                        decoration: const InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Cities'),
                          ),
                          ...cities.map((city) {
                            return DropdownMenuItem(
                              value: city,
                              child: Text(city),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          print('🎯 Selected city: $value');
                          setState(() => selectedCity = value);
                        },
                      );
                    }),

                    const SizedBox(height: 16),

                    // Country Dropdown
                    Obx(() {
                      final countries = controller.getUniqueCountries();
                      if (countries.isEmpty) {
                        return TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Country',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() => selectedCountry = value);
                          },
                        );
                      }
                      
                      return DropdownButtonFormField<String>(
                        value: selectedCountry,
                        decoration: const InputDecoration(
                          labelText: 'Country',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Countries'),
                          ),
                          ...countries.map((country) {
                            return DropdownMenuItem(
                              value: country,
                              child: Text(country),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          print('🎯 Selected country: $value');
                          setState(() => selectedCountry = value);
                        },
                      );
                    }),

                    const SizedBox(height: 16),

                    // Rating Filter
                    const Text('Minimum Rating:'),
                    Slider(
                      value: minRating ?? 0.0,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      label: minRating?.toStringAsFixed(1) ?? '0.0',
                      onChanged: (value) {
                        print('🎯 Min rating: $value');
                        setState(() => minRating = value);
                      },
                    ),
                    Text(
                      minRating != null ? '${minRating!.toStringAsFixed(1)} stars' : 'Any rating',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 16),

                    // Availability Filter
                    CheckboxListTile(
                      title: const Text('Show Available Drivers Only'),
                      value: availableOnly,
                      onChanged: (value) {
                        print('🎯 Available only: $value');
                        setState(() => availableOnly = value ?? false);
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  print('❌ Cancelling driver filter dialog');
                  Get.back();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear All'),
              ),
              ElevatedButton(
                onPressed: () {
                  print('✅ Applying driver filters from dialog');
                  _applyFilters();
                  Get.back();
                },
                child: const Text('Apply Filters'),
              ),
            ],
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Drivers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFiltersDialog,
            tooltip: 'Filter Drivers',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search drivers by name, city, languages...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Statistics
            Obx(() {
              if (!controller.isLoading.value && controller.publicDrivers.isNotEmpty) {
                final available = controller.publicDrivers.where((d) => d.isAvailable).length;
                final total = controller.publicDrivers.length;
                
                print('📊 Displaying driver statistics: Available=$available, Total=$total');
                
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Total', '$total', Colors.blue),
                      _buildStatCard('Available', '$available', Colors.green),
                      _buildStatCard('Avg Rating', 
                        controller.publicDrivers.isEmpty ? '0.0' : 
                        (controller.publicDrivers.map((d) => d.ratingAverage).reduce((a, b) => a + b) / 
                         controller.publicDrivers.length).toStringAsFixed(1),
                        Colors.amber,
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            }),

            const SizedBox(height: 16),

            // Active Filters
            Obx(() {
              if (controller.filteredDrivers.length < controller.publicDrivers.length) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_alt, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Showing ${controller.filteredDrivers.length} of ${controller.publicDrivers.length} drivers',
                        style: const TextStyle(color: Colors.orange),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Clear Filters'),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            }),

            const SizedBox(height: 16),

            // Drivers List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  print('🔄 Showing driver loading indicator');
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading available drivers...'),
                      ],
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  print('❌ Showing driver error: ${controller.errorMessage.value}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Error Loading Drivers',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            controller.errorMessage.value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: controller.refresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.filteredDrivers.isEmpty) {
                  print('ℹ️ No drivers found with current filters');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.directions_car, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No Drivers Found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (controller.searchQuery.value.isNotEmpty)
                          Text(
                            'No results for "${controller.searchQuery.value}"',
                            style: const TextStyle(color: Colors.grey),
                          )
                        else
                          const Text(
                            'Try adjusting your filters',
                            style: TextStyle(color: Colors.grey),
                          ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.filter_alt_off),
                          label: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }

                print('📱 Displaying ${controller.filteredDrivers.length} drivers');
                return ListView.builder(
                  itemCount: controller.filteredDrivers.length,
                  itemBuilder: (context, index) {
                    final driver = controller.filteredDrivers[index];
                    print('📱 Building driver item $index: ${driver.displayName}');
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _showDriverDetail(driver),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Driver Avatar
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: driver.isAvailable 
                                    ? Colors.green.shade100 
                                    : Colors.grey.shade200,
                                child: Text(
                                  driver.user.fullName[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: driver.isAvailable ? Colors.green : Colors.grey,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 16),
                              
                              // Driver Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      driver.displayName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      driver.user.fullName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${driver.baseCity}, ${driver.baseCountry}',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        // Rating
                                        Row(
                                          children: [
                                            const Icon(Icons.star, size: 16, color: Colors.amber),
                                            const SizedBox(width: 4),
                                            Text(
                                              driver.ratingAverage.toStringAsFixed(1),
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '(${driver.ratingCount})',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(width: 16),
                                        
                                        // Experience
                                        Row(
                                          children: [
                                            const Icon(Icons.timelapse, size: 16, color: Colors.blue),
                                            const SizedBox(width: 4),
                                            Text(
                                              driver.experienceText,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        
                                        const Spacer(),
                                        
                                        // Rate
                                        Text(
                                          driver.hourlyRateFormatted,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 8),
                                    
                                    // Status Badges
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        if (driver.isAvailable)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: Colors.green),
                                            ),
                                            child: const Text(
                                              'AVAILABLE',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(driver.status).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: _getStatusColor(driver.status)),
                                          ),
                                          child: Text(
                                            driver.status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _getStatusColor(driver.status),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}