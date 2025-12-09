// features/modules/branches/models/branch_models.dart
import 'package:flutter/material.dart';

// ==================== BRANCH MODELS ====================

class BranchAddress {
  final String line1;
  final String? line2;
  final String city;
  final String region;
  final String postalCode;
  final String country;

  BranchAddress({
    required this.line1,
    this.line2,
    required this.city,
    required this.region,
    required this.postalCode,
    required this.country,
  });

  factory BranchAddress.fromJson(Map<String, dynamic> json) => BranchAddress(
        line1: json["line1"] ?? "",
        line2: json["line2"],
        city: json["city"] ?? "",
        region: json["region"] ?? "",
        postalCode: json["postal_code"] ?? "",
        country: json["country"] ?? "Zimbabwe",
      );

  Map<String, dynamic> toJson() => {
        "line1": line1,
        if (line2 != null) "line2": line2,
        "city": city,
        "region": region,
        "postal_code": postalCode,
        "country": country,
      };

  String get fullAddress {
    final parts = [line1];
    if (line2 != null && line2!.isNotEmpty) parts.add(line2!);
    parts.addAll([city, region, country]);
    return parts.join(", ");
  }

  String get shortAddress => "$city, $region";
}

class BranchGeo {
  final String type;
  final List<double> coordinates;

  BranchGeo({
    required this.type,
    required this.coordinates,
  });

  factory BranchGeo.fromJson(Map<String, dynamic> json) => BranchGeo(
        type: json["type"] ?? "Point",
        coordinates: json["coordinates"] != null
            ? List<double>.from(json["coordinates"].map((x) => x.toDouble()))
            : [0.0, 0.0],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "coordinates": List<dynamic>.from(coordinates.map((x) => x)),
      };

  double get latitude => coordinates.isNotEmpty ? coordinates[1] : 0.0;
  double get longitude => coordinates.isNotEmpty ? coordinates[0] : 0.0;
}

class OpeningHour {
  final String open;
  final String close;

  OpeningHour({
    required this.open,
    required this.close,
  });

  factory OpeningHour.fromJson(Map<String, dynamic> json) => OpeningHour(
        open: json["open"] ?? "09:00",
        close: json["close"] ?? "17:00",
      );

  Map<String, dynamic> toJson() => {
        "open": open,
        "close": close,
      };

  String get formattedTime => "$open - $close";
}

class OpeningHours {
  final List<OpeningHour>? monday;
  final List<OpeningHour>? tuesday;
  final List<OpeningHour>? wednesday;
  final List<OpeningHour>? thursday;
  final List<OpeningHour>? friday;
  final List<OpeningHour>? saturday;
  final List<OpeningHour>? sunday;

