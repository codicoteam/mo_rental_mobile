// features/modules/branches/controllers/branch_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../domain/repositories/branch_repository.dart';
import '../../../data/models/branch_models/branch_models.dart';

class BranchController extends GetxController {
  late BranchRepository _repository;

  final RxList<Branch> branchesList = <Branch>[].obs;
  final RxList<Branch> filteredBranches = <Branch>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final Rx<Branch?> selectedBranch = Rx<Branch?>(null);
  final RxMap<String, bool> branchOpenStatus = <String, bool>{}.obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedCity = ''.obs;
  final RxString selectedRegion = ''.obs;
  
  // Add these properties to BranchController class
  final RxList<Branch> nearbyBranches = <Branch>[].obs;
  final RxBool isLoadingNearby = false.obs;
  final RxString nearbyError = ''.obs;
  final RxDouble currentLatitude = 0.0.obs;
  final RxDouble currentLongitude = 0.0.obs;
  final RxInt searchRadius = 5000.obs; // Default 5km

  @override
  void onInit() {
    super.onInit();
    _repository = BranchRepository();
    print('🏢 BranchController initialized');
    
    // Load branches automatically
    fetchBranches();
  }

  // Fetch all branches
  Future<void> fetchBranches() async {
    try {
      isLoading.value = true;
      error.value = '';
      branchesList.clear();
      filteredBranches.clear();

      final branches = await _repository.getAllBranches();
      branchesList.assignAll(branches);
      filteredBranches.assignAll(branches);
      
      print('✅ Fetched ${branches.length} branch(es)');
      
      // Pre-check open status for active branches
      await _checkOpenStatusForActiveBranches();
    } catch (e) {
      error.value = e.toString();
      print('❌ Error fetching branches: $e');
      Get.snackbar(
        'Fetch Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Getter to access branches
  List<Branch> get branches => branchesList.toList();

  // Calculate distance for all branches and sort them
  Future<void> calculateDistanceForAllBranches() async {
    try {
      if (currentLatitude.value == 0.0 || currentLongitude.value == 0.0) return;

      // Sort branchesList by distance
      branchesList.sort((a, b) {
        final distanceA = getDistanceToBranch(a);
        final distanceB = getDistanceToBranch(b);
        
        // Parse distances (e.g., "55.3 km" -> 55.3)
        final numA = _parseDistanceToNumber(distanceA);
        final numB = _parseDistanceToNumber(distanceB);
        
        return numA.compareTo(numB);
      });
      
      branchesList.refresh();
    } catch (e) {
      print('❌ Error calculating distances: $e');
    }
  }

  double _parseDistanceToNumber(String distance) {
    try {
      if (distance.contains('km')) {
        final value = double.tryParse(distance.split(' ')[0]) ?? 0.0;
        return value * 1000; // Convert km to meters for comparison
      } else if (distance.contains('m') && !distance.contains('km')) {
        return double.tryParse(distance.split(' ')[0]) ?? 0.0;
      }
      return 0.0;
    } catch (e) {
      return 0.0;
    }
  }

  // Search branches
  Future<void> searchBranches({
    String? city,
    String? region,
    bool? active,
    String? query,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      filteredBranches.clear();

      final branches = await _repository.searchBranches(
        city: city,
        region: region,
        active: active,
        query: query,
      );
      filteredBranches.assignAll(branches);
      
      print('🔍 Found ${branches.length} branch(es) for search');
    } catch (e) {
      error.value = e.toString();
      print('❌ Error searching branches: $e');
      Get.snackbar(
        'Search Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check if a branch is open
  Future<bool> checkBranchOpen(String branchId, {DateTime? at}) async {
    try {
      final status = await _repository.checkBranchOpenStatus(
        branchId: branchId,
        at: at,
      );
      branchOpenStatus[branchId] = status.open;
      return status.open;
    } catch (e) {
      print('❌ Error checking branch open status: $e');
      return false;
    }
  }

  // Check open status for all active branches
  Future<void> _checkOpenStatusForActiveBranches() async {
    try {
      final activeBranches = getActiveBranches();
      
      for (final branch in activeBranches.take(5)) { // Limit to 5 to avoid too many requests
        try {
          final isOpen = await checkBranchOpen(branch.id);
          print('🏪 Branch ${branch.name} is ${isOpen ? "OPEN" : "CLOSED"}');
        } catch (e) {
          print('⚠️ Could not check status for ${branch.name}: $e');
        }
      }
    } catch (e) {
      print('❌ Error checking open status: $e');
    }
  }

  // Get active branches
  List<Branch> getActiveBranches() {
    return branchesList.where((branch) => branch.active).toList();
  }

  // Get branches by city
  List<Branch> getBranchesByCity(String city) {
    return branchesList.where((branch) => 
      branch.city.toLowerCase() == city.toLowerCase()
    ).toList();
  }

  // Get branches by region
  List<Branch> getBranchesByRegion(String region) {
    return branchesList.where((branch) => 
      branch.region.toLowerCase() == region.toLowerCase()
    ).toList();
  }

  // Filter branches by search query
  void filterBranches(String query) {
    searchQuery.value = query;
    
    if (query.isEmpty) {
      filteredBranches.assignAll(branchesList);
      return;
    }
    
    final filtered = branchesList.where((branch) {
      return branch.name.toLowerCase().contains(query.toLowerCase()) ||
             branch.code.toLowerCase().contains(query.toLowerCase()) ||
             branch.city.toLowerCase().contains(query.toLowerCase()) ||
             branch.region.toLowerCase().contains(query.toLowerCase()) ||
             branch.address.fullAddress.toLowerCase().contains(query.toLowerCase());
    }).toList();
    
    filteredBranches.assignAll(filtered);
  }

  // Select a branch
  void selectBranch(Branch branch) {
    selectedBranch.value = branch;
    print('📍 Selected branch: ${branch.name}');
  }

  // Clear selection
  void clearSelection() {
    selectedBranch.value = null;
  }

  // Get all unique cities
  List<String> get uniqueCities {
    final cities = branchesList.map((branch) => branch.city).toSet().toList();
    cities.sort();
    return cities;
  }

  // Get all unique regions
  List<String> get uniqueRegions {
    final regions = branchesList.map((branch) => branch.region).toSet().toList();
    regions.sort();
    return regions;
  }

  // Get today's hours for a branch
  String getTodayHours(Branch branch) {
    return branch.openingHours.todayHours;
  }

  // Check if branch is open now (cached)
  bool isBranchOpenNow(String branchId) {
    return branchOpenStatus[branchId] ?? false;
  }

  // Refresh branches
  Future<void> refreshBranches() async {
    await fetchBranches();
  }

  // Get default branch (first active branch)
  Branch? get defaultBranch {
    final active = getActiveBranches();
    return active.isNotEmpty ? active.first : null;
  }

  // Get branch by ID
  Branch? getBranchById(String id) {
    try {
      return branchesList.firstWhere((branch) => branch.id == id);
    } catch (e) {
      return null;
    }
  }

  // Format address for display
  String formatAddress(Branch branch) {
    return branch.address.fullAddress;
  }

  // Format contact info
  String formatContact(Branch branch) {
    return '📞 ${branch.phone}\n✉️ ${branch.email}';
  }

  // Get status color
  Color getStatusColor(Branch branch) {
    return branch.statusColor;
  }

  // Get status text
  String getStatusText(Branch branch) {
    return branch.statusText;
  }

  Future<void> findNearbyBranches({
    double? latitude,
    double? longitude,
    int? radius,
  }) async {
    try {
      isLoadingNearby.value = true;
      nearbyError.value = '';
      nearbyBranches.clear();

      // Use provided coordinates or current coordinates
      final lat = latitude ?? currentLatitude.value;
      final lng = longitude ?? currentLongitude.value;
      final searchRadiusValue = radius ?? searchRadius.value;

      // Validate coordinates
      if (lat == 0.0 || lng == 0.0) {
        throw Exception('Location not available. Please enable location services.');
      }

      print('📍 Finding branches near: lat=$lat, lng=$lng, radius=${searchRadiusValue}m');

      final branches = await _repository.getNearbyBranches(
        latitude: lat,
        longitude: lng,
        maxDistance: searchRadiusValue,
      );

      // Sort by distance
      branches.sort((a, b) {
        final distanceA = _repository.calculateDistance(
          lat, lng, a.geo.latitude, a.geo.longitude,
        );
        final distanceB = _repository.calculateDistance(
          lat, lng, b.geo.latitude, b.geo.longitude,
        );
        return distanceA.compareTo(distanceB);
      });

      nearbyBranches.assignAll(branches);
      
      print('✅ Found ${branches.length} nearby branch(es)');
      
      if (branches.isEmpty) {
        Get.snackbar(
          'No Branches Nearby',
          'No branches found within ${searchRadiusValue ~/ 1000}km',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      nearbyError.value = e.toString();
      print('❌ Error finding nearby branches: $e');
      Get.snackbar(
        'Location Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingNearby.value = false;
    }
  }

  // Update user location
  void updateUserLocation(double latitude, double longitude) {
    currentLatitude.value = latitude;
    currentLongitude.value = longitude;
    print('📍 User location updated: lat=$latitude, lng=$longitude');
  }

  // Get distance to a branch
  String getDistanceToBranch(Branch branch) {
    if (currentLatitude.value == 0.0 || currentLongitude.value == 0.0) {
      return 'Distance unknown';
    }
    
    final distance = _repository.calculateDistance(
      currentLatitude.value,
      currentLongitude.value,
      branch.geo.latitude,
      branch.geo.longitude,
    );
    
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)}m away';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km away';
    }
  }

  // Get formatted distance for display
  String getFormattedDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)}m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)}km';
    }
  }

