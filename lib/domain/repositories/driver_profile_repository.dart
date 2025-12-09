// Update lib/features/modules/drivers/repositories/driver_profile_repository.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

import '../../app/features/data/models/drivers_models/driver_profile.dart';

class DriverProfileRepository {
  final String baseUrl = 'http://13.61.185.238:5050/api/v1';
  final GetStorage storage = GetStorage();

  // 1. GET - Public list of approved & available drivers (ALREADY IMPLEMENTED)
  Future<List<DriverProfile>> getPublicDrivers({
    String? baseCity,
    String? baseCountry,
    double? minRating,
  }) async {
    try {
      print('🚕 ==== FETCHING PUBLIC DRIVERS ====');
      print('🚕 Method: GET');
      print('🚕 Endpoint: /driver-profiles/public');
      
      // Build query parameters
      final Map<String, String> queryParams = {};
      
      if (baseCity != null && baseCity.isNotEmpty) queryParams['base_city'] = baseCity;
      if (baseCountry != null && baseCountry.isNotEmpty) queryParams['base_country'] = baseCountry;
      if (minRating != null) queryParams['min_rating'] = minRating.toString();
      
      final queryString = Uri(queryParameters: queryParams).query;
      final url = queryString.isNotEmpty 
          ? '$baseUrl/driver-profiles/public?$queryString'
          : '$baseUrl/driver-profiles/public';
      
      print('🚕 Request URL: $url');
      print('🚕 Query Parameters: $queryParams');
      
      // Get auth token (public endpoint, but token might be needed)
      final token = storage.read('auth_token');
      if (token == null) {
        print('ℹ️ No auth token - using public access');
      } else {
        print('🔑 Auth token found (length: ${token.toString().length})');
      }
      
      final headers = {
        'accept': '*/*',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      
      print('🚕 Headers: $headers');
      print('🚕 Starting HTTP request...');
      
      final startTime = DateTime.now();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      print('⏱️ Request duration: ${duration.inMilliseconds}ms');
      print('📊 HTTP Response Status: ${response.statusCode}');
      print('📊 HTTP Response Body length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Success response received');
        
        if (responseData['success'] == true) {
          final items = responseData['data'] as List<dynamic>;
          
          print('📋 Parsing ${items.length} driver profile(s)...');
          
          final drivers = <DriverProfile>[];
          int successCount = 0;
          int errorCount = 0;
          
          for (int i = 0; i < items.length; i++) {
            try {
              final driver = DriverProfile.fromJson(items[i]);
              drivers.add(driver);
              successCount++;
              print('✅ [$i/${items.length}] Successfully parsed: ${driver.displayName}');
            } catch (e) {
              errorCount++;
              print('❌ [$i/${items.length}] Failed to parse driver: $e');
              print('❌ Problematic item: ${items[i]}');
            }
          }
          
          print('📊 Parsing Results:');
          print('   - Successfully parsed: $successCount');
          print('   - Failed to parse: $errorCount');
          print('   - Total expected: ${items.length}');
          
          // Log driver statistics
          _logDriverStatistics(drivers);
          
          return drivers;
        } else {
          print('❌ API returned success: false');
          print('❌ Error message: ${responseData['message']}');
          throw Exception(responseData['message'] ?? 'Failed to fetch drivers');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        throw Exception('Failed to fetch drivers. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ ===== PUBLIC DRIVERS FETCH ERROR =====');
      print('❌ Error: $e');
      print('❌ Stack Trace: $stackTrace');
      print('❌ =====================================');
      rethrow;
    }
  }

  // 2. POST - Create my driver profile (REQUIRES DRIVER ROLE)
  Future<DriverProfile> createDriverProfile(CreateDriverProfileRequest request) async {
    try {
      print('🚕 ==== CREATING DRIVER PROFILE ====');
      print('🚕 Method: POST');
      print('🚕 Endpoint: /driver-profiles/me');
      print('🚕 Request Data: ${request.toJson()}');
      
      final url = '$baseUrl/driver-profiles/me';
      print('🚕 Request URL: $url');
      
      // This endpoint REQUIRES driver role
      final token = storage.read('auth_token');
      if (token == null) {
        print('❌ No auth token found');
        throw Exception('Authentication required');
      }
      
      print('🔑 Auth token found (length: ${token.toString().length})');
      
      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      
      print('🚕 Headers: $headers');
      print('🚕 Request Body: ${json.encode(request.toJson())}');
      print('🚕 Starting HTTP request...');
      
      final startTime = DateTime.now();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(request.toJson()),
      );
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      print('⏱️ Request duration: ${duration.inMilliseconds}ms');
      print('📊 HTTP Response Status: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('✅ Profile created successfully');
        
        if (responseData['success'] == true) {
          final data = responseData['data'];
          print('📋 Parsing created driver profile...');
          return DriverProfile.fromJson(data);
        } else {
          print('❌ API returned success: false');
          throw Exception(responseData['message'] ?? 'Failed to create profile');
        }
      } else if (response.statusCode == 403) {
        print('❌ Access denied - User is not a driver');
        final error = json.decode(response.body);
        final errorMsg = error['message'] ?? 'Access denied. Requires driver role.';
        print('❌ Error message: $errorMsg');
        throw Exception(errorMsg);
      } else if (response.statusCode == 409) {
        print('❌ Profile already exists');
        throw Exception('You already have a driver profile.');
      } else if (response.statusCode == 400) {
        print('❌ Validation error');
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Validation failed');
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        throw Exception('Failed to create profile. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ ===== CREATE DRIVER PROFILE ERROR =====');
      print('❌ Error: $e');
      print('❌ Stack Trace: $stackTrace');
      print('❌ ======================================');
      rethrow;
    }
  }

  // 3. GET - Get my driver profile (REQUIRES DRIVER ROLE)
  Future<DriverProfile?> getMyDriverProfile() async {
    try {
      print('🚕 ==== FETCHING MY DRIVER PROFILE ====');
      print('🚕 Method: GET');
      print('🚕 Endpoint: /driver-profiles/me');
      
      final url = '$baseUrl/driver-profiles/me';
      print('🚕 Request URL: $url');
      
      // This endpoint REQUIRES driver role
      final token = storage.read('auth_token');
      if (token == null) {
        print('❌ No auth token found');
        throw Exception('Authentication required');
      }
      
      print('🔑 Auth token found (length: ${token.toString().length})');
      
      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      };
      
      print('🚕 Headers: $headers');
      print('🚕 Starting HTTP request...');
      
      final startTime = DateTime.now();
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      print('⏱️ Request duration: ${duration.inMilliseconds}ms');
      print('📊 HTTP Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Success response received');
        
        if (responseData['success'] == true) {
          final data = responseData['data'];
          print('📋 Parsing my driver profile...');
          return DriverProfile.fromJson(data);
        } else {
          print('❌ API returned success: false');
          return null; // Profile might not exist
        }
      } else if (response.statusCode == 403) {
        print('⚠️ Access denied - User is not a driver');
        print('⚠️ Response Body: ${response.body}');
        return null;
      } else if (response.statusCode == 404) {
        print('⚠️ Profile not found');
        return null;
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ ===== MY DRIVER PROFILE FETCH ERROR =====');
      print('❌ Error: $e');
      print('❌ Stack Trace: $stackTrace');
      print('❌ =======================================');
      return null;
    }
  }

  // 4. PATCH - Update my driver profile (REQUIRES DRIVER ROLE)
  Future<DriverProfile> updateDriverProfile(UpdateDriverProfileRequest request) async {
    try {
      print('🚕 ==== UPDATING DRIVER PROFILE ====');
      print('🚕 Method: PATCH');
      print('🚕 Endpoint: /driver-profiles/me');
      print('🚕 Update Data: ${request.toJson()}');
      
      final url = '$baseUrl/driver-profiles/me';
      print('🚕 Request URL: $url');
      
      // This endpoint REQUIRES driver role
      final token = storage.read('auth_token');
      if (token == null) {
        print('❌ No auth token found');
        throw Exception('Authentication required');
      }
      
      print('🔑 Auth token found (length: ${token.toString().length})');
      
      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      
      print('🚕 Headers: $headers');
      print('🚕 Request Body: ${json.encode(request.toJson())}');
      print('🚕 Starting HTTP request...');
      
      final startTime = DateTime.now();
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(request.toJson()),
      );
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      
      print('⏱️ Request duration: ${duration.inMilliseconds}ms');
      print('📊 HTTP Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Profile updated successfully');
        
        if (responseData['success'] == true) {
          final data = responseData['data'];
          return DriverProfile.fromJson(data);
        } else {
          print('❌ API returned success: false');
          throw Exception(responseData['message'] ?? 'Failed to update profile');
        }
      } else if (response.statusCode == 403) {
        print('❌ Access denied - User is not a driver');
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Access denied');
      } else if (response.statusCode == 404) {
        print('❌ Profile not found');
        throw Exception('Driver profile not found');
      } else if (response.statusCode == 400) {
        print('❌ Validation error');
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Validation failed');
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        throw Exception('Failed to update profile. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ ===== UPDATE DRIVER PROFILE ERROR =====');
      print('❌ Error: $e');
      print('❌ Stack Trace: $stackTrace');
      print('❌ ======================================');
      rethrow;
    }
  }

