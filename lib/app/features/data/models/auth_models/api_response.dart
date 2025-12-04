// api_response.dart
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final dynamic error;  // CHANGE FROM String? to dynamic
  
  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,  // Now accepts any type
  });
  
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'error': error,
    };
  }
  
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      error: json['error'],
    );
  }
}