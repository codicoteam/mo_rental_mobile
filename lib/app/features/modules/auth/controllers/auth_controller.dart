import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../data/models/auth_models/api_response.dart' as api_models; // ONLY KEEP THIS ONE
import '../../../data/models/auth_models/login_request.dart';
import '../../../data/models/auth_models/login_response.dart';
import '../../../data/models/auth_models/register_request.dart';
import '../../../data/models/auth_models/register_response.dart';
import '../../../data/models/auth_models/verify_email_request.dart';
import '../../../data/models/auth_models/verify_email_response.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final GetStorage _storage = GetStorage();
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Debug method to print all data
  void _printDebugInfo(String operation, dynamic request, api_models.ApiResponse response) {
    print('\n🔵🔵🔵 AUTH DEBUG INFO 🔵🔵🔵');
    print('Operation: $operation');
    print('Time: ${DateTime.now()}');
    print('Request: $request');
    print('Response Success: ${response.success}');
    print('Response Message: ${response.message}');
    print('Response Data: ${response.data}');
    print('Response Error: ${response.error}');
    print('🔵🔵🔵 END DEBUG INFO 🔵🔵🔵\n');
  }

  // Registration
  Future<api_models.ApiResponse<RegisterResponse>> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final request = RegisterRequest(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
      );

      print('🚀 STARTING REGISTRATION: $email');
      print('📱 Phone: $phone');
      print('👤 Name: $fullName');

      final response = await _authRepository.register(request);
      
      // Print debug info
      _printDebugInfo('REGISTRATION', request.toJson(), response);
      
      if (!response.success) {
        errorMessage.value = response.message;
        Get.snackbar(
          'Registration Failed',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      } else {
        // Store email for OTP verification
        _storage.write('pending_verification_email', email);
        print('✅ Email stored for verification: $email');
      }
      
      return response;
    } catch (e) {
      print('🔥 REGISTRATION EXCEPTION: $e');
      errorMessage.value = e.toString();
      
      if (e.toString().contains('Timeout') || e.toString().contains('timeout')) {
        Get.snackbar(
          'Network Timeout',
          'Connection timeout. Please check your internet and try again.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'Registration Error',
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      }
      
      return api_models.ApiResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Login Method
  Future<api_models.ApiResponse<LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final request = LoginRequest(email: email, password: password);

      print('🚀 STARTING LOGIN: $email');
      print('🔑 Password length: ${password.length}');

      final response = await _authRepository.login(request);
      
      // Print debug info
      _printDebugInfo('LOGIN', request.toJson(), response);
      
      if (response.success && response.data != null) {
        // Store token and user data
        _storage.write('auth_token', response.data!.token);
        _storage.write('user_email', email);
        _storage.write('user_data', response.data!.user.toJson());
        
        print('✅ LOGIN SUCCESSFUL');
        print('🔐 Token stored: ${response.data!.token.substring(0, 20)}...');
        print('👤 User: ${response.data!.user.fullName}');
        print('📞 Phone: ${response.data!.user.phone}');
        print('🎯 Status: ${response.data!.user.status}');
        print('✅ Email Verified: ${response.data!.user.emailVerified}');
        
        // Check if email is verified
        if (!response.data!.user.emailVerified) {
          print('⚠️ Email not verified, redirecting to verification');
          _storage.write('pending_verification_email', email);
          Get.offNamed('/verify-email', arguments: {'email': email});
        } else {
          print('✅ Email verified, redirecting to home');
          Get.offAllNamed('/main'); 
        }
      } else {
        errorMessage.value = response.message;
        print('❌ LOGIN FAILED: ${response.message}');
        Get.snackbar(
          'Login Failed',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      }
      
      return response;
    } catch (e) {
      print('🔥 LOGIN EXCEPTION: $e');
      errorMessage.value = e.toString();
      
      if (e.toString().contains('Timeout') || e.toString().contains('timeout')) {
        Get.snackbar(
          'Network Timeout',
          'Connection timeout. Please check your internet and try again.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'Login Error',
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      }
      
      return api_models.ApiResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Email Verification
  Future<api_models.ApiResponse<VerifyEmailResponse>> verifyEmail({  // CHANGED THIS LINE
    required String email,
    required String otp,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final request = VerifyEmailRequest(email: email, otp: otp);

      print('🚀 STARTING EMAIL VERIFICATION: $email');
      print('🔢 OTP: $otp');

      final response = await _authRepository.verifyEmail(request);
      
      // Print debug info
      _printDebugInfo('EMAIL VERIFICATION', request.toJson(), response);
      
      if (response.success && response.data != null) {
        // Store token
        _storage.write('auth_token', response.data!.token);
        _storage.write('user_email', email);
        
        // Clear pending verification
        _storage.remove('pending_verification_email');
        
        print('✅ EMAIL VERIFICATION SUCCESSFUL');
        print('🔐 Token stored: ${response.data!.token.substring(0, 20)}...');
        
        Get.offAllNamed('/main');
      } else {
        errorMessage.value = response.message;
        print('❌ VERIFICATION FAILED: ${response.message}');
        Get.snackbar(
          'Verification Failed',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      }
      
      return response;
    } catch (e) {
      print('🔥 VERIFICATION EXCEPTION: $e');
      errorMessage.value = e.toString();
      
      Get.snackbar(
        'Verification Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
      
      return api_models.ApiResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Check if user has pending verification
  String? get pendingVerificationEmail => 
      _storage.read('pending_verification_email');

  // Get stored user data
  Map<String, dynamic>? get userData => _storage.read('user_data');

  // Clear auth data
  void logout() {
    print('🚪 LOGGING OUT USER');
    _storage.remove('auth_token');
    _storage.remove('user_email');
    _storage.remove('user_data');
    _storage.remove('pending_verification_email');
    print('✅ ALL AUTH DATA CLEARED');
    Get.offAllNamed('/login');
  }

  // Check if user is authenticated
  bool get isAuthenticated => _storage.read('auth_token') != null;

  // Check if user is admin/manager
  bool get isAdminOrManager {
    final userData = _storage.read('user_data') ?? {};
    final roles = (userData['roles'] as List<dynamic>?) ?? [];
    return roles.any((role) => 
        role.toString().toLowerCase().contains('admin') ||
        role.toString().toLowerCase().contains('manager'));
  }

  // Print user role info for debugging
  void printUserRoleInfo() {
    final userData = _storage.read('user_data') ?? {};
    print('\n👤 ========== USER ROLE INFO ==========');
    print('👤 User ID: ${userData['_id']}');
    print('👤 Email: ${userData['email']}');
    print('👤 Name: ${userData['full_name']}');
    print('👤 Roles: ${userData['roles']}');
    print('👤 Status: ${userData['status']}');
    
    final roles = (userData['roles'] as List<dynamic>?) ?? [];
    final isAdminOrManager = roles.any((role) => 
        role.toString().toLowerCase().contains('admin') ||
        role.toString().toLowerCase().contains('manager'));
    
    print('👤 Is Admin/Manager: $isAdminOrManager');
    print('👤 =================================\n');
  }
}