  // 5. Update availability status
  Future<DriverProfile> updateAvailability(bool isAvailable) async {
    try {
      print('🚕 ==== UPDATING AVAILABILITY ====');
      print('🚕 Available: $isAvailable');
      
      final request = UpdateDriverProfileRequest(isAvailable: isAvailable);
      return await updateDriverProfile(request);
    } catch (e, stackTrace) {
      print('❌ ===== UPDATE AVAILABILITY ERROR =====');
      print('❌ Error: $e');
      print('❌ Stack Trace: $stackTrace');
      rethrow;
    }
  }

  void _logDriverStatistics(List<DriverProfile> drivers) {
    print('📊 ===== DRIVER STATISTICS =====');
    print('📊 Total Drivers: ${drivers.length}');
    
    // City distribution
    final cityCount = <String, int>{};
    for (final driver in drivers) {
      cityCount[driver.baseCity] = (cityCount[driver.baseCity] ?? 0) + 1;
    }
    print('📊 City Distribution:');
    cityCount.forEach((city, count) {
      print('   - $city: $count');
    });
    
    // Rating distribution
    final ratingGroups = <String, int>{
      '0-2 stars': 0,
      '2-4 stars': 0,
      '4-5 stars': 0,
    };
    
    for (final driver in drivers) {
      if (driver.ratingAverage >= 4) {
        ratingGroups['4-5 stars'] = ratingGroups['4-5 stars']! + 1;
      } else if (driver.ratingAverage >= 2) {
        ratingGroups['2-4 stars'] = ratingGroups['2-4 stars']! + 1;
      } else {
        ratingGroups['0-2 stars'] = ratingGroups['0-2 stars']! + 1;
      }
    }
    
    print('📊 Rating Distribution:');
    ratingGroups.forEach((range, count) {
      print('   - $range: $count');
    });
    
    // Experience range
    final experienceGroups = <String, int>{
      '0-3 years': 0,
      '4-7 years': 0,
      '8+ years': 0,
    };
    
    for (final driver in drivers) {
      if (driver.yearsExperience >= 8) {
        experienceGroups['8+ years'] = experienceGroups['8+ years']! + 1;
      } else if (driver.yearsExperience >= 4) {
        experienceGroups['4-7 years'] = experienceGroups['4-7 years']! + 1;
      } else {
        experienceGroups['0-3 years'] = experienceGroups['0-3 years']! + 1;
      }
    }
    
    print('📊 Experience Distribution:');
    experienceGroups.forEach((range, count) {
      print('   - $range: $count');
    });
    
    // Availability
    final available = drivers.where((d) => d.isAvailable).length;
    print('📊 Availability: $available available, ${drivers.length - available} not available');
    
    print('📊 =============================');
  }
}