  // Get branches sorted by distance
  List<Branch> getBranchesSortedByDistance() {
    if (currentLatitude.value == 0.0 || currentLongitude.value == 0.0) {
      return branchesList.toList();
    }
    
    final sortedBranches = branchesList.toList();
    sortedBranches.sort((a, b) {
      final distanceA = _repository.calculateDistance(
        currentLatitude.value,
        currentLongitude.value,
        a.geo.latitude,
        a.geo.longitude,
      );
      final distanceB = _repository.calculateDistance(
        currentLatitude.value,
        currentLongitude.value,
        b.geo.latitude,
        b.geo.longitude,
      );
      return distanceA.compareTo(distanceB);
    });
    
    return sortedBranches;
  }

  // Set search radius
  void setSearchRadius(int radiusInMeters) {
    searchRadius.value = radiusInMeters;
    print('📏 Search radius set to: ${radiusInMeters}m');
  }

  // Get nearby active branches (with distance calculation)
  List<Map<String, dynamic>> getNearbyActiveBranches() {
    if (currentLatitude.value == 0.0 || currentLongitude.value == 0.0) {
      return [];
    }
    
    final activeBranches = getActiveBranches();
    final result = <Map<String, dynamic>>[];
    
    for (final branch in activeBranches) {
      final distance = _repository.calculateDistance(
        currentLatitude.value,
        currentLongitude.value,
        branch.geo.latitude,
        branch.geo.longitude,
      );
      
      if (distance <= searchRadius.value) {
        result.add({
          'branch': branch,
          'distance': distance,
          'formattedDistance': getFormattedDistance(distance),
        });
      }
    }
    
    // Sort by distance
    result.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
    
    return result;
  }

  // Clear nearby search
  void clearNearbySearch() {
    nearbyBranches.clear();
    nearbyError.value = '';
  }
}