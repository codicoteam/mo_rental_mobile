// lib/features/modules/vehicles/controllers/vehicle_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../domain/repositories/vehicle_repository.dart';
import '../../../data/models/vehicle_models/vehicle.dart';

class VehicleController extends GetxController {
  final VehicleRepository _repository;
  final RxList<Vehicle> vehicles = <Vehicle>[].obs;
  final RxList<Vehicle> filteredVehicles = <Vehicle>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, dynamic> filters = <String, dynamic>{}.obs;
  final RxString searchQuery = ''.obs;
  
  // Add the missing properties that your UI is trying to access
  final Rx<String?> filterStatus = Rx<String?>(null);
  final RxBool filterAvailableOnly = false.obs;
  final RxBool filterActiveOnly = false.obs;
  final TextEditingController searchTextController = TextEditingController();

  VehicleController(this._repository);

  @override
  void onInit() {
    super.onInit();
    print('🚙 VehicleController initialized');
    
    // Listen to search text changes
    searchTextController.addListener(() {
      searchVehicles(searchTextController.text);
    });
    
    fetchVehicles();
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  // Add this method that your UI is calling
  void applyFilters() {
    print('🚙 Applying filters from dialog');
    
    // Map dialog values to filter method
    String? statusFilter;
    String? availabilityFilter;
    
    if (filterStatus.value == 'active') {
      statusFilter = 'active';
    } else if (filterStatus.value == 'inactive') {
      statusFilter = 'inactive';
    } else if (filterStatus.value == 'maintenance') {
      statusFilter = 'maintenance';
    } else if (filterStatus.value == 'available') {
      availabilityFilter = 'available';
    } else if (filterStatus.value == 'reserved') {
      availabilityFilter = 'reserved';
    } else if (filterStatus.value == 'rented') {
      availabilityFilter = 'rented';
    }
    
    filterVehicles(
      status: statusFilter,
      availabilityState: availabilityFilter,
      availableOnly: filterAvailableOnly.value,
      activeOnly: filterActiveOnly.value,
    );
  }

  Future<void> fetchVehicles({
    Map<String, dynamic>? customFilters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🚙 ==== STARTING VEHICLES FETCH ====');
      print('🚙 Page: $page, Limit: $limit');
      if (customFilters != null) {
        print('🚙 Custom Filters: $customFilters');
      }
      
      isLoading.value = true;
      errorMessage.value = '';
      
      final fetchedVehicles = await _repository.getAllVehicles(
        plateNumber: customFilters?['plateNumber'],
        vin: customFilters?['vin'],
        branchId: customFilters?['branchId'],
        status: customFilters?['status'],
        availabilityState: customFilters?['availabilityState'],
        color: customFilters?['color'],
        odometerMin: customFilters?['odometerMin'],
        odometerMax: customFilters?['odometerMax'],
        page: page,
        limit: limit,
      );
      
      vehicles.assignAll(fetchedVehicles);
      filteredVehicles.assignAll(fetchedVehicles);
      
      print('🚙 Successfully loaded ${vehicles.length} vehicles');
      print('🚙 Available vehicles: ${vehicles.where((v) => v.isAvailable).length}');
      print('🚙 Active vehicles: ${vehicles.where((v) => v.isActive).length}');
      print('🚙 ===== VEHICLES FETCH COMPLETE =====');
      
    } catch (e, stackTrace) {
      print('❌ ===== VEHICLES FETCH FAILED =====');
      print('❌ Error: $e');
      print('❌ Stack Trace: $stackTrace');
      print('❌ =================================');
      
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load vehicles: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void filterVehicles({
    String? branchId,
    String? status,
    String? availabilityState,
    String? color,
    int? minOdometer,
    int? maxOdometer,
    bool? availableOnly,
    bool? activeOnly,
  }) {
    print('🚙 ==== APPLYING VEHICLE FILTERS ====');
    print('🚙 Branch ID: $branchId');
    print('🚙 Status: $status');
    print('🚙 Availability: $availabilityState');
    print('🚙 Color: $color');
    print('🚙 Odometer Range: $minOdometer - $maxOdometer');
    print('🚙 Available Only: $availableOnly');
    print('🚙 Active Only: $activeOnly');
    
    filters.value = {
      'branchId': branchId,
      'status': status,
      'availabilityState': availabilityState,
      'color': color,
      'minOdometer': minOdometer,
      'maxOdometer': maxOdometer,
      'availableOnly': availableOnly,
      'activeOnly': activeOnly,
    };
    
    filteredVehicles.value = vehicles.where((vehicle) {
      bool passes = true;
      
      if (branchId != null && branchId.isNotEmpty) {
        passes = passes && vehicle.branch.id == branchId;
      }
      
      if (status != null && status.isNotEmpty) {
        passes = passes && vehicle.status == status;
      }
      
      if (availabilityState != null && availabilityState.isNotEmpty) {
        passes = passes && vehicle.availabilityState == availabilityState;
      }
      
      if (color != null && color.isNotEmpty) {
        passes = passes && vehicle.color.toLowerCase() == color.toLowerCase();
      }
      
      if (minOdometer != null) {
        passes = passes && vehicle.odometerKm >= minOdometer;
      }
      
      if (maxOdometer != null) {
        passes = passes && vehicle.odometerKm <= maxOdometer;
      }
      
      if (availableOnly == true) {
        passes = passes && vehicle.isAvailable;
      }
      
      if (activeOnly == true) {
        passes = passes && vehicle.isActive;
      }
      
      return passes;
    }).toList();
    
    print('🚙 Filtered results: ${filteredVehicles.length} out of ${vehicles.length}');
    print('🚙 ===== VEHICLE FILTERS APPLIED =====');
  }

  void clearFilters() {
    print('🚙 Clearing all vehicle filters');
    filters.clear();
    filterStatus.value = null;
    filterAvailableOnly.value = false;
    filterActiveOnly.value = false;
    searchTextController.clear();
    filteredVehicles.assignAll(vehicles);
  }

  void searchVehicles(String query) {
    print('🚙 Searching vehicles with query: "$query"');
    searchQuery.value = query;
    
    if (query.isEmpty) {
      _applyCurrentFilters();
      return;
    }
    
    final lowerQuery = query.toLowerCase();
    filteredVehicles.value = vehicles.where((vehicle) {
      final matches = 
          vehicle.plateNumber.toLowerCase().contains(lowerQuery) ||
          vehicle.vin.toLowerCase().contains(lowerQuery) ||
          vehicle.vehicleModel.make.toLowerCase().contains(lowerQuery) ||
          vehicle.vehicleModel.model.toLowerCase().contains(lowerQuery) ||
          vehicle.branch.name.toLowerCase().contains(lowerQuery) ||
          vehicle.color.toLowerCase().contains(lowerQuery);
      
      return matches && _passesCurrentFilters(vehicle);
    }).toList();
    
    print('🚙 Search results: ${filteredVehicles.length} vehicles');
  }

  void _applyCurrentFilters() {
    if (filters.isEmpty) {
      filteredVehicles.assignAll(vehicles);
      return;
    }
    
    filteredVehicles.value = vehicles.where((vehicle) {
      return _passesCurrentFilters(vehicle);
    }).toList();
  }

  bool _passesCurrentFilters(Vehicle vehicle) {
    bool passes = true;
    
    if (filters['branchId'] != null && filters['branchId'].isNotEmpty) {
      passes = passes && vehicle.branch.id == filters['branchId'];
    }
    
    if (filters['status'] != null && filters['status'].isNotEmpty) {
      passes = passes && vehicle.status == filters['status'];
    }
    
    if (filters['availabilityState'] != null && filters['availabilityState'].isNotEmpty) {
      passes = passes && vehicle.availabilityState == filters['availabilityState'];
    }
    
    if (filters['color'] != null && filters['color'].isNotEmpty) {
      passes = passes && vehicle.color.toLowerCase() == filters['color'].toString().toLowerCase();
    }
    
    if (filters['minOdometer'] != null) {
      passes = passes && vehicle.odometerKm >= filters['minOdometer'];
    }
    
    if (filters['maxOdometer'] != null) {
      passes = passes && vehicle.odometerKm <= filters['maxOdometer'];
    }
    
    if (filters['availableOnly'] == true) {
      passes = passes && vehicle.isAvailable;
    }
    
    if (filters['activeOnly'] == true) {
      passes = passes && vehicle.isActive;
    }
    
    return passes;
  }

  List<Vehicle> getVehiclesByBranch(String branchId) {
    print('🚙 Getting vehicles for branch: $branchId');
    return vehicles.where((v) => v.branch.id == branchId).toList();
  }

  List<Vehicle> getAvailableVehicles() {
    return vehicles.where((v) => v.isAvailable).toList();
  }

  List<Vehicle> getVehiclesNeedingService() {
    return vehicles.where((v) => v.needsService).toList();
  }

  @override
  void refresh() {
    print('🚙 Refreshing vehicles data');
    fetchVehicles();
  }
}