class DeleteAccountRequest {
  final String otp;

  DeleteAccountRequest({
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
    "otp": otp,
  };

  @override
  String toString() => 'DeleteAccountRequest(otp: $otp)';
}

class DeleteAccountResponse {
  final String message;
  final bool success;

  DeleteAccountResponse({
    required this.message,
    required this.success,
  });

  factory DeleteAccountResponse.fromJson(Map<String, dynamic> json) {
    return DeleteAccountResponse(
      message: json['message'] ?? '',
      success: json['success'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'success': success,
  };
}