import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/auth_models/api_response.dart';

class ApiService extends GetxService {
  static ApiService get to => Get.find();
  
  final String baseUrl = 'http://13.61.185.238:5050';
  final Duration timeout = Duration(seconds: 15);

  // POST method
  Future<ApiResponse<T>> post<T>(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    
    try {
      print('\n🌐 API CALL STARTED');
      print('📡 URL: $baseUrl$endpoint');
      print('📦 REQUEST BODY: $body');
      print('⏰ Timeout: ${timeout.inSeconds} seconds');
      
      final url = Uri.parse('$baseUrl$endpoint');
      final defaultHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      final response = await http.post(
        url,
        headers: {...defaultHeaders, ...?headers},
        body: json.encode(body),
      ).timeout(timeout, onTimeout: () {
        throw http.ClientException('Request timeout after ${timeout.inSeconds} seconds');
      });

      stopwatch.stop();
      
      print('✅ API CALL COMPLETED');
      print('⏱️  Response Time: ${stopwatch.elapsedMilliseconds}ms');
      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response Headers: ${response.headers}');
      print('📝 Response Body: ${response.body}');
      
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('🎉 API SUCCESS');
        return ApiResponse<T>(
          success: true,
          message: responseData['message'] ?? 'Success',
          data: fromJson != null && responseData['data'] != null 
              ? fromJson(responseData['data']) 
              : null,
        );
      } else {
        String errorMessage = responseData['message'] ?? 'Request failed';
        
        // Check for duplicate key errors
        if (responseData['message']?.contains('duplicate key') ?? false) {
          if (responseData['message']?.contains('email') ?? false) {
            errorMessage = 'Email is already registered';
          } else if (responseData['message']?.contains('phone') ?? false) {
            errorMessage = 'Phone number is already registered';
          }
        }
        
        print('❌ API ERROR: $errorMessage');
        return ApiResponse<T>(
          success: false,
          message: errorMessage,
          error: responseData,
        );
      }
    } on http.ClientException catch (e) {
      stopwatch.stop();
      print('❌ HTTP CLIENT ERROR: $e');
      print('⏱️  Failed after: ${stopwatch.elapsedMilliseconds}ms');
      return ApiResponse<T>(
        success: false,
        message: 'Network error: ${e.message}',
        error: e,
      );
    } on FormatException catch (e) {
      stopwatch.stop();
      print('❌ JSON FORMAT ERROR: $e');
      return ApiResponse<T>(
        success: false,
        message: 'Invalid response from server',
        error: e,
      );
    } catch (e) {
      stopwatch.stop();
      print('❌ UNEXPECTED ERROR: $e');
      print('⏱️  Failed after: ${stopwatch.elapsedMilliseconds}ms');
      return ApiResponse<T>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // GET method
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    
    try {
      print('\n🌐 API CALL STARTED');
      print('📡 URL: $baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        print('🔍 Query Params: $queryParams');
      }
      if (headers != null && headers.containsKey('Authorization')) {
        print('🔑 Token: ${headers['Authorization']?.substring(0, 30)}...');
      }
      
      String url = '$baseUrl$endpoint';
      
      // Add query parameters if any
      if (queryParams != null && queryParams.isNotEmpty) {
        final queryString = Uri(queryParameters: queryParams).query;
        url += '?$queryString';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(timeout);

      stopwatch.stop();
      
      print('✅ API CALL COMPLETED');
      print('⏱️ Response Time: ${stopwatch.elapsedMilliseconds}ms');
      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response Headers: ${response.headers}');
      print('📝 Response Body: ${response.body}');
      
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print('🎉 API SUCCESS');
        return ApiResponse<T>(
          success: true,
          message: responseData['message'] ?? 'Success',
          data: fromJson != null && responseData['data'] != null 
              ? fromJson(responseData['data']) 
              : null,
        );
      } else {
        print('❌ API ERROR');
        print('❌ Error Message: ${responseData['message']}');
        print('❌ Error Details: $responseData');
        
        return ApiResponse<T>(
          success: false,
          message: responseData['message'] ?? 'Request failed with status ${response.statusCode}',
          error: responseData,
        );
      }
    } on http.ClientException catch (e) {
      stopwatch.stop();
      print('❌ HTTP CLIENT ERROR: $e');
      return ApiResponse<T>(
        success: false,
        message: 'Network error: ${e.message}',
        error: e,
      );
    } catch (e) {
      stopwatch.stop();
      print('❌ UNEXPECTED ERROR: $e');
      return ApiResponse<T>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // PUT method
  Future<ApiResponse<T>> put<T>(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    
    try {
      print('\n🌐 PUT API CALL STARTED');
      print('📡 URL: $baseUrl$endpoint');
      print('📦 REQUEST BODY: $body');
      
      final url = Uri.parse('$baseUrl$endpoint');
      final defaultHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      
      final response = await http.put(
        url,
        headers: {...defaultHeaders, ...?headers},
        body: json.encode(body),
      ).timeout(timeout);

      stopwatch.stop();
      
      print('✅ PUT API CALL COMPLETED');
      print('⏱️ Response Time: ${stopwatch.elapsedMilliseconds}ms');
      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response Body: ${response.body}');
      
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print('🎉 PUT API SUCCESS');
        return ApiResponse<T>(
          success: true,
          message: responseData['message'] ?? 'Success',
          data: fromJson != null && responseData['data'] != null 
              ? fromJson(responseData['data']) 
              : null,
        );
      } else {
        print('❌ PUT API ERROR');
        print('❌ Error Message: ${responseData['message']}');
        
        return ApiResponse<T>(
          success: false,
          message: responseData['message'] ?? 'Request failed',
          error: responseData,
        );
      }
    } catch (e) {
      stopwatch.stop();
      print('❌ PUT API ERROR: $e');
      return ApiResponse<T>(
        success: false,
        message: e.toString(),
        error: e,
      );
    }
  }

  // DELETE method
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    
    try {
      print('\n🌐 DELETE API CALL STARTED');
      print('📡 URL: $baseUrl$endpoint');
      
      final url = Uri.parse('$baseUrl$endpoint');
      final defaultHeaders = {
        'Accept': 'application/json',
      };
      
      final response = await http.delete(
        url,
        headers: {...defaultHeaders, ...?headers},
      ).timeout(timeout);

      stopwatch.stop();
      
      print('✅ DELETE API CALL COMPLETED');
      print('⏱️ Response Time: ${stopwatch.elapsedMilliseconds}ms');
      print('📊 Status Code: ${response.statusCode}');
      print('📝 Response Body: ${response.body}');
      
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        print('🎉 DELETE API SUCCESS');
        return ApiResponse<T>(
          success: true,
          message: responseData['message'] ?? 'Success',
        );
      } else {
        print('❌ DELETE API ERROR');
        print('❌ Error Message: ${responseData['message']}');
        
        return ApiResponse<T>(
          success: false,
          message: responseData['message'] ?? 'Request failed',
          error: responseData,
        );
      }
    } catch (e) {
      stopwatch.stop();
      print('❌ DELETE API ERROR: $e');
      return ApiResponse<T>(
        success: false,
        message: e.toString(),
        error: e,
      );
    }
  }
}