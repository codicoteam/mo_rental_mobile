class AppConstants {
  static const String baseUrl = 'http://13.61.185.238:5050';
  static const String registerEndpoint = '/api/v1/users/register';
  static const String verifyEmailEndpoint = '/api/v1/users/verify-email';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}