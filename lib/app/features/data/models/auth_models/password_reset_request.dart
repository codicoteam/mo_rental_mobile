class ForgotPasswordRequest {
  final String email;

  ForgotPasswordRequest({
    required this.email,
  });

  Map<String, dynamic> toJson() => {
    "email": email,
  };

  @override
  String toString() => 'ForgotPasswordRequest(email: $email)';
}

class ResetPasswordRequest {
  final String email;
  final String otp;
  final String newPassword;

  ResetPasswordRequest({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    "email": email,
    "otp": otp,
    "new_password": newPassword,
  };

  @override
  String toString() => 'ResetPasswordRequest(email: $email, otp: $otp)';
}

class PasswordResetResponse {
  final String message;
  final bool success;

  PasswordResetResponse({
    required this.message,
    required this.success,
  });

  factory PasswordResetResponse.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'success': success,
  };
}