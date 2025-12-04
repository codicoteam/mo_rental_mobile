import 'dart:math'; // ADD THIS IMPORT
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/auth_models/api_response.dart';
import '../../../data/models/rate_plan/rate_plan_request.dart';
import '../../../data/models/rate_plan/rate_plan_response.dart';
import '../../../data/services/rate_plan_service.dart';

class RatePlanController extends GetxController {
  final RatePlanService _ratePlanService = Get.find<RatePlanService>();
  final GetStorage _storage = GetStorage();
  
  // Reactive state
  final RxList<RatePlan> ratePlans = <RatePlan>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;
  
  // Filters
  final RxString selectedBranch = ''.obs;
  final RxString selectedVehicleClass = ''.obs;
  final RxString selectedCurrency = 'USD'.obs;
  final RxBool showActiveOnly = true.obs;
  final RxString selectedDate = ''.obs;
  
  // Search
  final RxString searchQuery = ''.obs;
  
  // Available options
  final List<String> vehicleClasses = [
    'economy',
    'compact', 
    'midsize',
    'suv',
    'luxury',
    'van',
    'truck',
  ];
  
  final List<String> currencies = ['USD', 'ZWL'];
  
  @override
  void onInit() {
    super.onInit();
    print('📊 RatePlanController initialized');
    // Load rate plans if user is authenticated
    if (isAuthenticated) {
      loadRatePlans();
    }
  }
  
  bool get isAuthenticated => _storage.read('auth_token') != null;
  String? get authToken => _storage.read('auth_token');
  
Future<void> loadRatePlans({int page = 1}) async {
  if (!isAuthenticated) {
    errorMessage.value = 'Please login to view rate plans';
    Get.snackbar(
      'Authentication Required',
      'Please login to view rate plans',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
    );
    return;
  }
  
  isLoading.value = true;
  errorMessage.value = '';
  
  try {
    print('\n📊 ========== LOADING RATE PLANS ==========');
    print('📊 Page: $page');
    print('🔑 Auth Token Present: ${authToken != null}');
    if (authToken != null) {
      // FIX: Use min from dart:math
      final tokenLength = min(30, authToken!.length);
      print('🔑 Token (first 30 chars): ${authToken!.substring(0, tokenLength)}...');
    }
    
    final request = RatePlanRequest(
      branchId: selectedBranch.value.isNotEmpty ? selectedBranch.value : null,
      vehicleClass: selectedVehicleClass.value.isNotEmpty ? selectedVehicleClass.value : null,
      currency: selectedCurrency.value,
      active: showActiveOnly.value,
      validOn: selectedDate.value.isNotEmpty ? selectedDate.value : null,
      page: page,
      limit: 10,
    );
    
    print('📋 Query Params: ${request.toQueryParams()}');
    
    final response = await _ratePlanService.getRatePlans(
      token: authToken!,
      request: request,
    );
    
    print('\n📊 ========== RATE PLANS RESPONSE ==========');
    print('📊 Success: ${response.success}');
    print('📊 Message: ${response.message}');
    print('📊 Error: ${response.error}');
    print('📊 Plans count: ${response.data?.plans.length ?? 0}');
    print('📊 ======================================\n');
    
    if (response.success && response.data != null) {
      if (page == 1) {
        ratePlans.value = response.data!.plans;
      } else {
        ratePlans.addAll(response.data!.plans);
      }
      
      currentPage.value = response.data!.pagination.page;
      totalPages.value = response.data!.pagination.totalPages;
      totalItems.value = response.data!.pagination.total;
      
      Get.snackbar(
        'Success',
        'Loaded ${response.data!.plans.length} rate plans',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
    } else {
      errorMessage.value = response.message;
      
      // FIX: Check if response.message is not null before checking contains
      final message = response.message;
      if (message.contains('Access denied') ||
          message.contains('admin') ||
          message.contains('manager')) {
        errorMessage.value = 'Access denied. Only managers/admins can view rate plans.';
        Get.snackbar(
          'Access Denied',
          'Only managers/admins can view rate plans.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'Error',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  } catch (e) {
    print('\n🔥 ========== RATE PLANS EXCEPTION ==========');
    print('🔥 Error: $e');
    print('🔥 StackTrace: ${e.toString()}');
    print('🔥 =======================================\n');
    
    errorMessage.value = e.toString();
    Get.snackbar(
      'Error',
      'Failed to load rate plans: $e',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isLoading.value = false;
  }
}
  
  Future<void> loadMore() async {
    if (currentPage.value < totalPages.value && !isLoading.value) {
      await loadRatePlans(page: currentPage.value + 1);
    }
  }
  
  void applyFilters() {
    print('🔍 Applying filters');
    print('📍 Branch: ${selectedBranch.value}');
    print('🚗 Class: ${selectedVehicleClass.value}');
    print('💰 Currency: ${selectedCurrency.value}');
    print('✅ Active Only: ${showActiveOnly.value}');
    print('📅 Date: ${selectedDate.value}');
    
    // Reset to first page and reload
    currentPage.value = 1;
    loadRatePlans();
  }
  
  void clearFilters() {
    selectedBranch.value = '';
    selectedVehicleClass.value = '';
    selectedCurrency.value = 'USD';
    showActiveOnly.value = true;
    selectedDate.value = '';
    searchQuery.value = '';
    
    applyFilters();
  }
  
  void searchPlans(String query) {
    searchQuery.value = query;
    // In a real app, you might want to debounce this or call API with search
    // For now, we'll just filter locally
  }
  
  List<RatePlan> get filteredPlans {
    if (searchQuery.value.isEmpty) {
      return ratePlans;
    }
    
    return ratePlans.where((plan) {
      return plan.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
             plan.description.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
             plan.vehicleClass.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }
  
  // CRUD Operations
  Future<ApiResponse<RatePlan>> createPlan(Map<String, dynamic> data) async {
    if (!isAuthenticated) {
      return ApiResponse(
        success: false,
        message: 'Authentication required',
      );
    }
    
    isLoading.value = true;
    
    try {
      final response = await _ratePlanService.createRatePlan(
        token: authToken!,
        data: data,
      );
      
      if (response.success && response.data != null) {
        // Add to list
        ratePlans.insert(0, response.data!);
        Get.snackbar(
          'Success',
          'Rate plan created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
      return response;
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<ApiResponse<RatePlan>> updatePlan(String planId, Map<String, dynamic> data) async {
    if (!isAuthenticated) {
      return ApiResponse(
        success: false,
        message: 'Authentication required',
      );
    }
    
    isLoading.value = true;
    
    try {
      final response = await _ratePlanService.updateRatePlan(
        token: authToken!,
        planId: planId,
        data: data,
      );
      
      if (response.success && response.data != null) {
        // Update in list
        final index = ratePlans.indexWhere((p) => p.id == planId);
        if (index != -1) {
          ratePlans[index] = response.data!;
          ratePlans.refresh();
        }
        
        Get.snackbar(
          'Success',
          'Rate plan updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
      return response;
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<ApiResponse<void>> deletePlan(String planId) async {
    if (!isAuthenticated) {
      return ApiResponse(
        success: false,
        message: 'Authentication required',
      );
    }
    
    isLoading.value = true;
    
    try {
      final response = await _ratePlanService.deleteRatePlan(
        token: authToken!,
        planId: planId,
      );
      
      if (response.success) {
        // Remove from list
        ratePlans.removeWhere((p) => p.id == planId);
        Get.snackbar(
          'Success',
          'Rate plan deleted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
      
      return response;
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}