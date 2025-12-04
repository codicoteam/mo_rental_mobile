import 'dart:convert';

class VerifyEmailModel {
  final String email;
  final String otp;

  VerifyEmailModel({
    required this.email,
    required this.otp,
  });

  factory VerifyEmailModel.fromRawJson(String str) =>
      VerifyEmailModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory VerifyEmailModel.fromJson(Map<String, dynamic> json) =>
      VerifyEmailModel(
        email: json["email"],
        otp: json["otp"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "otp": otp,
      };
}