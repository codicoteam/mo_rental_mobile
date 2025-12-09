// lib/features/modules/vehicles/views/vehicle_models_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vehicle_model_controller.dart';

class VehicleModelsScreen extends StatefulWidget {
  const VehicleModelsScreen({super.key});

  @override
  State<VehicleModelsScreen> createState() => _VehicleModelsScreenState();
}

class _VehicleModelsScreenState extends State<VehicleModelsScreen> {
  final VehicleModelController controller = Get.find<VehicleModelController>();
  final TextEditingController searchController = TextEditingController();
  String? selectedMake;
  String? selectedClass;
  String? selectedTransmission;
  String? selectedFuelType;
  int? minSeats;
  int? maxSeats;

  @override
  void initState() {
    super.initState();
    print('🚗 VehicleModelsScreen initialized');
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
    print('🔍 Search query changed: "$query"');
    _applyFilters();
  }

  void _applyFilters() {
    print('🔍 Applying filters...');
    controller.filterModels(
      selectedMake: selectedMake,
      selectedClass: selectedClass,
      selectedTransmission: selectedTransmission,
      selectedFuelType: selectedFuelType,
      minSeats: minSeats,
      maxSeats: maxSeats,
    );
  }

  void _clearFilters() {
    print('🧹 Clearing all filters');
    searchController.clear();
    selectedMake = null;
    selectedClass = null;
    selectedTransmission = null;
    selectedFuelType = null;
    minSeats = null;
    maxSeats = null;
    controller.clearFilters();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Models'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Models',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchVehicleModels,
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
                hintText: 'Search models...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                final results = controller.searchModels(value);
                print('🔍 Found ${results.length} models matching "$value"');
              },
            ),

            const SizedBox(height: 16),

            // Active Filters
            Obx(() {
              if (controller.filteredModels.length < controller.vehicleModels.length) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_alt, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Showing ${controller.filteredModels.length} of ${controller.vehicleModels.length} models',
                        style: const TextStyle(color: Colors.blue),
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

            // Models List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  print('🔄 Showing loading indicator');
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading vehicle models...'),
                      ],
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  print('❌ Showing error: ${controller.errorMessage.value}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Error Loading Models',
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
                          onPressed: controller.fetchVehicleModels,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.filteredModels.isEmpty) {
                  print('ℹ️ No models found');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.car_repair, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No Vehicle Models Found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
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

                print('📱 Displaying ${controller.filteredModels.length} models');
                return ListView.builder(
                  itemCount: controller.filteredModels.length,
                  itemBuilder: (context, index) {
                    final model = controller.filteredModels[index];
                    print('📱 Building list item $index: ${model.fullName}');
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Model Image/Icon
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: model.images.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            model.images.first,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              print('❌ Error loading image: $error');
                                              return const Icon(Icons.directions_car, color: Colors.blue);
                                            },
                                          ),
                                        )
                                      : const Icon(Icons.directions_car, color: Colors.blue),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        model.fullName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        model.displayInfo,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        children: model.features.map((feature) {
                                          return Chip(
                                            label: Text(feature),
                                            backgroundColor: Colors.blue.shade50,
                                            labelStyle: const TextStyle(fontSize: 12),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  void _showFilterDialog() {
    print('🎯 Showing filter dialog');
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Models'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Make Dropdown
                      Obx(() {
                        return DropdownButtonFormField<String>(
                          value: selectedMake,
                          decoration: const InputDecoration(
                            labelText: 'Make',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Makes'),
                            ),
                            ...?controller.filters['make']?.map((make) {
                              return DropdownMenuItem(
                                value: make,
                                child: Text(make),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            print('🎯 Selected make: $value');
                            setState(() => selectedMake = value);
                          },
                        );
                      }),

                      const SizedBox(height: 16),

                      // Class Dropdown
                      Obx(() {
                        return DropdownButtonFormField<String>(
                          value: selectedClass,
                          decoration: const InputDecoration(
                            labelText: 'Class',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Classes'),
                            ),
                            ...controller.filters['class']!.map((vehicleClass) {
                              return DropdownMenuItem(
                                value: vehicleClass,
                                child: Text(vehicleClass),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            print('🎯 Selected class: $value');
                            setState(() => selectedClass = value);
                          },
                        );
                      }),

                      const SizedBox(height: 16),

                      // Transmission Dropdown
                      Obx(() {
                        return DropdownButtonFormField<String>(
                          value: selectedTransmission,
                          decoration: const InputDecoration(
                            labelText: 'Transmission',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Transmissions'),
                            ),
                            ...controller.filters['transmission']!.map((transmission) {
                              return DropdownMenuItem(
                                value: transmission,
                                child: Text(transmission),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            print('🎯 Selected transmission: $value');
                            setState(() => selectedTransmission = value);
                          },
                        );
                      }),

                      const SizedBox(height: 16),

                      // Fuel Type Dropdown
                      Obx(() {
                        return DropdownButtonFormField<String>(
                          value: selectedFuelType,
                          decoration: const InputDecoration(
                            labelText: 'Fuel Type',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Fuel Types'),
                            ),
                            ...controller.filters['fuelType']!.map((fuelType) {
                              return DropdownMenuItem(
                                value: fuelType,
                                child: Text(fuelType),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            print('🎯 Selected fuel type: $value');
                            setState(() => selectedFuelType = value);
                          },
                        );
                      }),

                      const SizedBox(height: 16),

                      // Seats Range
                      const Text('Seats Range:'),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Min',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                minSeats = int.tryParse(value);
                                print('🎯 Min seats: $minSeats');
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('to'),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Max',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                maxSeats = int.tryParse(value);
                                print('🎯 Max seats: $maxSeats');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    print('❌ Cancelling filter dialog');
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
                    print('✅ Applying filters from dialog');
                    _applyFilters();
                    Get.back();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}