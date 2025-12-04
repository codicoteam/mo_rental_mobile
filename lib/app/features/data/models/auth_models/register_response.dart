class RegisterResponse {
  final String userId;
  final String email;
  final String status;

  RegisterResponse({
    required this.userId,
    required this.email,
    required this.status,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      userId: json['userId'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? '',
    );
  }
}