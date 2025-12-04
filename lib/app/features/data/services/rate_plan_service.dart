import 'dart:convert'; // ADD THIS
import 'package:get/get.dart';
import 'package:http/http.dart' as http; // ADD THIS
import '../models/auth_models/api_response.dart';
import '../models/rate_plan/rate_plan_request.dart';
import '../models/rate_plan/rate_plan_response.dart';
import 'api_service.dart';

class RatePlanService extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  Future<ApiResponse<RatePlanResponse>> getRatePlans({
    required String token,
    RatePlanRequest? request,
  }) async {
    print('📊 RATE PLANS REQUEST');
    print('🔑 Token: ${token.substring(0, 20)}...');
    print('📋 Query Params: ${request?.toQueryParams()}');

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    final queryParams = request?.toQueryParams() ?? {};
    final endpoint = '/api/v1/rate-plans';

    return await _apiService.get<RatePlanResponse>(
      endpoint,
      headers: headers,
      fromJson: (data) => RatePlanResponse.fromJson(data),
      queryParams: queryParams,
    );
  }

  // Add other methods for POST, PUT, DELETE as needed
  Future<ApiResponse<RatePlan>> createRatePlan({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    print('➕ CREATE RATE PLAN');
    print('📊 Data: $data');

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    return await _apiService.post<RatePlan>(
      '/api/v1/rate-plans',
      data,
      headers: headers,
      fromJson: (data) => RatePlan.fromJson(data),
    );
  }

  Future<ApiResponse<RatePlan>> updateRatePlan({
    required String token,
    required String planId,
    required Map<String, dynamic> data,
  }) async {
    print('✏️ UPDATE RATE PLAN: $planId');
    print('📊 Data: $data');

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    return await _apiService.put<RatePlan>(
      '/api/v1/rate-plans/$planId',
      data,
      headers: headers,
      fromJson: (data) => RatePlan.fromJson(data),
    );
  }

  Future<ApiResponse<void>> deleteRatePlan({
    required String token,
    required String planId,
  }) async {
    print('🗑️ DELETE RATE PLAN: $planId');

    final headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };

    return await _apiService.delete(
      '/api/v1/rate-plans/$planId',
      headers: headers,
    );
  }
}

// Update ApiService to support query params
// Add this to your existing ApiService class:
extension ApiServiceExtensions on ApiService {
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      String url = '$baseUrl$endpoint';
      
      // Add query parameters if any
      if (queryParams != null && queryParams.isNotEmpty) {
        final queryString = Uri(queryParameters: queryParams).query;
        url += '?$queryString';
      }
      
      print('🌐 GET API CALL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(timeout);

      // Parse response
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<T>(
          success: true,
          message: responseData['message'] ?? 'Success',
          data: fromJson != null ? fromJson(responseData['data'] ?? {}) : null,
        );
      } else {
        return ApiResponse<T>(
          success: false,
          message: responseData['message'] ?? 'Request failed',
          error: responseData,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: e.toString(),
        error: e,
      );
    }
  }

  Future<ApiResponse<T>> put<T>(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      
      print('🌐 PUT API CALL: $url');
      print('📦 Request Body: $body');
      
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(body),
      ).timeout(timeout);

      // Parse response
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<T>(
          success: true,
          message: responseData['message'] ?? 'Success',
          data: fromJson != null ? fromJson(responseData['data'] ?? {}) : null,
        );
      } else {
        return ApiResponse<T>(
          success: false,
          message: responseData['message'] ?? 'Request failed',
          error: responseData,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: e.toString(),
        error: e,
      );
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      
      print('🌐 DELETE API CALL: $url');
      
      final response = await http.delete(
        url,
        headers: headers,
      ).timeout(timeout);

      // Parse response
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse<T>(
          success: true,
          message: responseData['message'] ?? 'Success',
        );
      } else {
        return ApiResponse<T>(
          success: false,
          message: responseData['message'] ?? 'Request failed',
          error: responseData,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        message: e.toString(),
        error: e,
      );
    }
  }
}