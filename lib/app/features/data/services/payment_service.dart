// payment_service.dart - COMPLETE FIXED VERSION
import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../models/payment_models/payment_models.dart';

class PaymentService {
  static const String baseUrl = 'http://13.61.185.238:5050';
  final GetStorage _storage = GetStorage();

 // In your PaymentService class
Future<Map<String, String>> _getHeaders() async {
  try {
    // Try to get token from multiple possible locations
    final userData = _storage.read('user_data') ?? {};
    String? token;
    
    // Check ALL possible token locations including 'auth_token'
    token = userData['token'] ?? 
             userData['access_token'] ?? 
             _storage.read('access_token') ??
             _storage.read('token') ??
             _storage.read('auth_token'); // ADD THIS LINE!
    
    print('🔍 PaymentService: Looking for auth token...');
    print('   User data keys: ${userData.keys}');
    print('   Token found: ${token != null ? "YES (${token.substring(0, token.length > 10 ? 10 : token.length)}...)" : "NO"}');
    
    if (token == null || token.isEmpty) {
      print('❌ PaymentService: No authentication token found');
      print('   Checked locations: user_data[token], user_data[access_token], access_token, token, auth_token');
      throw Exception('Access denied. No token provided.');
    }
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  } catch (e) {
    print('❌ PaymentService Error in _getHeaders: $e');
    rethrow;
  }
}
  // API 1: Initiate Paynow redirect payment
  Future<PaymentInitiateResponse> initiatePayment({
    required String reservationId,
    required double amount,
    required String email,
    String? driverBookingId,
    String currency = 'USD',
    String? promoCode,
    String? reference,
    String? lineItem,
  }) async {
    try {
      print('💰 PaymentService: Initiating card payment for reservation $reservationId');
      
      final headers = await _getHeaders();
      final request = PaymentInitiateRequest(
        reservationId: reservationId,
        driverBookingId: driverBookingId,
        amount: amount,
        currency: currency,
        promoCode: promoCode,
        reference: reference ?? 'RES-$reservationId-${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        lineItem: lineItem,
      );

      print('📦 PaymentService Request body: ${request.toJson()}');
      print('🔑 PaymentService Headers: $headers');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/payments/initiate'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      print('📊 PaymentService Response status: ${response.statusCode}');
      print('📄 PaymentService Response body: ${response.body}');
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ PaymentService: Card payment initiated successfully');
        return PaymentInitiateResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        print('❌ PaymentService: Authentication failed (401)');
        throw Exception('Authentication failed. Please log in again.');
      } else {
        print('❌ PaymentService: API error ${response.statusCode}');
        throw Exception('Failed to initiate payment: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ PaymentService Error in initiatePayment: $e');
      rethrow;
    }
  }

  // API 2: Initiate mobile money payment
  Future<PaymentInitiateResponse> initiateMobilePayment({
    required String reservationId,
    required double amount,
    required String phone,
    required String mobileMethod,
    String? driverBookingId,
    String currency = 'USD',
    String? promoCode,
    String? reference,
    String? lineItem,
  }) async {
    try {
      print('📱 PaymentService: Initiating mobile payment for reservation $reservationId');
      print('   Phone: $phone, Method: $mobileMethod');
      
      final headers = await _getHeaders();
      final request = PaymentMobileRequest(
        reservationId: reservationId,
        driverBookingId: driverBookingId,
        amount: amount,
        currency: currency,
        promoCode: promoCode,
        reference: reference ?? 'RES-$reservationId-${DateTime.now().millisecondsSinceEpoch}',
        phone: phone,
        mobileMethod: mobileMethod,
        lineItem: lineItem,
      );

      print('📦 PaymentService Mobile request body: ${request.toJson()}');
      print('🔑 PaymentService Headers: $headers');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/payments/mobile'),
        headers: headers,
        body: json.encode(request.toJson()),
      );

      print('📊 PaymentService Mobile response status: ${response.statusCode}');
      print('📄 PaymentService Mobile response body: ${response.body}');
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ PaymentService: Mobile payment initiated successfully');
        return PaymentInitiateResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        print('❌ PaymentService: Authentication failed (401) for mobile payment');
        throw Exception('Access denied. No token provided.');
      } else {
        final error = json.decode(response.body);
        print('❌ PaymentService: Mobile payment API error ${response.statusCode}: $error');
        throw Exception(error['message'] ?? 'Mobile payment failed');
      }
    } catch (e) {
      print('❌ PaymentService Error in initiateMobilePayment: $e');
      rethrow;
    }
  }

  // API 3: Get payment status by polling
  Future<PaymentStatusResponse> getPaymentStatus(String paymentId) async {
    try {
      print('🔄 PaymentService: Getting payment status for $paymentId');
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/payments/$paymentId/status'),
        headers: headers,
      );

      print('📊 PaymentService Status response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ PaymentService: Got payment status successfully');
        return PaymentStatusResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        print('❌ PaymentService: Authentication failed (401) for status check');
        throw Exception('Authentication failed');
      } else {
        print('❌ PaymentService: Status check error ${response.statusCode}');
        throw Exception('Failed to get payment status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ PaymentService Error in getPaymentStatus: $e');
      rethrow;
    }
  }

  // API 4: Get single payment by ID
  Future<Payment?> getPayment(String paymentId) async {
    try {
      print('🔍 PaymentService: Getting payment details for $paymentId');
      
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/payments/$paymentId'),
        headers: headers,
      );

      print('📊 PaymentService Get payment response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['payment'] != null) {
          print('✅ PaymentService: Got payment details successfully');
          return Payment.fromJson(data['payment']);
        }
      } else if (response.statusCode == 401) {
        print('❌ PaymentService: Authentication failed (401) for get payment');
        throw Exception('Authentication failed');
      }
      return null;
    } catch (e) {
      print('❌ PaymentService Error in getPayment: $e');
      rethrow;
    }
  }

  // Poll payment status until it changes from pending
  Future<PaymentStatusResponse> pollPaymentStatus({
    required String paymentId,
    int maxAttempts = 30,
    int intervalSeconds = 2,
  }) async {
    print('⏳ PaymentService: Starting polling for payment $paymentId');
    
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        print('   Poll attempt ${attempt + 1}/$maxAttempts');
        final status = await getPaymentStatus(paymentId);
        
        // If payment is no longer pending, return
        if (status.payment != null && 
            status.payment!.paymentStatus.toLowerCase() != 'pending') {
          print('✅ PaymentService: Polling complete - status changed');
          return status;
        }

        print('   Payment still pending, waiting $intervalSeconds seconds...');
        // Wait before next poll
        await Future.delayed(Duration(seconds: intervalSeconds));
      } catch (e) {
        print('   Poll attempt ${attempt + 1} error: $e');
        // Continue polling on error
        await Future.delayed(Duration(seconds: intervalSeconds));
      }
    }
    
    print('❌ PaymentService: Polling timed out after $maxAttempts attempts');
    throw Exception('Payment polling timed out');
  }
}