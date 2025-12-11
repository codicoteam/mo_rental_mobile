import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/auth_models/api_response.dart';

class ApiService extends GetxService {
  static ApiService get to => Get.find();
  
  final String baseUrl = 'http://13.61.185.238:5050';
  final Duration timeout = Duration(seconds: 15);
  final GetStorage _storage = GetStorage();

  // Helper method to get headers with authorization token
  Future<Map<String, String>> _getHeaders({Map<String, String>? additionalHeaders}) async {
    final token = _storage.read<String>('auth_token');
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    // Add authorization header if token exists
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    // Merge with additional headers if provided
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    return headers;
  }

  // POST method - UPDATED to accept headers parameter
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
      
      // Get default headers and merge with provided headers
      final defaultHeaders = await _getHeaders();
      final finalHeaders = headers != null 
          ? {...defaultHeaders, ...headers}
          : defaultHeaders;
      
      // Log headers for debugging
      if (finalHeaders.containsKey('Authorization')) {
        final authHeader = finalHeaders['Authorization']!;
        print('🔑 Authorization: ${authHeader.substring(0, min(30, authHeader.length))}...');
      }
      
      final response = await http.post(
        url,
        headers: finalHeaders,
        body: json.encode(body),
      ).timeout(timeout, onTimeout: () {
        throw http.ClientException('Request timeout after ${timeout.inSeconds} seconds');
      });

      stopwatch.stop();
      
      print('✅ API CALL COMPLETED');
      print('⏱️ Response Time: ${stopwatch.elapsedMilliseconds}ms');
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
      print('⏱️ Failed after: ${stopwatch.elapsedMilliseconds}ms');
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
      print('⏱️ Failed after: ${stopwatch.elapsedMilliseconds}ms');
      return ApiResponse<T>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // GET method - UPDATED with headers parameter
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    
    try {
      print('\n🌐 GET API CALL STARTED');
      print('📡 URL: $baseUrl$endpoint');
      
      // Get default headers and merge with provided headers
      final defaultHeaders = await _getHeaders();
      final finalHeaders = headers != null 
          ? {...defaultHeaders, ...headers}
          : defaultHeaders;
      
      // Log headers for debugging
      if (finalHeaders.containsKey('Authorization')) {
        final authHeader = finalHeaders['Authorization']!;
        print('🔑 Authorization: ${authHeader.substring(0, min(30, authHeader.length))}...');
      }
      
      String url = '$baseUrl$endpoint';
      
      // Add query parameters if any
      if (queryParams != null && queryParams.isNotEmpty) {
        final queryString = Uri(queryParameters: queryParams).query;
        url += '?$queryString';
        print('🔍 Query Params: $queryParams');
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: finalHeaders,
      ).timeout(timeout);

      stopwatch.stop();
      
      print('✅ GET API CALL COMPLETED');
      print('⏱️ Response Time: ${stopwatch.elapsedMilliseconds}ms');
      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response Headers: ${response.headers}');
      
      // Check for authentication errors first
      if (response.statusCode == 401) {
        print('🔐 UNAUTHORIZED - Token may be invalid or expired');
        print('📝 Response Body: ${response.body}');
        
        // Clear token if unauthorized
        _storage.remove('auth_token');
        print('🗑️ Cleared invalid token from storage');
        
        return ApiResponse<T>(
          success: false,
          message: 'Session expired. Please login again.',
          error: {'statusCode': 401, 'message': 'Unauthorized'},
        );
      }
      
      final Map<String, dynamic> responseData = json.decode(response.body);
      print('📝 Response Data: $responseData');

      if (response.statusCode == 200) {
        print('🎉 GET API SUCCESS');
        return ApiResponse<T>(
          success: true,
          message: responseData['message'] ?? 'Success',
          data: fromJson != null && responseData['data'] != null 
              ? fromJson(responseData['data']) 
              : null,
        );
      } else {
        print('❌ GET API ERROR');
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
      return ApiResponse<T>(
        success: false,
        message: 'An unexpected error occurred: ${e.toString()}',
        error: e.toString(),
      );
    }
  }

  // PUT method - UPDATED with headers parameter
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
      
      // Get default headers and merge with provided headers
      final defaultHeaders = await _getHeaders();
      final finalHeaders = headers != null 
          ? {...defaultHeaders, ...headers}
          : defaultHeaders;
      
      final response = await http.put(
        url,
        headers: finalHeaders,
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

  // DELETE method - UPDATED with headers parameter
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    
    try {
      print('\n🌐 DELETE API CALL STARTED');
      print('📡 URL: $baseUrl$endpoint');
      
      final url = Uri.parse('$baseUrl$endpoint');
      
      // Get default headers and merge with provided headers
      final defaultHeaders = await _getHeaders();
      final finalHeaders = headers != null 
          ? {...defaultHeaders, ...headers}
          : defaultHeaders;
      
      final response = await http.delete(
        url,
        headers: finalHeaders,
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

  // In your ApiService class, add this method:
Future<ApiResponse<T>> patch<T>(
  String endpoint,
  Map<String, dynamic> body, {
  Map<String, String>? headers,
  T Function(Map<String, dynamic>)? fromJson,
}) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  
  try {
    print('\n🌐 PATCH API CALL STARTED');
    print('📡 URL: $baseUrl$endpoint');
    print('📦 REQUEST BODY: $body');
    
    final url = Uri.parse('$baseUrl$endpoint');
    
    // Get default headers and merge with provided headers
    final defaultHeaders = await _getHeaders();
    final finalHeaders = headers != null 
        ? {...defaultHeaders, ...headers}
        : defaultHeaders;
    
    final response = await http.patch(
      url,
      headers: finalHeaders,
      body: json.encode(body),
    ).timeout(timeout);

    stopwatch.stop();
    
    print('✅ PATCH API CALL COMPLETED');
    print('⏱️ Response Time: ${stopwatch.elapsedMilliseconds}ms');
    print('📊 Status Code: ${response.statusCode}');
    print('📝 Response Body: ${response.body}');
    
    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      print('🎉 PATCH API SUCCESS');
      return ApiResponse<T>(
        success: true,
        message: responseData['message'] ?? 'Success',
        data: fromJson != null && responseData['data'] != null 
            ? fromJson(responseData['data']) 
            : null,
      );
    } else {
      print('❌ PATCH API ERROR');
      print('❌ Error Message: ${responseData['message']}');
      
      return ApiResponse<T>(
        success: false,
        message: responseData['message'] ?? 'Request failed',
        error: responseData,
      );
    }
  } catch (e) {
    stopwatch.stop();
    print('❌ PATCH API ERROR: $e');
    return ApiResponse<T>(
      success: false,
      message: e.toString(),
      error: e,
    );
  }
}

  // Helper method to get the minimum of two values
  int min(int a, int b) => a < b ? a : b;

  // Optional: Method to check if user is authenticated
  bool get isAuthenticated {
    final token = _storage.read<String>('auth_token');
    return token != null && token.isNotEmpty;
  }

  // Optional: Method to get current token
  String? get currentToken => _storage.read<String>('auth_token');

  // Optional: Method to clear authentication
  void clearAuth() {
    _storage.remove('auth_token');
    print('🔐 Auth token cleared from ApiService');
  }
}