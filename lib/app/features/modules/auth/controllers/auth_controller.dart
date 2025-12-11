import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../../domain/repositories/auth_repository.dart';
import '../../../../core/themes/app_palette.dart';
import '../../../data/models/auth_models/account_deletion_request.dart';
import '../../../data/models/auth_models/api_response.dart'
    as api_models; // ONLY KEEP THIS ONE
import '../../../data/models/auth_models/login_request.dart';
import '../../../data/models/auth_models/login_response.dart';
import '../../../data/models/auth_models/password_reset_request.dart';
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
  final RxBool isDeletingAccount = false.obs;
  final RxBool isResettingPassword = false.obs; // ADD THIS LINE - it's missing!
  
  final Rx<UserProfileResponse?> currentUserProfile = Rx<UserProfileResponse?>(null);
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


 
// In your AuthController's updateProfile method, add debug prints:
Future<api_models.ApiResponse<UserProfileResponse>> updateProfile({
  String? fullName,
  String? phone,
}) async {
  print('🎯 STARTING PROFILE UPDATE IN CONTROLLER');
  print('👤 Full Name to update: $fullName');
  print('📱 Phone to update: $phone');
  
  isUpdatingProfile.value = true;
  errorMessage.value = '';

  try {
    final request = UpdateProfileRequest(
      fullName: fullName,
      phone: phone,
    );

    print('📦 UPDATE REQUEST: ${request.toJson()}');
    
    // Validate request
    if (request.isEmpty) {
      print('❌ EMPTY REQUEST - No changes provided');
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
      print('✅ CONTROLLER: PROFILE UPDATE SUCCESSFUL');
      // Update the reactive current user profile
      currentUserProfile.value = response.data!;
      
      // Also update stored user data
      _storage.write('user_data', response.data!.toJson());
      
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
      print('❌ CONTROLLER: PROFILE UPDATE FAILED');
      errorMessage.value = response.message;
      print('❌ Error Message: ${response.message}');
      
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
    print('🔥 CONTROLLER: PROFILE UPDATE EXCEPTION');
    print('🔥 Error: $e');
    print('🔥 Stack trace: ${e.toString()}');
    
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
    print('🏁 PROFILE UPDATE PROCESS COMPLETED');
  }
}

// Also add these validation methods if they don't exist:
bool isValidPhone(String phone) {
  // Basic phone validation - adjust as needed
  final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
  final isValid = phoneRegex.hasMatch(phone);
  print('📱 Phone validation: "$phone" is ${isValid ? "valid" : "invalid"}');
  return isValid;
}

bool isValidName(String name) {
  final isValid = name.length >= 2 && name.length <= 50;
  print('👤 Name validation: "$name" (${name.length} chars) is ${isValid ? "valid" : "invalid"}');
  return isValid;
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

   // NEW: Request account deletion OTP
  Future<api_models.ApiResponse<DeleteAccountResponse>> requestAccountDeletion() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('🚀 REQUESTING ACCOUNT DELETION OTP');

      final response = await _authRepository.requestAccountDeletion();
      
      _printDebugInfo('REQUEST_ACCOUNT_DELETION', null, response);
      
      if (response.success) {
        print('✅ DELETE OTP REQUEST SUCCESSFUL');
        print('📧 OTP sent to email for account deletion');
        
        Get.snackbar(
          'OTP Sent',
          'An OTP has been sent to your email to confirm account deletion',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      } else {
        errorMessage.value = response.message;
        print('� DELETE OTP REQUEST FAILED: ${response.message}');
        
        Get.snackbar(
          'Request Failed',
          response.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      }
      
      return response;
    } catch (e) {
      print('🔥 DELETE OTP REQUEST EXCEPTION: $e');
      errorMessage.value = e.toString();
      
      Get.snackbar(
        'Error',
        'Failed to request account deletion: $e',
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

  // NEW: Confirm account deletion with OTP
  Future<api_models.ApiResponse<DeleteAccountResponse>> confirmAccountDeletion(String otp) async {
    isDeletingAccount.value = true;
    errorMessage.value = '';

    try {
      print('🚀 CONFIRMING ACCOUNT DELETION');
      print('🔢 OTP: $otp');

      final response = await _authRepository.confirmAccountDeletion(otp);
      
      _printDebugInfo('CONFIRM_ACCOUNT_DELETION', {'otp': otp}, response);
      
      if (response.success) {
        print('✅ ACCOUNT DELETION SUCCESSFUL');
        
        // Clear all user data
        logout();
        
        Get.snackbar(
          'Account Deleted',
          'Your account has been successfully deleted',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
        
        // Navigate to login screen
        Get.offAllNamed('/login');
      } else {
        errorMessage.value = response.message;
        print('❌ ACCOUNT DELETION FAILED: ${response.message}');
        
        if (response.message.toLowerCase().contains('invalid') || 
            response.message.toLowerCase().contains('expired')) {
          Get.snackbar(
            'Invalid OTP',
            'The OTP you entered is invalid or has expired',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
          );
        } else {
          Get.snackbar(
            'Deletion Failed',
            response.message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
          );
        }
      }
      
      return response;
    } catch (e) {
      print('🔥 ACCOUNT DELETION EXCEPTION: $e');
      errorMessage.value = e.toString();
      
      Get.snackbar(
        'Error',
        'Failed to delete account: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
      
      return api_models.ApiResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      isDeletingAccount.value = false;
    }
  }

   // NEW: Request password reset OTP
  Future<api_models.ApiResponse<PasswordResetResponse>> requestPasswordReset(String email) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      print('🚀 REQUESTING PASSWORD RESET OTP');
      print('📧 Email: $email');

      final response = await _authRepository.requestPasswordReset(email);
      
      _printDebugInfo('REQUEST_PASSWORD_RESET', {'email': email}, response);
      
      if (response.success) {
        print('✅ PASSWORD RESET OTP REQUEST SUCCESSFUL');
        print('📧 OTP sent to email for password reset');
        
        Get.snackbar(
          'OTP Sent',
          'An OTP has been sent to your email to reset your password',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      } else {
        errorMessage.value = response.message;
        print('❌ PASSWORD RESET OTP REQUEST FAILED: ${response.message}');
        
        if (response.message.toLowerCase().contains('not found')) {
          Get.snackbar(
            'Email Not Found',
            'No account found with this email address',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
          );
        } else {
          Get.snackbar(
            'Request Failed',
            response.message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
          );
        }
      }
      
      return response;
    } catch (e) {
      print('🔥 PASSWORD RESET REQUEST EXCEPTION: $e');
      errorMessage.value = e.toString();
      
      Get.snackbar(
        'Error',
        'Failed to request password reset: $e',
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

  // NEW: Reset password with OTP
  Future<api_models.ApiResponse<PasswordResetResponse>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    isResettingPassword.value = true;
    errorMessage.value = '';

    try {
      print('🚀 RESETTING PASSWORD');
      print('📧 Email: $email');
      print('🔢 OTP: $otp');

      final response = await _authRepository.resetPassword(
        email: email,
        otp: otp,
        newPassword: newPassword,
      );
      
      _printDebugInfo('RESET_PASSWORD', {'email': email, 'otp': otp}, response);
      
      if (response.success) {
        print('✅ PASSWORD RESET SUCCESSFUL');
        
        Get.snackbar(
          'Password Reset',
          'Your password has been reset successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
        
        // Navigate back to login screen
        Get.offAllNamed('/login');
      } else {
        errorMessage.value = response.message;
        print('❌ PASSWORD RESET FAILED: ${response.message}');
        
        if (response.message.toLowerCase().contains('invalid') || 
            response.message.toLowerCase().contains('expired')) {
          Get.snackbar(
            'Invalid OTP',
            'The OTP you entered is invalid or has expired',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
          );
        } else if (response.message.toLowerCase().contains('not found')) {
          Get.snackbar(
            'Email Not Found',
            'No account found with this email address',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
          );
        } else {
          Get.snackbar(
            'Reset Failed',
            response.message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: Duration(seconds: 5),
          );
        }
      }
      
      return response;
    } catch (e) {
      print('🔥 PASSWORD RESET EXCEPTION: $e');
      errorMessage.value = e.toString();
      
      Get.snackbar(
        'Error',
        'Failed to reset password: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
      
      return api_models.ApiResponse(
        success: false,
        message: e.toString(),
      );
    } finally {
      isResettingPassword.value = false;
    }
  }

  // NEW: Show forgot password dialog
  void showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    Get.defaultDialog(
      title: 'Forgot Password',
      titlePadding: const EdgeInsets.only(top: 20, bottom: 10),
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppPalette.primaryBlue,
      ),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        children: [
          const Icon(
            Icons.lock_reset,
            size: 60,
            color: AppPalette.primaryBlue,
          ),
          const SizedBox(height: 16),
          const Text(
            'Enter your email address',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'We will send you an OTP to reset your password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppPalette.primaryBlue),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (isLoading.value) {
              return const CircularProgressIndicator();
            }
            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = emailController.text.trim();
                      if (email.isEmpty) {
                        Get.snackbar(
                          'Email Required',
                          'Please enter your email address',
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
                        Get.snackbar(
                          'Invalid Email',
                          'Please enter a valid email address',
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      
                      final result = await requestPasswordReset(email);
                      if (result.success) {
                        Get.back(); // Close email dialog
                        await Future.delayed(const Duration(milliseconds: 500));
                        _showResetPasswordDialog(email);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Send OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      radius: 12,
    );
  }

 // Show reset password dialog - UPDATED VERSION
void _showResetPasswordDialog(String email) {
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final showPassword = false.obs;
  
  Get.defaultDialog(
    title: 'Reset Password',
    titlePadding: const EdgeInsets.only(top: 20, bottom: 10),
    titleStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppPalette.primaryBlue,
    ),
    contentPadding: const EdgeInsets.all(20),
    barrierDismissible: false, // Prevent closing by tapping outside
    content: SizedBox(
      width: Get.width * 0.9, // Set max width
      child: SingleChildScrollView( // ADD THIS - makes content scrollable
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min, // ADD THIS - prevents overflow
            children: [
              const Icon(
                Icons.email,
                size: 50,
                color: AppPalette.primaryBlue,
              ),
              const SizedBox(height: 16),
              Text(
                'OTP sent to $email',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter the OTP and your new password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              
              // OTP Field
              TextFormField(
                controller: otpController,
                decoration: InputDecoration(
                  labelText: 'OTP',
                  hintText: 'Enter 6-digit OTP',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter OTP';
                  }
                  if (value.length != 6) {
                    return 'OTP must be 6 digits';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // New Password Field
              Obx(() => TextFormField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter new password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword.value ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () => showPassword.value = !showPassword.value,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                obscureText: !showPassword.value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              )),
              
              const SizedBox(height: 16),
              
              // Confirm Password Field
              Obx(() => TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm new password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      showPassword.value ? Icons.visibility_off : Icons.visibility,
                      size: 20,
                    ),
                    onPressed: () => showPassword.value = !showPassword.value,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                obscureText: !showPassword.value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm password';
                  }
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              )),
              
              const SizedBox(height: 20),
              
              // Action Buttons
              Obx(() {
                if (isResettingPassword.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: CircularProgressIndicator(),
                  );
                }
                
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final otp = otpController.text.trim();
                            final newPassword = newPasswordController.text;
                            
                            await resetPassword(
                              email: email,
                              otp: otp,
                              newPassword: newPassword,
                            );
                            
                            if (!isResettingPassword.value) {
                              Get.back(); // Close dialog after completion
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppPalette.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 10),
                    
                    TextButton(
                      onPressed: () async {
                        Get.back(); // Close current dialog
                        await requestPasswordReset(email);
                        await Future.delayed(const Duration(milliseconds: 500));
                        _showResetPasswordDialog(email);
                      },
                      child: const Text(
                        'Resend OTP',
                        style: TextStyle(
                          color: AppPalette.primaryBlue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    ),
    radius: 12,
  );
}

  // Helper method to show delete confirmation dialog
  void showDeleteAccountDialog() {
    Get.defaultDialog(
      title: 'Delete Account',
      titlePadding: const EdgeInsets.only(top: 20, bottom: 10),
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 60,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          const Text(
            'Are you sure you want to delete your account?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This action cannot be undone. All your data will be permanently deleted.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (isLoading.value) {
              return const CircularProgressIndicator();
            }
            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back(); // Close confirmation dialog
                      await _initiateAccountDeletion();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Yes, Delete My Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      radius: 12,
    );
  }

  // Helper method to initiate account deletion process
  Future<void> _initiateAccountDeletion() async {
    final result = await requestAccountDeletion();
    
    if (result.success) {
      // Show OTP input dialog after OTP is sent
      await Future.delayed(const Duration(milliseconds: 500));
      _showOtpVerificationDialog();
    }
  }

  // Show OTP verification dialog
  void _showOtpVerificationDialog() {
    final otpController = TextEditingController();
    
    Get.defaultDialog(
      title: 'Confirm Account Deletion',
      titlePadding: const EdgeInsets.only(top: 20, bottom: 10),
      titleStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        children: [
          const Icon(
            Icons.email,
            size: 50,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          const Text(
            'Enter the OTP sent to your email',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check your email for the 6-digit OTP to confirm account deletion',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: otpController,
            decoration: InputDecoration(
              labelText: 'OTP',
              hintText: 'Enter 6-digit OTP',
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 20),
          Obx(() {
            if (isDeletingAccount.value) {
              return const CircularProgressIndicator();
            }
            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: () async {
                      final otp = otpController.text.trim();
                      if (otp.length != 6) {
                        Get.snackbar(
                          'Invalid OTP',
                          'Please enter a 6-digit OTP',
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      
                      await confirmAccountDeletion(otp);
                      if (isDeletingAccount.value == false) {
                        Get.back(); // Close dialog after completion
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Confirm Deletion',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () async {
                    Get.back(); // Close current dialog
                    await requestAccountDeletion();
                    await Future.delayed(const Duration(milliseconds: 500));
                    _showOtpVerificationDialog();
                  },
                  child: const Text(
                    'Resend OTP',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      radius: 12,
    );
  }
}

