// lib/features/modules/vehicles/views/vehicles_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/vehicle_models/vehicle.dart';
import '../controllers/vehicle_controller.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final VehicleController controller = Get.find<VehicleController>();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('🚙 VehiclesScreen initialized');
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
    print('🔍 Vehicle search query changed: "$query"');
    controller.searchVehicles(query);
  }

  void _showVehicleDetail(Vehicle vehicle) {
    print('📱 Showing detail for vehicle: ${vehicle.displayName}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vehicle.displayName),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Vehicle Image
              if (vehicle.photos.isNotEmpty)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(vehicle.photos.first),
                      fit: BoxFit.cover,
                      onError: (error, stackTrace) {
                        print('❌ Error loading vehicle photo: $error');
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Vehicle Info
              _buildDetailRow('Plate Number', vehicle.plateNumber),
              _buildDetailRow('VIN', vehicle.vin),
              _buildDetailRow('Model', vehicle.vehicleModel.fullName),
              _buildDetailRow('Branch', vehicle.locationInfo),
              _buildDetailRow('Color', vehicle.color),
              _buildDetailRow('Odometer', '${vehicle.odometerKm} km'),
              _buildDetailRow('Status', vehicle.status),
              _buildDetailRow('Availability', vehicle.availabilityState),

              const SizedBox(height: 8),

              // Status Indicators
              Row(
                children: [
                  _buildStatusIndicator('Available', vehicle.isAvailable, Colors.green),
                  const SizedBox(width: 8),
                  _buildStatusIndicator('Active', vehicle.isActive, Colors.blue),
                  const SizedBox(width: 8),
                  _buildStatusIndicator('Needs Service', vehicle.needsService, Colors.orange),
                ],
              ),

              const SizedBox(height: 16),

              // Features
              if (vehicle.vehicleModel.features.isNotEmpty) ...[
                const Text(
                  'Features:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 8,
                  children: vehicle.vehicleModel.features.map((feature) {
                    return Chip(
                      label: Text(feature),
                      backgroundColor: Colors.blue.shade50,
                    );
                  }).toList(),
                ),
              ],
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
        children: [
          SizedBox(
            width: 100,
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

  Widget _buildStatusIndicator(String label, bool isTrue, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isTrue ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isTrue ? color : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isTrue ? color : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isTrue ? color : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showFiltersDialog() {
    print('🎯 Showing vehicle filters dialog');
    showDialog(
      context: context,
      builder: (context) {
        String? selectedStatus;
        String? selectedAvailability;
        bool availableOnly = false;
        bool activeOnly = false;

        return AlertDialog(
          title: const Text('Filter Vehicles'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status Filter
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Text('All Status'),
                      ),
                      DropdownMenuItem(
                        value: 'active',
                        child: Text('Active'),
                      ),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text('Inactive'),
                      ),
                      DropdownMenuItem(
                        value: 'maintenance',
                        child: Text('Maintenance'),
                      ),
                    ],
                    onChanged: (value) {
                      print('🎯 Selected status: $value');
                      selectedStatus = value;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Availability Filter
                  DropdownButtonFormField<String>(
                    value: selectedAvailability,
                    decoration: const InputDecoration(
                      labelText: 'Availability',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: null,
                        child: Text('All Availability'),
                      ),
                      DropdownMenuItem(
                        value: 'available',
                        child: Text('Available'),
                      ),
                      DropdownMenuItem(
                        value: 'reserved',
                        child: Text('Reserved'),
                      ),
                      DropdownMenuItem(
                        value: 'rented',
                        child: Text('Rented'),
                      ),
                      DropdownMenuItem(
                        value: 'maintenance',
                        child: Text('Maintenance'),
                      ),
                    ],
                    onChanged: (value) {
                      print('🎯 Selected availability: $value');
                      selectedAvailability = value;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Quick Filters
                  CheckboxListTile(
                    title: const Text('Show Available Only'),
                    value: availableOnly,
                    onChanged: (value) {
                      print('🎯 Available only: $value');
                      availableOnly = value ?? false;
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Show Active Only'),
                    value: activeOnly,
                    onChanged: (value) {
                      print('🎯 Active only: $value');
                      activeOnly = value ?? false;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('❌ Cancelling vehicle filter dialog');
                Get.back();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                print('🧹 Clearing vehicle filters');
                controller.clearFilters();
                Get.back();
              },
              child: const Text('Clear All'),
            ),
            ElevatedButton(
              onPressed: () {
                print('✅ Applying vehicle filters');
                controller.filterVehicles(
                  status: selectedStatus,
                  availabilityState: selectedAvailability,
                  availableOnly: availableOnly,
                  activeOnly: activeOnly,
                );
                Get.back();
              },
              child: const Text('Apply Filters'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Fleet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFiltersDialog,
            tooltip: 'Filter Vehicles',
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
                hintText: 'Search vehicles by plate, VIN, model, branch...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Statistics
            Obx(() {
              if (!controller.isLoading.value && controller.vehicles.isNotEmpty) {
                final available = controller.getAvailableVehicles().length;
                final needService = controller.getVehiclesNeedingService().length;
                
                print('📊 Displaying statistics: Available=$available, NeedService=$needService');
                
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard('Total', '${controller.vehicles.length}', Colors.blue),
                      _buildStatCard('Available', '$available', Colors.green),
                      _buildStatCard('Need Service', '$needService', Colors.orange),
                    ],
                  ),
                );
              }
              return const SizedBox();
            }),

            const SizedBox(height: 16),

            // Vehicles List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  print('🔄 Showing vehicle loading indicator');
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading vehicle fleet...'),
                      ],
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  print('❌ Showing vehicle error: ${controller.errorMessage.value}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Error Loading Vehicles',
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

                if (controller.filteredVehicles.isEmpty) {
                  print('ℹ️ No vehicles found with current filters');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.directions_car, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No Vehicles Found',
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
                          onPressed: controller.clearFilters,
                          icon: const Icon(Icons.filter_alt_off),
                          label: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  );
                }

                print('📱 Displaying ${controller.filteredVehicles.length} vehicles');
                return ListView.builder(
                  itemCount: controller.filteredVehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = controller.filteredVehicles[index];
                    print('📱 Building vehicle item $index: ${vehicle.displayName}');
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _showVehicleDetail(vehicle),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Vehicle Icon/Status
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: vehicle.isAvailable 
                                      ? Colors.green.shade50 
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: vehicle.isAvailable 
                                        ? Colors.green 
                                        : Colors.red,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.directions_car,
                                        color: vehicle.isAvailable 
                                            ? Colors.green 
                                            : Colors.red,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        vehicle.availabilityState.substring(0, 3).toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: vehicle.isAvailable 
                                              ? Colors.green 
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              const SizedBox(width: 16),
                              
                              // Vehicle Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vehicle.displayName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      vehicle.vehicleModel.displayInfo,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${vehicle.branch.name} • ${vehicle.color} • ${vehicle.odometerKm} km',
                                      style: const TextStyle(
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        if (vehicle.needsService)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade50,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: Colors.orange),
                                            ),
                                            child: const Text(
                                              'NEEDS SERVICE',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ),
                                        if (!vehicle.isActive)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade50,
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: Colors.red),
                                            ),
                                            child: const Text(
                                              'INACTIVE',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red,
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