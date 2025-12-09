// lib/features/modules/vehicles/repositories/vehicle_model_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

import '../../app/features/data/models/vehicle_models/vehicle_model.dart';

class VehicleModelRepository {
  final String baseUrl = 'http://13.61.185.238:5050/api/v1';
  final GetStorage storage = GetStorage();

  Future<List<VehicleModel>> getAllVehicleModels({
    String? make,
    String? model,
    int? year,
    String? vehicleClass,
    String? transmission,
    String? fuelType,
    int? seatsMin,
    int? seatsMax,
    int? doorsMin,
    int? doorsMax,
    String? feature,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🚗 ==== FETCHING VEHICLE MODELS ====');
      print('🚗 Method: GET');
      print('🚗 Endpoint: /vehicle-models');
      
      // Build query parameters
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      if (make != null) queryParams['make'] = make;
      if (model != null) queryParams['model'] = model;
      if (year != null) queryParams['year'] = year.toString();
      if (vehicleClass != null) queryParams['class'] = vehicleClass;
      if (transmission != null) queryParams['transmission'] = transmission;
      if (fuelType != null) queryParams['fuel_type'] = fuelType;
      if (seatsMin != null) queryParams['seats_min'] = seatsMin.toString();
      if (seatsMax != null) queryParams['seats_max'] = seatsMax.toString();
      if (doorsMin != null) queryParams['doors_min'] = doorsMin.toString();
      if (doorsMax != null) queryParams['doors_max'] = doorsMax.toString();
      if (feature != null) queryParams['feature'] = feature;
      
      final queryString = Uri(queryParameters: queryParams).query;
      final url = '$baseUrl/vehicle-models?$queryString';
      
      print('🚗 Request URL: $url');
      print('🚗 Query Parameters: $queryParams');
      
      // Get auth token
      final token = storage.read('auth_token');
      if (token == null) {
        print('⚠️ No auth token found. Using public access.');
      } else {
        print('🔑 Auth token found (length: ${token.toString().length})');
      }
      
      final headers = {
        'accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      
      print('🚗 Headers: $headers');
      print('🚗 Starting HTTP request...');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      print('📊 HTTP Response Status: ${response.statusCode}');
      print('📊 HTTP Response Body length: ${response.body.length}');
      print('📊 Response Headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('✅ Success response received');
        
        if (responseData['success'] == true) {
          final data = responseData['data'];
          final items = data['items'] as List<dynamic>;
          
          print('📋 Parsing ${items.length} vehicle model(s)...');
          
          final vehicleModels = items.map<VehicleModel>((item) {
            try {
              return VehicleModel.fromJson(item);
            } catch (e) {
              print('❌ Error parsing vehicle model item: $e');
              print('❌ Problematic item: $item');
              rethrow;
            }
          }).toList();
          
          print('✅ Successfully parsed ${vehicleModels.length} vehicle model(s)');
          print('📊 Pagination Info:');
          print('   - Total: ${data['total']}');
          print('   - Page: ${data['page']}');
          print('   - Limit: ${data['limit']}');
          print('   - Total Pages: ${data['totalPages']}');
          
          return vehicleModels;
        } else {
          print('❌ API returned success: false');
          print('❌ Error message: ${responseData['message']}');
          throw Exception(responseData['message'] ?? 'Failed to fetch vehicle models');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('❌ Error Body: ${response.body}');
        throw Exception('Failed to fetch vehicle models. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ ===== VEHICLE MODEL FETCH ERROR =====');
      print('❌ Error: $e');
      print('❌ Stack Trace: $stackTrace');
      print('❌ ====================================');
      rethrow;
    }
  }

  Future<VehicleModel> getVehicleModelById(String id) async {
    try {
      print('🚗 ==== FETCHING SINGLE VEHICLE MODEL ====');
      print('🚗 Model ID: $id');
      
      final url = '$baseUrl/vehicle-models/$id';
      print('🚗 Request URL: $url');
      
      final token = storage.read('auth_token');
      final headers = {
        'accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };
      
      print('🚗 Starting HTTP request...');
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
          print('📋 Parsing vehicle model data...');
          return VehicleModel.fromJson(data);
        } else {
          print('❌ API returned success: false');
          throw Exception(responseData['message'] ?? 'Failed to fetch vehicle model');
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        throw Exception('Failed to fetch vehicle model. Status: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print('❌ ===== SINGLE VEHICLE MODEL FETCH ERROR =====');
      print('❌ Error: $e');
      print('❌ Stack Trace: $stackTrace');
      print('❌ ==========================================');
      rethrow;
    }
  }
}