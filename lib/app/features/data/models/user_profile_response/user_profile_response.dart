class UserProfileResponse {
  final String id;
  final String email;
  final String phone;
  final List<String> roles;
  final String fullName;
  final String status;
  final bool emailVerified;
  final List<dynamic> authProviders;
  final String createdAt;
  final String updatedAt;

  UserProfileResponse({
    required this.id,
    required this.email,
    required this.phone,
    required this.roles,
    required this.fullName,
    required this.status,
    required this.emailVerified,
    required this.authProviders,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      fullName: json['full_name'] ?? '',
      status: json['status'] ?? '',
      emailVerified: json['email_verified'] ?? false,
      authProviders: json['auth_providers'] ?? [],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'email': email,
    'phone': phone,
    'roles': roles,
    'full_name': fullName,
    'status': status,
    'email_verified': emailVerified,
    'auth_providers': authProviders,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}