class VerifyEmailResponse {
  final String token;

  VerifyEmailResponse({required this.token});

  factory VerifyEmailResponse.fromJson(Map<String, dynamic> json) {
    return VerifyEmailResponse(
      token: json['token'] ?? '',
    );
  }
}