  OpeningHours({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  factory OpeningHours.fromJson(Map<String, dynamic> json) => OpeningHours(
        monday: json["mon"] != null
            ? List<OpeningHour>.from(
                json["mon"].map((x) => OpeningHour.fromJson(x)))
            : null,
        tuesday: json["tue"] != null
            ? List<OpeningHour>.from(
                json["tue"].map((x) => OpeningHour.fromJson(x)))
            : null,
        wednesday: json["wed"] != null
            ? List<OpeningHour>.from(
                json["wed"].map((x) => OpeningHour.fromJson(x)))
            : null,
        thursday: json["thu"] != null
            ? List<OpeningHour>.from(
                json["thu"].map((x) => OpeningHour.fromJson(x)))
            : null,
        friday: json["fri"] != null
            ? List<OpeningHour>.from(
                json["fri"].map((x) => OpeningHour.fromJson(x)))
            : null,
        saturday: json["sat"] != null
            ? List<OpeningHour>.from(
                json["sat"].map((x) => OpeningHour.fromJson(x)))
            : null,
        sunday: json["sun"] != null
            ? List<OpeningHour>.from(
                json["sun"].map((x) => OpeningHour.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        if (monday != null) "mon": List<dynamic>.from(monday!.map((x) => x.toJson())),
        if (tuesday != null) "tue": List<dynamic>.from(tuesday!.map((x) => x.toJson())),
        if (wednesday != null) "wed": List<dynamic>.from(wednesday!.map((x) => x.toJson())),
        if (thursday != null) "thu": List<dynamic>.from(thursday!.map((x) => x.toJson())),
        if (friday != null) "fri": List<dynamic>.from(friday!.map((x) => x.toJson())),
        if (saturday != null) "sat": List<dynamic>.from(saturday!.map((x) => x.toJson())),
        if (sunday != null) "sun": List<dynamic>.from(sunday!.map((x) => x.toJson())),
      };

  String get todayHours {
    final now = DateTime.now();
    final day = now.weekday;
    
    switch (day) {
      case DateTime.monday:
        return _formatDayHours("Monday", monday);
      case DateTime.tuesday:
        return _formatDayHours("Tuesday", tuesday);
      case DateTime.wednesday:
        return _formatDayHours("Wednesday", wednesday);
      case DateTime.thursday:
        return _formatDayHours("Thursday", thursday);
      case DateTime.friday:
        return _formatDayHours("Friday", friday);
      case DateTime.saturday:
        return _formatDayHours("Saturday", saturday);
      case DateTime.sunday:
        return _formatDayHours("Sunday", sunday);
      default:
        return "Closed";
    }
  }

  String _formatDayHours(String dayName, List<OpeningHour>? hours) {
    if (hours == null || hours.isEmpty) return "$dayName: Closed";
    return "$dayName: ${hours.first.formattedTime}";
  }
}

class Branch {
  final String id;
  final String name;
  final String code;
  final BranchAddress address;
  final BranchGeo geo;
  final OpeningHours openingHours;
  final String phone;
  final String email;
  final String? imageLoc;
  final bool active;
  final DateTime createdAt;
  final DateTime updatedAt;

  Branch({
    required this.id,
    required this.name,
    required this.code,
    required this.address,
    required this.geo,
    required this.openingHours,
    required this.phone,
    required this.email,
    this.imageLoc,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        id: json["_id"] ?? json["id"] ?? '',
        name: json["name"] ?? '',
        code: json["code"] ?? '',
        address: BranchAddress.fromJson(json["address"] ?? {}),
        geo: BranchGeo.fromJson(json["geo"] ?? {}),
        openingHours: OpeningHours.fromJson(json["opening_hours"] ?? {}),
        phone: json["phone"] ?? '',
        email: json["email"] ?? '',
        imageLoc: json["imageLoc"],
        active: json["active"] ?? true,
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : DateTime.now(),
        updatedAt: json["updatedAt"] != null
            ? DateTime.parse(json["updatedAt"])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "code": code,
        "address": address.toJson(),
        "geo": geo.toJson(),
        "opening_hours": openingHours.toJson(),
        "phone": phone,
        "email": email,
        if (imageLoc != null) "imageLoc": imageLoc,
        "active": active,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };

  String get displayName => "$name ($code)";
  String get city => address.city;
  String get region => address.region;

  Color get statusColor => active ? Colors.green : Colors.red;
  String get statusText => active ? "Open" : "Closed";
}

// ==================== BRANCH STATUS RESPONSE ====================

class BranchStatusResponse {
  final Branch branch;
  final bool open;
  final DateTime at;

  BranchStatusResponse({
    required this.branch,
    required this.open,
    required this.at,
  });

  factory BranchStatusResponse.fromJson(Map<String, dynamic> json) =>
      BranchStatusResponse(
        branch: Branch.fromJson(json["branch"] ?? {}),
        open: json["open"] ?? false,
        at: json["at"] != null
            ? DateTime.parse(json["at"])
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        "branch": branch.toJson(),
        "open": open,
        "at": at.toIso8601String(),
      };
}

// ==================== API RESPONSE MODELS ====================

class BranchListResponse {
  final bool success;
  final String message;
  final List<Branch> data;

  BranchListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BranchListResponse.fromJson(Map<String, dynamic> json) =>
      BranchListResponse(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        data: json["data"] != null
            ? List<Branch>.from(
                json["data"].map((x) => Branch.fromJson(x)))
            : [],
      );
}

class BranchStatusCheckResponse {
  final bool success;
  final String message;
  final BranchStatusResponse data;

  BranchStatusCheckResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BranchStatusCheckResponse.fromJson(Map<String, dynamic> json) =>
      BranchStatusCheckResponse(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        data: BranchStatusResponse.fromJson(json["data"] ?? {}),
      );
}