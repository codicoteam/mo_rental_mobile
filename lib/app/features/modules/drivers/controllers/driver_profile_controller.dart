// Update lib/features/modules/drivers/controllers/driver_profile_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../../domain/repositories/driver_profile_repository.dart';
import '../../../data/models/drivers_models/driver_profile.dart';

class DriverProfileController extends GetxController {
  final DriverProfileRepository _repository;
  final RxList<DriverProfile> publicDrivers = <DriverProfile>[].obs;
  final Rx<DriverProfile?> myDriverProfile = Rx<DriverProfile?>(null);
  final RxList<DriverProfile> filteredDrivers = <DriverProfile>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingProfile = false.obs;
  final RxBool isCreatingProfile = false.obs;
  final RxBool isUpdatingProfile = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString profileError = ''.obs;
  final RxMap<String, dynamic> filters = <String, dynamic>{
    'baseCity': '',
    'baseCountry': '',
    'minRating': null,
  }.obs;
  final RxString searchQuery = ''.obs;

  DriverProfileController(this._repository);

  @override
  void onInit() {
    super.onInit();
    print('🚕 DriverProfileController initialized');
    fetchPublicDrivers();
    fetchMyDriverProfile();
  }


   // Get unique cities for filter dropdowns
  List<String> getUniqueCities() {
    try {
      final cities = publicDrivers.map((d) => d.baseCity).toSet().toList();
      cities.sort();
      print('🚕 Unique cities found: ${cities.length}');
      return cities;
    } catch (e) {
      print('❌ Error getting unique cities: $e');
      return [];
    }
  }
  
  // Get unique countries for filter dropdowns
  List<String> getUniqueCountries() {
    try {
      final countries = publicDrivers.map((d) => d.baseCountry).toSet().toList();
      countries.sort();
      print('🚕 Unique countries found: ${countries.length}');
      return countries;
    } catch (e) {
      print('❌ Error getting unique countries: $e');
      return [];
    }
  }
  
  // Get unique languages for filter dropdowns (optional)
  List<String> getUniqueLanguages() {
    try {
      final languages = <String>{};
      for (final driver in publicDrivers) {
        languages.addAll(driver.languages);
      }
      final sortedLanguages = languages.toList()..sort();
      print('🚕 Unique languages found: ${sortedLanguages.length}');
      return sortedLanguages;
    } catch (e) {
      print('❌ Error getting unique languages: $e');
      return [];
    }
  }


