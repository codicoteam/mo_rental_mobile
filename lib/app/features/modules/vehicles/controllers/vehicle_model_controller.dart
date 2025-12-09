// lib/features/modules/vehicles/controllers/vehicle_model_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../domain/repositories/vehicle_model_repository.dart';
import '../../../data/models/vehicle_models/vehicle_model.dart';

class VehicleModelController extends GetxController {
  final VehicleModelRepository _repository;
  final RxList<VehicleModel> vehicleModels = <VehicleModel>[].obs;
  final RxList<VehicleModel> filteredModels = <VehicleModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, List<String>> filters = <String, List<String>>{
    'make': [],
    'class': [],
    'transmission': [],
    'fuelType': [],
  }.obs;

  VehicleModelController(this._repository);

  @override
  void onInit() {
    super.onInit();
    print('🚗 VehicleModelController initialized');
    fetchVehicleModels();
  }

  Future<void> fetchVehicleModels({
    Map<String, dynamic>? customFilters,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🚗 ==== STARTING VEHICLE MODELS FETCH ====');
      print('🚗 Page: $page, Limit: $limit');
      if (customFilters != null) {
        print('🚗 Custom Filters: $customFilters');
      }
      
      isLoading.value = true;
      errorMessage.value = '';
      
      final models = await _repository.getAllVehicleModels(
        page: page,
        limit: limit,
      );
      
      vehicleModels.assignAll(models);
      filteredModels.assignAll(models);
      
      // Extract unique values for filters
      _extractFilterValues(models);
      
      print('🚗 Successfully loaded ${models.length} vehicle models');
      print('🚗 Unique makes: ${filters['make']}');
      print('🚗 Unique classes: ${filters['class']}');
      print('🚗 ===== VEHICLE MODELS FETCH COMPLETE =====');
      
    } catch (e, stackTrace) {
      print('❌ ===== VEHICLE MODELS FETCH FAILED =====');
      print('❌ Error: $e');
      print('❌ Stack Trace: $stackTrace');
      print('❌ ======================================');
      
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load vehicle models: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _extractFilterValues(List<VehicleModel> models) {
    final makes = <String>{};
    final classes = <String>{};
    final transmissions = <String>{};
    final fuelTypes = <String>{};
    
    for (final model in models) {
      makes.add(model.make);
      classes.add(model.vehicleClass);
      transmissions.add(model.transmission);
      fuelTypes.add(model.fuelType);
    }
    
    filters['make'] = makes.toList()..sort();
    filters['class'] = classes.toList()..sort();
    filters['transmission'] = transmissions.toList()..sort();
    filters['fuelType'] = fuelTypes.toList()..sort();
  }

  void filterModels({
    String? selectedMake,
    String? selectedClass,
    String? selectedTransmission,
    String? selectedFuelType,
    int? minSeats,
    int? maxSeats,
  }) {
    print('🚗 ==== APPLYING FILTERS ====');
    print('🚗 Make: $selectedMake');
    print('🚗 Class: $selectedClass');
    print('🚗 Transmission: $selectedTransmission');
    print('🚗 Fuel Type: $selectedFuelType');
    print('🚗 Min Seats: $minSeats, Max Seats: $maxSeats');
    
    filteredModels.value = vehicleModels.where((model) {
      bool passes = true;
      
      if (selectedMake != null && selectedMake.isNotEmpty) {
        passes = passes && model.make == selectedMake;
      }
      
      if (selectedClass != null && selectedClass.isNotEmpty) {
        passes = passes && model.vehicleClass == selectedClass;
      }
      
      if (selectedTransmission != null && selectedTransmission.isNotEmpty) {
        passes = passes && model.transmission == selectedTransmission;
      }
      
      if (selectedFuelType != null && selectedFuelType.isNotEmpty) {
        passes = passes && model.fuelType == selectedFuelType;
      }
      
      if (minSeats != null) {
        passes = passes && model.seats >= minSeats;
      }
      
      if (maxSeats != null) {
        passes = passes && model.seats <= maxSeats;
      }
      
      return passes;
    }).toList();
    
    print('🚗 Filtered results: ${filteredModels.length} out of ${vehicleModels.length}');
    print('🚗 ===== FILTERS APPLIED =====');
  }

  void clearFilters() {
    print('🚗 Clearing all filters');
    filteredModels.assignAll(vehicleModels);
  }

  List<VehicleModel> searchModels(String query) {
    print('🚗 Searching models with query: "$query"');
    
    if (query.isEmpty) {
      return filteredModels;
    }
    
    final lowerQuery = query.toLowerCase();
    return filteredModels.where((model) {
      return model.make.toLowerCase().contains(lowerQuery) ||
             model.model.toLowerCase().contains(lowerQuery) ||
             model.fullName.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}