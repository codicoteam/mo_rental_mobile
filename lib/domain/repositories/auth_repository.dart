import '../../app/features/data/models/auth_models/api_response.dart';
import '../../app/features/data/models/auth_models/login_request.dart';
import '../../app/features/data/models/auth_models/login_response.dart';
import '../../app/features/data/models/auth_models/password_reset_request.dart';
import '../../app/features/data/models/auth_models/register_request.dart';
import '../../app/features/data/models/auth_models/register_response.dart';
import '../../app/features/data/models/auth_models/verify_email_request.dart';
import '../../app/features/data/models/auth_models/verify_email_response.dart';
import '../../app/features/data/models/user_profile_response/update_profile_request.dart';
import '../../app/features/data/models/user_profile_response/user_profile_response.dart';
import '../../app/features/data/models/auth_models/account_deletion_request.dart'; // MAKE SURE THIS IMPORT EXISTS
import '../../app/features/data/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<ApiResponse<RegisterResponse>> register(
      RegisterRequest request) async {
    print('📤 REGISTER REQUEST: ${request.toJson()}');
    final response = await _apiService.post(
      '/api/v1/users/register',
      request.toJson(),
      fromJson: (data) => RegisterResponse.fromJson(data),
    );
    print('📥 REGISTER RESPONSE: ${response.success} - ${response.message}');
    if (response.error != null) print('❌ ERROR: ${response.error}');
    return response;
  }

  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    print('📤 LOGIN REQUEST: ${request.toJson()}');
    final response = await _apiService.post(
      '/api/v1/users/login',
      request.toJson(),
      fromJson: (data) => LoginResponse.fromJson(data),
    );
    print('📥 LOGIN RESPONSE: ${response.success} - ${response.message}');
    if (response.error != null) print('❌ LOGIN ERROR: ${response.error}');
    if (response.data != null) {
      print('✅ LOGIN DATA: ${response.data!.toJson()}');
    }
    return response;
  }

  Future<ApiResponse<VerifyEmailResponse>> verifyEmail(
      VerifyEmailRequest request) async {
    print('📤 VERIFY EMAIL REQUEST: ${request.toJson()}');
    final response = await _apiService.post(
      '/api/v1/users/verify-email',
      request.toJson(),
      fromJson: (data) => VerifyEmailResponse.fromJson(data),
    );
    print(
        '📥 VERIFY EMAIL RESPONSE: ${response.success} - ${response.message}');
    return response;
  }

  Future<ApiResponse<UserProfileResponse>> getUserProfile() async {
    print('📤 GETTING USER PROFILE');

    final response = await _apiService.get(
      '/api/v1/users/me',
      fromJson: (data) {
        print('🔄 PARSING USER PROFILE DATA: $data');
        return UserProfileResponse.fromJson(data);
      },
    );

    print(
        '📥 USER PROFILE RESPONSE: ${response.success} - ${response.message}');
    if (response.error != null) print('❌ PROFILE ERROR: ${response.error}');
    if (response.data != null) {
      print('✅ PROFILE DATA: ${response.data!.toJson()}');
      print('👤 User Profile Parsed Successfully');
      print('📧 Email: ${response.data!.email}');
      print('👤 Name: ${response.data!.fullName}');
      print('📞 Phone: ${response.data!.phone}');
      print('🎯 Roles: ${response.data!.roles}');
      print('✅ Email Verified: ${response.data!.emailVerified}');
    } else {
      print('⚠️ No profile data received');
    }

    return response;
  }

  Future<ApiResponse<UserProfileResponse>> updateProfile(
      UpdateProfileRequest request) async {
    print('📤 UPDATING USER PROFILE');
    print('📦 REQUEST DATA: ${request.toJson()}');

    final response = await _apiService.patch(
      '/api/v1/users/me',
      request.toJson(),
      fromJson: (data) => UserProfileResponse.fromJson(data),
    );

    print(
        '📥 UPDATE PROFILE RESPONSE: ${response.success} - ${response.message}');
    if (response.error != null) print('❌ UPDATE ERROR: ${response.error}');
    if (response.data != null) {
      print('✅ UPDATED PROFILE DATA: ${response.data!.toJson()}');
    }

    return response;
  }

  // ADD THESE TWO METHODS - THEY WERE MISSING:

  // Request account deletion (send OTP)
  Future<ApiResponse<DeleteAccountResponse>> requestAccountDeletion() async {
    print('📤 REQUESTING ACCOUNT DELETION OTP');

    final response = await _apiService.post(
      '/api/v1/users/me/request-delete',
      {}, // Empty body as shown in the API docs
      fromJson: (data) => DeleteAccountResponse.fromJson(data),
    );

    print(
        '📥 DELETE REQUEST RESPONSE: ${response.success} - ${response.message}');
    if (response.error != null) {
      print('❌ DELETE REQUEST ERROR: ${response.error}');
    }

    return response;
  }

  // Confirm account deletion with OTP
  Future<ApiResponse<DeleteAccountResponse>> confirmAccountDeletion(
      String otp) async {
    print('📤 CONFIRMING ACCOUNT DELETION WITH OTP');

    final request = DeleteAccountRequest(otp: otp);
    print('🔢 OTP: $otp');

    final response = await _apiService.post(
      '/api/v1/users/me/confirm-delete',
      request.toJson(),
      fromJson: (data) => DeleteAccountResponse.fromJson(data),
    );

    print(
        '📥 DELETE CONFIRMATION RESPONSE: ${response.success} - ${response.message}');
    if (response.error != null) {
      print('❌ DELETE CONFIRMATION ERROR: ${response.error}');
    }

    return response;
  }

  // NEW: Request password reset OTP
  Future<ApiResponse<PasswordResetResponse>> requestPasswordReset(
      String email) async {
    print('📤 REQUESTING PASSWORD RESET OTP');
    print('📧 Email: $email');

    final request = ForgotPasswordRequest(email: email);

    final response = await _apiService.post(
      '/api/v1/users/forgot-password/request-otp',
      request.toJson(),
      fromJson: (data) => PasswordResetResponse.fromJson(data),
    );

    print(
        '📥 PASSWORD RESET REQUEST RESPONSE: ${response.success} - ${response.message}');
    if (response.error != null) {
      print('❌ PASSWORD RESET REQUEST ERROR: ${response.error}');
    }

    return response;
  }

  // NEW: Reset password with OTP
  Future<ApiResponse<PasswordResetResponse>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    print('📤 RESETTING PASSWORD');
    print('📧 Email: $email');
    print('🔢 OTP: $otp');
    print('🔑 New password length: ${newPassword.length}');

    final request = ResetPasswordRequest(
      email: email,
      otp: otp,
      newPassword: newPassword,
    );

    final response = await _apiService.post(
      '/api/v1/users/forgot-password/reset',
      request.toJson(),
      fromJson: (data) => PasswordResetResponse.fromJson(data),
    );

    print(
        '📥 PASSWORD RESET RESPONSE: ${response.success} - ${response.message}');
    if (response.error != null) {
      print('❌ PASSWORD RESET ERROR: ${response.error}');
    }

    return response;
  }
}
