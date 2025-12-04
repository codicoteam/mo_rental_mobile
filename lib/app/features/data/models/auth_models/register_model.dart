import 'dart:convert';

class RegisterModel {
  final String fullName;
  final String email;
  final String phone;
  final String password;

  RegisterModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });

  factory RegisterModel.fromRawJson(String str) =>
      RegisterModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
        fullName: json["full_name"],
        email: json["email"],
        phone: json["phone"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "full_name": fullName,
        "email": email,
        "phone": phone,
        "password": password,
      };
}