import '../../app/features/data/models/auth_models/api_response.dart';
import '../../app/features/data/models/auth_models/login_request.dart';
import '../../app/features/data/models/auth_models/login_response.dart';
import '../../app/features/data/models/auth_models/register_request.dart';
import '../../app/features/data/models/auth_models/register_response.dart';
import '../../app/features/data/models/auth_models/verify_email_request.dart';
import '../../app/features/data/models/auth_models/verify_email_response.dart';
import '../../app/features/data/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<ApiResponse<RegisterResponse>> register(RegisterRequest request) async {
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

  // ADD THIS LOGIN METHOD
  Future<ApiResponse<LoginResponse>> login(LoginRequest request) async {
    print('📤 LOGIN REQUEST: ${request.toJson()}');
    final response = await _apiService.post(
      '/api/v1/users/login',
      request.toJson(),
      fromJson: (data) => LoginResponse.fromJson(data),
    );
    print('📥 LOGIN RESPONSE: ${response.success} - ${response.message}');
    if (response.error != null) print('❌ LOGIN ERROR: ${response.error}');
    if (response.data != null) print('✅ LOGIN DATA: ${response.data!.toJson()}');
    return response;
  }

  Future<ApiResponse<VerifyEmailResponse>> verifyEmail(VerifyEmailRequest request) async {
    print('📤 VERIFY EMAIL REQUEST: ${request.toJson()}');
    final response = await _apiService.post(
      '/api/v1/users/verify-email',
      request.toJson(),
      fromJson: (data) => VerifyEmailResponse.fromJson(data),
    );
    print('📥 VERIFY EMAIL RESPONSE: ${response.success} - ${response.message}');
    return response;
  }
}