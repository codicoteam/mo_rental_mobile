class LoginResponse {
  final UserData user;
  final String token;

  LoginResponse({
    required this.user,
    required this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: UserData.fromJson(json['user']),
      token: json['token'] ?? '',
    );
  }

  // Add toJson() method for LoginResponse
  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'token': token,
  };
}

class UserData {
  final String id;
  final String email;
  final String phone;
  final String fullName;
  final List<String> roles;
  final String status;
  final bool emailVerified;
  final List<dynamic> authProviders;
  final String createdAt;
  final String updatedAt;

  UserData({
    required this.id,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.roles,
    required this.status,
    required this.emailVerified,
    required this.authProviders,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      fullName: json['full_name'] ?? '',
      roles: List<String>.from(json['roles'] ?? []),
      status: json['status'] ?? '',
      emailVerified: json['email_verified'] ?? false,
      authProviders: json['auth_providers'] ?? [],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  // Fix UserData toJson() - remove 'user' and 'token' from here
  Map<String, dynamic> toJson() => {
    '_id': id,
    'email': email,
    'phone': phone,
    'full_name': fullName,
    'roles': roles,
    'status': status,
    'email_verified': emailVerified,
    'auth_providers': authProviders,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
  // Remove these lines from UserData.toJson():
  // 'user': user.toJson(),  // WRONG - this doesn't exist in UserData
  // 'token': token,         // WRONG - this doesn't exist in UserData
}