  // 1. GET - Public drivers (ALREADY IMPLEMENTED)
  Future<void> fetchPublicDrivers({
    String? baseCity,
    String? baseCountry,
    double? minRating,
  }) async {
    try {
      print('🚕 ==== FETCHING PUBLIC DRIVERS ====');
      print('🚕 City filter: $baseCity');
      print('🚕 Country filter: $baseCountry');
      print('🚕 Min rating: $minRating');
      
      isLoading.value = true;
      errorMessage.value = '';
      
      filters['baseCity'] = baseCity ?? '';
      filters['baseCountry'] = baseCountry ?? '';
      filters['minRating'] = minRating;
      
      final drivers = await _repository.getPublicDrivers(
        baseCity: baseCity,
        baseCountry: baseCountry,
        minRating: minRating,
      );
      
      publicDrivers.assignAll(drivers);
      filteredDrivers.assignAll(drivers);
      
      print('🚕 Successfully loaded ${drivers.length} public drivers');
      print('🚕 Available drivers: ${drivers.where((d) => d.isAvailable).length}');
      print('🚕 Approved drivers: ${drivers.where((d) => d.isApproved).length}');
      print('🚕 ===== PUBLIC DRIVERS FETCH COMPLETE =====');
      
    } catch (e, stackTrace) {
      print('❌ ===== PUBLIC DRIVERS FETCH FAILED =====');
      print('❌ Error: $e');
      print('❌ Stack Trace: $stackTrace');
      print('❌ ======================================');
      
      errorMessage.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load drivers: ${e.toString().replaceAll('Exception: ', '')}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // 2. GET - My driver profile (REQUIRES DRIVER ROLE)
  Future<void> fetchMyDriverProfile() async {
    try {
      print('🚕 ==== FETCHING MY DRIVER PROFILE ====');
      
      isLoadingProfile.value = true;
      profileError.value = '';
      
      final profile = await _repository.getMyDriverProfile();
      myDriverProfile.value = profile;
      
      if (profile == null) {
        print('ℹ️ No driver profile found for current user');
        profileError.value = 'You don\'t have a driver profile yet.';
      } else {
        print('✅ Loaded driver profile: ${profile.displayName}');
        print('📊 Profile status: ${profile.status}');
        print('📊 Availability: ${profile.isAvailable}');
      }
      
      print('🚕 ===== MY DRIVER PROFILE FETCH COMPLETE =====');
      
    } catch (e, stackTrace) {
      print('❌ ===== MY DRIVER PROFILE FETCH FAILED =====');
      print('❌ Error: $e');
      print('❌ Stack Trace: $stackTrace');
      print('❌ ==========================================');
      
      profileError.value = e.toString();
    } finally {
      isLoadingProfile.value = false;
    }
  }

  // 3. POST - Create driver profile (REQUIRES DRIVER ROLE - will fail for regular users)
  Future<bool> createDriverProfile({
    required String displayName,
    required String baseCity,
    required String baseRegion,
    required String baseCountry,
    required double hourlyRate,
    required String bio,
    required int yearsExperience,
    required List<String> languages,
    required IdentityDocument identityDocument,
    required DriverLicense driverLicense,
  }) async {
    try {
      print('🚕 ==== CREATING DRIVER PROFILE ====');
      print('🚕 Display Name: $displayName');
      print('🚕 City: $baseCity');
      print('🚕 Hourly Rate: $hourlyRate');
      print('🚕 Experience: $yearsExperience years');
      
      isCreatingProfile.value = true;
      profileError.value = '';
      
      final request = CreateDriverProfileRequest(
        displayName: displayName,
        baseCity: baseCity,
        baseRegion: baseRegion,
        baseCountry: baseCountry,
        hourlyRate: hourlyRate,
        bio: bio,
        yearsExperience: yearsExperience,
        languages: languages,
        identityDocument: identityDocument,
        driverLicense: driverLicense,
      );
      
      final profile = await _repository.createDriverProfile(request);
      myDriverProfile.value = profile;
      
      print('✅ Driver profile created successfully: ${profile.displayName}');
      print('📊 Profile ID: ${profile.id}');
      print('📊 Profile Status: ${profile.status}');
      
      Get.snackbar(
        'Success!',
        'Driver profile created successfully!\nStatus: ${profile.status.toUpperCase()}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      
      return true;
    } catch (e, stackTrace) {
      print('❌ ===== CREATE DRIVER PROFILE FAILED =====');
      print('❌ Error: $e');
      print('❌ Stack Trace: $stackTrace');
      print('❌ =======================================');
      
      profileError.value = e.toString();
      
      // Special handling for role-based access error
      if (e.toString().contains('driver role') || e.toString().contains('Access denied')) {
        Get.snackbar(
          'Role Required',
          'You need the "driver" role to create a driver profile.\n\nPlease contact support to request driver access.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 10),
        );
      } else {
        Get.snackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      }
      
      return false;
    } finally {
      isCreatingProfile.value = false;
    }
  }

  // 4. PATCH - Update driver profile (REQUIRES DRIVER ROLE)
  Future<bool> updateDriverProfile({
    String? displayName,
    String? baseCity,
    String? baseRegion,
    String? baseCountry,
    double? hourlyRate,
    String? bio,
    int? yearsExperience,
    List<String>? languages,
    IdentityDocument? identityDocument,
    DriverLicense? driverLicense,
    bool? isAvailable,
  }) async {
    try {
      print('🚕 ==== UPDATING DRIVER PROFILE ====');
      
      isUpdatingProfile.value = true;
      profileError.value = '';
      
      final request = UpdateDriverProfileRequest(
        displayName: displayName,
        baseCity: baseCity,
        baseRegion: baseRegion,
        baseCountry: baseCountry,
        hourlyRate: hourlyRate,
        bio: bio,
        yearsExperience: yearsExperience,
        languages: languages,
        identityDocument: identityDocument,
        driverLicense: driverLicense,
        isAvailable: isAvailable,
      );
      
      final profile = await _repository.updateDriverProfile(request);
      myDriverProfile.value = profile;
      
      print('✅ Driver profile updated successfully');
      
      Get.snackbar(
        'Success',
        'Driver profile updated successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      return true;
    } catch (e, stackTrace) {
      print('❌ ===== UPDATE DRIVER PROFILE FAILED =====');
      print('❌ Error: $e');
      print('❌ Stack Trace: $stackTrace');
      
      profileError.value = e.toString();
      
      if (e.toString().contains('driver role') || e.toString().contains('Access denied')) {
        Get.snackbar(
          'Role Required',
          'You need the "driver" role to update your profile.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
      
      return false;
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  // 5. Update availability status
  Future<bool> updateAvailability(bool isAvailable) async {
    try {
      print('🚕 ==== UPDATING AVAILABILITY ====');
      print('🚕 Available: $isAvailable');
      
      final success = await updateDriverProfile(isAvailable: isAvailable);
      
      if (success) {
        Get.snackbar(
          'Availability Updated',
          isAvailable ? 'You are now available for bookings' : 'You are now unavailable',
          backgroundColor: isAvailable ? Colors.green : Colors.blue,
          colorText: Colors.white,
        );
      }
      
      return success;
    } catch (e, stackTrace) {
      print('❌ ===== UPDATE AVAILABILITY FAILED =====');
      print('❌ Error: $e');
      print('❌ Stack Trace: $stackTrace');
      return false;
    }
  }

  // Helper methods...
  void filterDrivers({
    String? city,
    String? country,
    double? minRating,
    bool? availableOnly,
  }) {
    print('🚕 ==== APPLYING DRIVER FILTERS ====');
    print('🚕 City: $city');
    print('🚕 Country: $country');
    print('🚕 Min Rating: $minRating');
    print('🚕 Available Only: $availableOnly');
    
    filteredDrivers.value = publicDrivers.where((driver) {
      bool passes = true;
      
      if (city != null && city.isNotEmpty) {
        passes = passes && driver.baseCity.toLowerCase().contains(city.toLowerCase());
      }
      
      if (country != null && country.isNotEmpty) {
        passes = passes && driver.baseCountry.toLowerCase().contains(country.toLowerCase());
      }
      
      if (minRating != null) {
        passes = passes && driver.ratingAverage >= minRating;
      }
      
      if (availableOnly == true) {
        passes = passes && driver.isAvailable;
      }
      
      return passes;
    }).toList();
    
    print('🚕 Filtered results: ${filteredDrivers.length} out of ${publicDrivers.length}');
    print('🚕 ===== DRIVER FILTERS APPLIED =====');
  }

  void searchDrivers(String query) {
    print('🚕 Searching drivers with query: "$query"');
    searchQuery.value = query;
    
    if (query.isEmpty) {
      filterDrivers(
        city: filters['baseCity'],
        country: filters['baseCountry'],
        minRating: filters['minRating'],
      );
      return;
    }
    
    final lowerQuery = query.toLowerCase();
    filteredDrivers.value = publicDrivers.where((driver) {
      final matches = 
          driver.displayName.toLowerCase().contains(lowerQuery) ||
          driver.user.fullName.toLowerCase().contains(lowerQuery) ||
          driver.baseCity.toLowerCase().contains(lowerQuery) ||
          driver.languages.any((lang) => lang.toLowerCase().contains(lowerQuery)) ||
          driver.bio.toLowerCase().contains(lowerQuery);
      
      return matches;
    }).toList();
    
    print('🚕 Search results: ${filteredDrivers.length} drivers');
  }

  void clearFilters() {
    print('🚕 Clearing all driver filters');
    filters['baseCity'] = '';
    filters['baseCountry'] = '';
    filters['minRating'] = null;
    searchQuery.value = '';
    filteredDrivers.assignAll(publicDrivers);
  }

  // Check if current user has driver role
  bool get hasDriverRole {
    final userData = GetStorage().read('user_data');
    final roles = userData?['roles'] as List<dynamic>?;
    return roles?.contains('driver') == true;
  }

  // Check if user has a driver profile (regardless of role)
  bool get hasDriverProfile => myDriverProfile.value != null;

  // Get driver role status
  String get driverStatus {
    if (!hasDriverRole) return 'no_driver_role';
    if (!hasDriverProfile) return 'no_profile';
    return myDriverProfile.value!.status;
  }

  // Refresh data
  @override
  void refresh() {
    print('🚕 Refreshing driver data');
    fetchPublicDrivers();
    fetchMyDriverProfile();
  }


}