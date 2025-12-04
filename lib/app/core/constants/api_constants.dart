class ApiConstants {
  static const String baseUrl = 'http://13.61.185.238:5050';
  
  // Auth Endpoints
  static const String register = '/api/v1/users/register';
  static const String verifyEmail = '/api/v1/users/verify-email';
  static const String login = '/api/v1/users/login'; // Add if you have login
  static const String resendOtp = '/api/v1/users/resend-otp'; // Add if available
  
  // Common Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static const Duration apiTimeout = Duration(seconds: 30);
}