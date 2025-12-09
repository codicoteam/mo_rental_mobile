// lib/features/modules/vehicles/repositories/vehicle_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

import '../../app/features/data/models/vehicle_models/vehicle.dart';

class VehicleRepository {
  final String baseUrl = 'http://13.61.185.238:5050/api/v1';
  final GetStorage storage = GetStorage();

  Future<List<Vehicle>> getAllVehicles({
    String? plateNumber,
    String? vin,
    String? branchId,
    String? status,
    String? availabilityState,
    String? color,
    int? odometerMin,
    int? odometerMax,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🚙 ==== FETCHING VEHICLES ====');
      print('🚙 Method: GET');
      print('🚙 Endpoint: /vehicles');
      
      // Build query parameters
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (plateNumber != null) queryParams['plate_number'] = plateNumber;
      if (vin != null) queryParams['vin'] = vin;
      if (branchId != null) queryParams['branch_id'] = branchId;
      if (status != null) queryParams['status'] = status;
      if (availabilityState != null) queryParams['availability_state'] = availabilityState;
      if (color != null) queryParams['color'] = color;
      if (odometerMin != null) queryParams['odometer_min'] = odometerMin.toString();
      if (odometerMax != null) queryParams['odometer_max'] = odometerMax.toString();
      
      final queryString = Uri(queryParameters: queryParams).query;
      final url = '$baseUrl/vehicles?$queryString';
      
      print('🚙 Request URL: $url');
      print('🚙 Query Parameters: $queryParams');
      
      // Get auth token
      final token = storage.read('auth_token');
      if (token == null) {
        print('⚠️ No auth token found. Using public access.');
      } else {
        print('🔑 Auth token found (length: ${token.toString().length})');
      }
      
      final headers = {
        'accept': '*/*',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      
      print('🚙 Headers: $headers');
      print('🚙 Starting HTTP request...');
      
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
      print('📊 Response Headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Success response received');
        
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final items = data['items'] as List<dynamic>;
          
          print('📋 Parsing ${items.length} vehicle(s)...');
          
          final vehicles = <Vehicle>[];
          int successCount = 0;
          int errorCount = 0;
          
          for (int i = 0; i < items.length; i++) {
            try {
              final vehicle = Vehicle.fromJson(items[i]);
              vehicles.add(vehicle);
              successCount++;
              print('✅ [$i/${items.length}] Successfully parsed: ${vehicle.displayName}');
            } catch (e) {
              errorCount++;
              print('❌ [$i/${items.length}] Failed to parse vehicle: $e');
              print('❌ Problematic item: ${items[i]}');
            }
          }
          
          print('📊 Parsing Results:');
          print('   - Successfully parsed: $successCount');
          print('   - Failed to parse: $errorCount');
          print('   - Total expected: ${items.length}');
          
          print('📊 Pagination Info:');
          print('   - Total: ${data['total']}');
          print('   - Page: ${data['page']}');
          print('   - Limit: ${data['limit']}');
          print('   - Total Pages: ${data['totalPages']}');
          
          // Log vehicle statistics
          _logVehicleStatistics(vehicles);
          
          return vehicles;
        } else {
          print('❌ API returned success: false');
          print('❌ Error message: ${responseData['message']}');
          throw Exception(responseData['message'] ?? 'Failed to fetch vehicles');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        throw Exception('Failed to fetch vehicles. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ ===== VEHICLE FETCH ERROR =====');
      print('❌ Error: $e');
      print('❌ Stack Trace: $stackTrace');
      print('❌ ==================================');
      rethrow;
    }
  }

  void _logVehicleStatistics(List<Vehicle> vehicles) {
    print('📊 ===== VEHICLE STATISTICS =====');
    print('📊 Total Vehicles: ${vehicles.length}');
    
    // Status breakdown
    final statusCount = <String, int>{};
    for (final vehicle in vehicles) {
      statusCount[vehicle.status] = (statusCount[vehicle.status] ?? 0) + 1;
    }
    print('📊 Status Breakdown:');
    statusCount.forEach((status, count) {
      print('   - $status: $count');
    });
    
    // Availability breakdown
    final availabilityCount = <String, int>{};
    for (final vehicle in vehicles) {
      availabilityCount[vehicle.availabilityState] = (availabilityCount[vehicle.availabilityState] ?? 0) + 1;
    }
    print('📊 Availability Breakdown:');
    availabilityCount.forEach((state, count) {
      print('   - $state: $count');
    });
    
    // Branch distribution
    final branchCount = <String, int>{};
    for (final vehicle in vehicles) {
      branchCount[vehicle.branch.name] = (branchCount[vehicle.branch.name] ?? 0) + 1;
    }
    print('📊 Branch Distribution:');
    branchCount.forEach((branch, count) {
      print('   - $branch: $count');
    });
    
    // Service needs
    final needsService = vehicles.where((v) => v.needsService).length;
    print('📊 Service Needs: $needsService vehicles need service');
    
    print('📊 ==============================');
  }

  Future<Vehicle> getVehicleById(String id) async {
    try {
      print('🚙 ==== FETCHING SINGLE VEHICLE ====');
      print('🚙 Vehicle ID: $id');
      
      final url = '$baseUrl/vehicles/$id';
      print('🚙 Request URL: $url');
      
      final token = storage.read('auth_token');
      final headers = {
        'accept': '*/*',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      
      print('🚙 Starting HTTP request...');
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      print('📊 HTTP Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Success response received');
        
        if (responseData['success'] == true) {
          final data = responseData['data'];
          print('📋 Parsing vehicle data...');
          return Vehicle.fromJson(data);
        } else {
          print('❌ API returned success: false');
          throw Exception(responseData['message'] ?? 'Failed to fetch vehicle');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        throw Exception('Failed to fetch vehicle. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ ===== SINGLE VEHICLE FETCH ERROR =====');
      print('❌ Error: $e');
      print('❌ Stack Trace: $stackTrace');
      print('❌ =====================================');
      rethrow;
    }
  }
}