import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../data/models/auth_models/api_response.dart'
    as api_models; // ONLY KEEP THIS ONE
import '../../../data/models/auth_models/login_request.dart';
import '../../../data/models/auth_models/login_response.dart';
import '../../../data/models/auth_models/register_request.dart';
import '../../../data/models/auth_models/register_response.dart';
import '../../../data/models/auth_models/verify_email_request.dart';
import '../../../data/models/auth_models/verify_email_response.dart';
import '../../../data/models/user_profile_response/update_profile_request.dart';
import '../../../data/models/user_profile_response/user_profile_response.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final GetStorage _storage = GetStorage();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isUpdatingProfile = false.obs;

  final Rx<UserProfileResponse?> currentUserProfile =
      Rx<UserProfileResponse?>(null);

  // Add this to your AuthController class
  @override
  void onInit() {
    super.onInit();
    // Initialize user profile from storage when controller is created
    initUserProfile();
  }

  // Debug method to print all data
  void _printDebugInfo(
      String operation, dynamic request, api_models.ApiResponse response) {
    print('\n🔵🔵🔵 AUTH DEBUG INFO 🔵🔵🔵');
    print('Operation: $operation');
    print('Time: ${DateTime.now()}');
    if (request != null) print('Request: $request');
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

      if (e.toString().contains('Timeout') ||
          e.toString().contains('timeout')) {
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

        // Set current user profile from login response
        currentUserProfile.value = UserProfileResponse(
          id: response.data!.user.id,
          email: response.data!.user.email,
          phone: response.data!.user.phone,
          roles: response.data!.user.roles,
          fullName: response.data!.user.fullName,
          status: response.data!.user.status,
          emailVerified: response.data!.user.emailVerified,
          authProviders: response.data!.user.authProviders,
          createdAt: response.data!.user.createdAt,
          updatedAt: response.data!.user.updatedAt,
        );

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

      if (e.toString().contains('Timeout') ||
          e.toString().contains('timeout')) {
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
  Future<api_models.ApiResponse<VerifyEmailResponse>> verifyEmail({
    // CHANGED THIS LINE
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

  // Get current user profile
  // In your AuthController, update the getUserProfile method:
  Future<api_models.ApiResponse<UserProfileResponse>> getUserProfile() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('🚀 GETTING CURRENT USER PROFILE');

      final response = await _authRepository.getUserProfile();

      // Print debug info
      _printDebugInfo('GET_USER_PROFILE', null, response);

      if (response.success) {
        if (response.data != null) {
          // Update the reactive current user profile
          currentUserProfile.value = response.data!;

          // Also update stored user data for backward compatibility
          _storage.write('user_data', response.data!.toJson());

          print('✅ USER PROFILE FETCHED SUCCESSFULLY');
          print('👤 Name: ${response.data!.fullName}');
          print('📧 Email: ${response.data!.email}');
          print('📞 Phone: ${response.data!.phone}');
          print('🎯 Roles: ${response.data!.roles}');
          print('✅ Email Verified: ${response.data!.emailVerified}');
          print('🆔 User ID: ${response.data!.id}');
          print('📊 Status: ${response.data!.status}');

          // Check token storage
          final token = _storage.read('auth_token');
          if (token != null) {
            print('🔐 Token present in storage');
            print('🔐 Token preview: ${token.substring(0, 20)}...');
          } else {
            print('⚠️ No token found in storage');
          }

          // Notify UI
          Get.snackbar(
            'Profile Updated',
            'Successfully fetched latest profile data',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: Duration(seconds: 3),
          );
        } else {
          print('⚠️ Profile response successful but data is null');
          errorMessage.value = 'No user data received';
        }
      } else {
        errorMessage.value = response.message;
        print('❌ FAILED TO GET USER PROFILE: ${response.message}');

        // If unauthorized, user might need to login again
        if (response.message.toLowerCase().contains('unauthorized') ||
            response.message.toLowerCase().contains('token') ||
            response.message.toLowerCase().contains('session')) {
          print('🔐 Authentication error detected, logging out...');
          Get.snackbar(
            'Session Expired',
            'Please login again',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
          );
          logout();
        } else {
          Get.snackbar(
            'Profile Error',
            response.message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
          );
        }
      }

      return response;
    } catch (e) {
      print('🔥 GET USER PROFILE EXCEPTION: $e');
      errorMessage.value = e.toString();

      if (e.toString().contains('Timeout') ||
          e.toString().contains('timeout')) {
        Get.snackbar(
          'Network Timeout',
          'Connection timeout. Please check your internet and try again.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          'Profile Error',
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


  // NEW METHOD: Update user profile
  Future<api_models.ApiResponse<UserProfileResponse>> updateProfile({
    String? fullName,
    String? phone,
  }) async {
    isUpdatingProfile.value = true;
    errorMessage.value = '';

    try {
      final request = UpdateProfileRequest(
        fullName: fullName,
        phone: phone,
      );

      print('🚀 UPDATING USER PROFILE');
      print('📋 Request: ${request.toJson()}');
      
      // Validate request
      if (request.isEmpty) {
        errorMessage.value = 'No changes provided';
        Get.snackbar(
          'Update Failed',
          'Please provide at least one field to update',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        
        return api_models.ApiResponse(
          success: false,
          message: 'No changes provided',
        );
      }

      final response = await _authRepository.updateProfile(request);
      
      // Print debug info
      _printDebugInfo('UPDATE_PROFILE', request.toJson(), response);
      
      if (response.success && response.data != null) {
        // Update the reactive current user profile
        currentUserProfile.value = response.data!;
        
        // Also update stored user data
        _storage.write('user_data', response.data!.toJson());
        
        print('✅ PROFILE UPDATED SUCCESSFULLY');
        print('👤 New Name: ${response.data!.fullName}');
        print('📞 New Phone: ${response.data!.phone}');
        print('📅 Updated At: ${response.data!.updatedAt}');
        
        // Show success message
        Get.snackbar(
          'Profile Updated',
          'Your profile has been updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        
        // Refresh the profile to get latest data
        await getUserProfile();
      } else {
        errorMessage.value = response.message;
        print('❌ PROFILE UPDATE FAILED: ${response.message}');
        
        Get.snackbar(
          'Update Failed',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      }
      
      return response;
    } catch (e) {
      print('🔥 PROFILE UPDATE EXCEPTION: $e');
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
          'Update Error',
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
      isUpdatingProfile.value = false;
    }
  }

  // Helper method to validate phone number
  bool isValidPhone(String phone) {
    // Basic phone validation - adjust as needed
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    return phoneRegex.hasMatch(phone);
  }

  // Helper method to validate name
  bool isValidName(String name) {
    return name.length >= 2 && name.length <= 50;
  }




  // Check if user has pending verification
  String? get pendingVerificationEmail =>
      _storage.read('pending_verification_email');

  // Get stored user data
  Map<String, dynamic>? get userData => _storage.read('user_data');

  // Getter for current user profile
  UserProfileResponse? get userProfile => currentUserProfile.value;

  // Clear auth data
  void logout() {
    print('🚪 LOGGING OUT USER');
    _storage.remove('auth_token');
    _storage.remove('user_email');
    _storage.remove('user_data');
    _storage.remove('pending_verification_email');
    currentUserProfile.value = null; // Clear the reactive profile
    print('✅ ALL AUTH DATA CLEARED');
    Get.offAllNamed('/login');
  }

  // Check if user is authenticated
  bool get isAuthenticated => _storage.read('auth_token') != null;

  // Check if user is admin/manager
  bool get isAdminOrManager {
    // First try to use the current user profile
    if (currentUserProfile.value != null) {
      return currentUserProfile.value!.roles.any((role) =>
          role.toLowerCase().contains('admin') ||
          role.toLowerCase().contains('manager'));
    }

    // Fallback to stored data
    final userData = _storage.read('user_data') ?? {};
    final roles = (userData['roles'] as List<dynamic>?) ?? [];
    return roles.any((role) =>
        role.toString().toLowerCase().contains('admin') ||
        role.toString().toLowerCase().contains('manager'));
  }

  // Print user role info for debugging
  void printUserRoleInfo() {
    print('\n👤 ========== USER ROLE INFO ==========');

    if (currentUserProfile.value != null) {
      final user = currentUserProfile.value!;
      print('👤 User ID: ${user.id}');
      print('👤 Email: ${user.email}');
      print('👤 Name: ${user.fullName}');
      print('👤 Roles: ${user.roles}');
      print('👤 Status: ${user.status}');
      print('👤 Is Admin/Manager: $isAdminOrManager');
    } else {
      final userData = _storage.read('user_data') ?? {};
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
    }

    print('👤 Token Present: ${isAuthenticated ? 'Yes' : 'No'}');
    print(
        '👤 Profile Loaded: ${currentUserProfile.value != null ? 'Yes' : 'No'}');
    print('👤 =================================\n');
  }

  // Initialize user profile from storage on app start
  void initUserProfile() {
    final userData = _storage.read('user_data');
    if (userData != null && isAuthenticated) {
      try {
        currentUserProfile.value = UserProfileResponse(
          id: userData['_id'] ?? '',
          email: userData['email'] ?? '',
          phone: userData['phone'] ?? '',
          roles: List<String>.from(userData['roles'] ?? []),
          fullName: userData['full_name'] ?? '',
          status: userData['status'] ?? '',
          emailVerified: userData['email_verified'] ?? false,
          authProviders: userData['auth_providers'] ?? [],
          createdAt: userData['created_at'] ?? '',
          updatedAt: userData['updated_at'] ?? '',
        );
        print('✅ User profile initialized from storage');
      } catch (e) {
        print('❌ Failed to initialize user profile from storage: $e');
      }
    }
  }
}
