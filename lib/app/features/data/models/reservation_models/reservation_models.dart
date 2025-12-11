import 'package:flutter/material.dart';

// ==================== AVAILABILITY MODELS ====================

class AvailabilityRequest {
  final String? vehicleId;
  final DateTime start;
  final DateTime end;

  AvailabilityRequest({
    this.vehicleId,
    required this.start,
    required this.end,
  });

  factory AvailabilityRequest.fromJson(Map<String, dynamic> json) =>
      AvailabilityRequest(
        vehicleId: json["vehicle_id"],
        start: DateTime.parse(json["start"]),
        end: DateTime.parse(json["end"]),
      );

  Map<String, dynamic> toJson() => {
        if (vehicleId != null && vehicleId!.isNotEmpty) "vehicle_id": vehicleId,
        "start": start.toIso8601String(),
        "end": end.toIso8601String(),
      };
}

class AvailabilityResponse {
  final bool available;
  final String? message;
  final List<Conflict>? conflicts;
  final VehicleInfo? vehicle;

  AvailabilityResponse({
    required this.available,
    this.message,
    this.conflicts,
    this.vehicle,
  });

  factory AvailabilityResponse.fromJson(Map<String, dynamic> json) =>
      AvailabilityResponse(
        available: json["available"] ?? false,
        message: json["message"],
        conflicts: json["conflicts"] != null
            ? List<Conflict>.from(
                json["conflicts"].map((x) => Conflict.fromJson(x)))
            : null,
        vehicle: json["vehicle"] != null
            ? VehicleInfo.fromJson(json["vehicle"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "available": available,
        if (message != null) "message": message,
        if (conflicts != null)
          "conflicts": List<dynamic>.from(conflicts!.map((x) => x.toJson())),
        if (vehicle != null) "vehicle": vehicle!.toJson(),
      };
}

class Conflict {
  final String? reservationId;
  final DateTime start;
  final DateTime end;
  final String? status;

  Conflict({
    this.reservationId,
    required this.start,
    required this.end,
    this.status,
  });

  factory Conflict.fromJson(Map<String, dynamic> json) => Conflict(
        reservationId: json["reservation_id"],
        start: DateTime.parse(json["start"]),
        end: DateTime.parse(json["end"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        if (reservationId != null) "reservation_id": reservationId,
        "start": start.toIso8601String(),
        "end": end.toIso8601String(),
        if (status != null) "status": status,
      };
}

class VehicleInfo {
  final String id;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final String? color;
  final String? fuelType;
  final int seatingCapacity;
  final double dailyRate;
  final bool isAvailable;

  VehicleInfo({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    this.color,
    this.fuelType,
    required this.seatingCapacity,
    required this.dailyRate,
    required this.isAvailable,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) => VehicleInfo(
        id: json["_id"] ?? json["id"] ?? '',
        make: json["make"] ?? '',
        model: json["model"] ?? '',
        year: json["year"] ?? 0,
        licensePlate: json["license_plate"] ?? '',
        color: json["color"],
        fuelType: json["fuel_type"],
        seatingCapacity: json["seating_capacity"] ?? 0,
        dailyRate: (json["daily_rate"] ?? 0).toDouble(),
        isAvailable: json["is_available"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "make": make,
        "model": model,
        "year": year,
        "license_plate": licensePlate,
        if (color != null) "color": color,
        if (fuelType != null) "fuel_type": fuelType,
        "seating_capacity": seatingCapacity,
        "daily_rate": dailyRate,
        "is_available": isAvailable,
      };

  String get displayName => "$year $make $model";
  String get formattedDailyRate => "\$${dailyRate.toStringAsFixed(2)}/day";

  String get details {
    return "$seatingCapacity seats • ${fuelType ?? 'Unknown fuel'} • ${color ?? 'Various colors'}";
  }
}

// ==================== CREATE RESERVATION MODELS ====================

class CreateReservationRequest {
  final String createdChannel;
  final String vehicleId;
  final String? vehicleModelId;
  final BranchTime pickup;
  final BranchTime dropoff;
  final ReservationPricing pricing;
  final ReservationPaymentSummary? paymentSummary;
  final ReservationDriverSnapshot driverSnapshot;
  final String? notes;
  final String code; // REQUIRED FIELD
  final String? userId;

  CreateReservationRequest({
    required this.createdChannel,
    required this.vehicleId,
    this.vehicleModelId,
    required this.pickup,
    required this.dropoff,
    required this.pricing,
    this.paymentSummary,
    required this.driverSnapshot,
    this.notes,
    required this.code, // REQUIRED
    this.userId,
  });

  Map<String, dynamic> toJson() => {
        "created_channel": createdChannel,
        "vehicle_id": vehicleId,
        if (vehicleModelId != null) "vehicle_model_id": vehicleModelId,
        "code": code, // REQUIRED
        "pickup": pickup.toJson(),
        "dropoff": dropoff.toJson(),
        "pricing": pricing.toJson(),
        if (paymentSummary != null) "payment_summary": paymentSummary!.toJson(),
        "driver_snapshot": driverSnapshot.toJson(),
        if (notes != null && notes!.isNotEmpty) "notes": notes,
        if (userId != null) "user_id": userId,
      };
}

class BranchTime {
  final String branchId;
  final DateTime at;

  BranchTime({
    required this.branchId,
    required this.at,
  });

  Map<String, dynamic> toJson() => {
        "branch_id": branchId,
        "at": at.toIso8601String(),
      };

  factory BranchTime.fromJson(Map<String, dynamic> json) => BranchTime(
        branchId: json["branch_id"],
        at: DateTime.parse(json["at"]),
      );
}

class ReservationPricing {
  final String currency;
  final List<PriceBreakdownItem> breakdown;
  final List<ReservationFee> fees;
  final List<ReservationTax> taxes;
  final List<ReservationDiscount> discounts;
  final double grandTotal;
  final DateTime computedAt;

  ReservationPricing({
    required this.currency,
    required this.breakdown,
    required this.fees,
    required this.taxes,
    required this.discounts,
    required this.grandTotal,
    required this.computedAt,
  });

  Map<String, dynamic> toJson() => {
        "currency": currency,
        "breakdown": breakdown.map((item) => item.toJson()).toList(),
        "fees": fees.map((item) => item.toJson()).toList(),
        "taxes": taxes.map((item) => item.toJson()).toList(),
        "discounts": discounts.map((item) => item.toJson()).toList(),
        "grand_total": grandTotal.toStringAsFixed(2),
        "computed_at": computedAt.toIso8601String(),
      };

  factory ReservationPricing.fromJson(Map<String, dynamic> json) =>
      ReservationPricing(
        currency: json["currency"] ?? "USD",
        breakdown: json["breakdown"] != null
            ? List<PriceBreakdownItem>.from(
                json["breakdown"].map((x) => PriceBreakdownItem.fromJson(x)))
            : [],
        fees: json["fees"] != null
            ? List<ReservationFee>.from(
                json["fees"].map((x) => ReservationFee.fromJson(x)))
            : [],
        taxes: json["taxes"] != null
            ? List<ReservationTax>.from(
                json["taxes"].map((x) => ReservationTax.fromJson(x)))
            : [],
        discounts: json["discounts"] != null
            ? List<ReservationDiscount>.from(
                json["discounts"].map((x) => ReservationDiscount.fromJson(x)))
            : [],
        grandTotal: (json["grand_total"] ?? 0).toDouble(),
        computedAt: json["computed_at"] != null
            ? DateTime.parse(json["computed_at"])
            : DateTime.now(),
      );
}

class PriceBreakdownItem {
  final String label;
  final int quantity;
  final double unitAmount;
  final double total;

  PriceBreakdownItem({
    required this.label,
    required this.quantity,
    required this.unitAmount,
    required this.total,
  });

  Map<String, dynamic> toJson() => {
        "label": label,
        "quantity": quantity,
        "unit_amount": unitAmount.toStringAsFixed(2),
        "total": total.toStringAsFixed(2),
      };

  factory PriceBreakdownItem.fromJson(Map<String, dynamic> json) =>
      PriceBreakdownItem(
        label: json["label"] ?? "",
        quantity: json["quantity"] ?? 0,
        unitAmount: (json["unit_amount"] ?? 0).toDouble(),
        total: (json["total"] ?? 0).toDouble(),
      );
}

class ReservationFee {
  final String code;
  final double amount;

  ReservationFee({
    required this.code,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        "code": code,
        "amount": amount.toStringAsFixed(2),
      };

  factory ReservationFee.fromJson(Map<String, dynamic> json) => ReservationFee(
        code: json["code"] ?? "",
        amount: (json["amount"] ?? 0).toDouble(),
      );
}

class ReservationTax {
  final String code;
  final double rate;
  final double amount;

  ReservationTax({
    required this.code,
    required this.rate,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        "code": code,
        "rate": rate,
        "amount": amount.toStringAsFixed(2),
      };

  factory ReservationTax.fromJson(Map<String, dynamic> json) => ReservationTax(
        code: json["code"] ?? "",
        rate: (json["rate"] ?? 0).toDouble(),
        amount: (json["amount"] ?? 0).toDouble(),
      );
}

class ReservationDiscount {
  final String? promoCodeId;
  final double amount;

  ReservationDiscount({
    this.promoCodeId,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        if (promoCodeId != null) "promo_code_id": promoCodeId,
        "amount": amount.toStringAsFixed(2),
      };

  factory ReservationDiscount.fromJson(Map<String, dynamic> json) =>
      ReservationDiscount(
        promoCodeId: json["promo_code_id"],
        amount: (json["amount"] ?? 0).toDouble(),
      );
}

class ReservationPaymentSummary {
  final String status;
  final double paidTotal;
  final double outstanding;
  final DateTime? lastPaymentAt;

  ReservationPaymentSummary({
    required this.status,
    required this.paidTotal,
    required this.outstanding,
    this.lastPaymentAt,
  });

  Map<String, dynamic> toJson() => {
        "status": status,
        "paid_total": paidTotal.toStringAsFixed(2),
        "outstanding": outstanding.toStringAsFixed(2),
        if (lastPaymentAt != null)
          "last_payment_at": lastPaymentAt!.toIso8601String(),
      };

  factory ReservationPaymentSummary.fromJson(Map<String, dynamic> json) =>
      ReservationPaymentSummary(
        status: json["status"] ?? "unpaid",
        paidTotal: (json["paid_total"] ?? 0).toDouble(),
        outstanding: (json["outstanding"] ?? 0).toDouble(),
        lastPaymentAt: json["last_payment_at"] != null
            ? DateTime.parse(json["last_payment_at"])
            : null,
      );
}

class ReservationDriverSnapshot {
  final String fullName;
  final String phone;
  final String email;
  final ReservationDriverLicense driverLicense;

  ReservationDriverSnapshot({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.driverLicense,
  });

  Map<String, dynamic> toJson() => {
        "full_name": fullName,
        "phone": phone,
        "email": email,
        "driver_license": driverLicense.toJson(),
      };

  factory ReservationDriverSnapshot.fromJson(Map<String, dynamic> json) =>
      ReservationDriverSnapshot(
        fullName: json["full_name"] ?? "",
        phone: json["phone"] ?? "",
        email: json["email"] ?? "",
        driverLicense: ReservationDriverLicense.fromJson(
            json["driver_license"] ?? {}),
      );
}

class ReservationDriverLicense {
  final String number;
  final String country;
  final String licenseClass;
  final DateTime expiresAt;
  final bool verified;

  ReservationDriverLicense({
    required this.number,
    required this.country,
    required this.licenseClass,
    required this.expiresAt,
    required this.verified,
  });

  Map<String, dynamic> toJson() => {
        "number": number,
        "country": country,
        "class": licenseClass,
        "expires_at": expiresAt.toIso8601String(),
        "verified": verified,
      };

  factory ReservationDriverLicense.fromJson(Map<String, dynamic> json) =>
      ReservationDriverLicense(
        number: json["number"] ?? "NOT_PROVIDED",
        country: json["country"] ?? "ZW",
        licenseClass: json["class"] ?? "Class 4",
        expiresAt: json["expires_at"] != null
            ? DateTime.parse(json["expires_at"])
            : DateTime.now().add(const Duration(days: 365 * 5)),
        verified: json["verified"] ?? false,
      );
}

class CreateReservationResponse {
  final bool success;
  final String message;
  final Reservation? data;

  CreateReservationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateReservationResponse.fromJson(Map<String, dynamic> json) {
    try {
      print('📦 Parsing CreateReservationResponse from JSON...');
      
      // Check if we have valid data to parse
      if (json['data'] == null) {
        print('⚠️ No data field in response');
        return CreateReservationResponse(
          success: json["success"] ?? false,
          message: json["message"] ?? '',
          data: null,
        );
      }
      
      // Try to parse the reservation data
      final dataJson = json['data'] as Map<String, dynamic>;
      
      print('✅ Successfully parsed reservation data');
      return CreateReservationResponse(
        success: json["success"] ?? false,
        message: json["message"] ?? '',
        data: Reservation.fromJson(dataJson),
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing CreateReservationResponse: $e');
      print('📋 Stack trace: $stackTrace');
      print('📋 Raw JSON data: $json');
      
      // Return a response without data but with success message
      return CreateReservationResponse(
        success: json["success"] ?? false,
        message: json["message"] ?? 'Reservation created but failed to parse details',
        data: null,
      );
    }
  }
}

// ==================== RESERVATION MODELS ====================

class Reservation {
  final String id;
  final String vehicleId;
  final String userId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final double totalAmount;
  final String? specialInstructions;
  final String? pickupLocation;
  final String? dropoffLocation;
  final String? promoCode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final VehicleInfo? vehicleDetails;

  Reservation({
    required this.id,
    required this.vehicleId,
    required this.userId,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.totalAmount,
    this.specialInstructions,
    this.pickupLocation,
    this.dropoffLocation,
    this.promoCode,
    required this.createdAt,
    required this.updatedAt,
    this.vehicleDetails,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    try {
      print('🔄 Parsing Reservation from JSON...');
      print('📋 JSON keys: ${json.keys}');
      
      // Helper function to extract ID from nested object
      String extractId(dynamic value) {
        if (value == null) return '';
        if (value is String) return value;
        if (value is Map<String, dynamic>) {
          return value['_id']?.toString() ?? 
                 value['id']?.toString() ?? 
                 '';
        }
        return value.toString();
      }

      // Helper function to extract double from MongoDB Decimal128 format
      double extractAmount(dynamic value) {
        if (value == null) return 0.0;
        if (value is num) return value.toDouble();
        if (value is Map<String, dynamic>) {
          if (value.containsKey('\$numberDecimal')) {
            return double.tryParse(value['\$numberDecimal'].toString()) ?? 0.0;
          }
          return (value['amount'] ?? value['total'] ?? 0).toDouble();
        }
        return double.tryParse(value.toString()) ?? 0.0;
      }

      // Extract dates from nested pickup/dropoff objects
      DateTime? startDate;
      DateTime? endDate;
      
      if (json['pickup'] is Map) {
        final pickup = json['pickup'] as Map<String, dynamic>;
        final at = pickup['at'];
        if (at != null) {
          try {
            startDate = DateTime.parse(at.toString());
          } catch (e) {
            print('⚠️ Error parsing start_date: $e');
          }
        }
      }
      
      if (json['dropoff'] is Map) {
        final dropoff = json['dropoff'] as Map<String, dynamic>;
        final at = dropoff['at'];
        if (at != null) {
          try {
            endDate = DateTime.parse(at.toString());
          } catch (e) {
            print('⚠️ Error parsing end_date: $e');
          }
        }
      }

      // Extract total amount from pricing
      double totalAmount = 0.0;
      if (json['pricing'] is Map) {
        final pricing = json['pricing'] as Map<String, dynamic>;
        totalAmount = extractAmount(pricing['grand_total']);
      }

      // Extract vehicle details if available
      VehicleInfo? vehicleDetails;
      if (json['vehicle_id'] is Map) {
        final vehicle = json['vehicle_id'] as Map<String, dynamic>;
        try {
          vehicleDetails = VehicleInfo.fromJson({
            '_id': vehicle['_id'] ?? '',
            'make': json['vehicle_model_id']?['make'] ?? '',
            'model': json['vehicle_model_id']?['model'] ?? '',
            'year': json['vehicle_model_id']?['year'] ?? 0,
            'license_plate': vehicle['plate_number'] ?? '',
            'color': vehicle['color'],
            'fuel_type': json['vehicle_model_id']?['fuel_type'],
            'seating_capacity': json['vehicle_model_id']?['seats'] ?? 5,
            'daily_rate': 0.0,
            'is_available': vehicle['availability_state'] == 'available',
          });
        } catch (e) {
          print('⚠️ Error parsing vehicle details: $e');
        }
      }

      final reservation = Reservation(
        id: json['_id'] ?? json['id'] ?? '',
        vehicleId: extractId(json['vehicle_id']),
        userId: extractId(json['user_id']),
        startDate: startDate ?? DateTime.now(),
        endDate: endDate ?? DateTime.now().add(const Duration(days: 1)),
        status: json['status'] ?? 'pending',
        totalAmount: totalAmount,
        specialInstructions: json['notes']?.toString(),
        pickupLocation: json['pickup']?['branch_id']?.toString(),
        dropoffLocation: json['dropoff']?['branch_id']?.toString(),
        promoCode: json['promo_code']?.toString(),
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
        updatedAt: json['updated_at'] != null 
            ? DateTime.parse(json['updated_at'].toString())
            : DateTime.now(),
        vehicleDetails: vehicleDetails,
      );

      print('✅ Successfully parsed reservation: ${reservation.id}');
      print('   Vehicle ID: ${reservation.vehicleId}');
      print('   User ID: ${reservation.userId}');
      print('   Dates: ${reservation.startDate} - ${reservation.endDate}');
      print('   Status: ${reservation.status}');
      print('   Amount: \$${reservation.totalAmount}');
      
      return reservation;
    } catch (e, stackTrace) {
      print('❌ Error parsing Reservation: $e');
      print('📋 Stack trace: $stackTrace');
      print('📋 Raw JSON: $json');
      
      // Return a minimal valid reservation object
      return Reservation(
        id: json['_id']?.toString() ?? 'error',
        vehicleId: 'unknown',
        userId: 'unknown',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 1)),
        status: 'error',
        totalAmount: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "vehicle_id": vehicleId,
        "user_id": userId,
        "start_date": startDate.toIso8601String(),
        "end_date": endDate.toIso8601String(),
        "status": status,
        "total_amount": totalAmount,
        if (specialInstructions != null)
          "special_instructions": specialInstructions,
        if (pickupLocation != null) "pickup_location": pickupLocation,
        if (dropoffLocation != null) "dropoff_location": dropoffLocation,
        if (promoCode != null) "promo_code": promoCode,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        if (vehicleDetails != null) "vehicle_details": vehicleDetails!.toJson(),
      };

  int get durationInDays => endDate.difference(startDate).inDays;

  String get formattedDates {
    final start = "${startDate.month}/${startDate.day}/${startDate.year}";
    final end = "${endDate.month}/${endDate.day}/${endDate.year}";
    return "$start - $end ($durationInDays days)";
  }

  String get formattedTotalAmount => "\$${totalAmount.toStringAsFixed(2)}";

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed ✓';
      case 'pending':
        return 'Pending...';
      case 'cancelled':
        return 'Cancelled ✗';
      case 'completed':
        return 'Completed ✓';
      default:
        return status;
    }
  }
}

// ==================== API RESPONSE MODELS ====================

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? code;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.code,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(Object?) fromJsonT) {
    return ApiResponse<T>(
      success: json["success"] ?? false,
      message: json["message"] ?? '',
      data: json["data"] != null ? fromJsonT(json["data"]) : null,
      code: json["code"],
    );
  }
}

// ==================== SIMPLIFIED MODELS FOR UI USE ====================

class SimpleReservationRequest {
  final String vehicleId;
  final DateTime startDate;
  final DateTime endDate;
  final String? specialInstructions;
  final String? pickupLocation;
  final String? dropoffLocation;
  final String? promoCode;

  SimpleReservationRequest({
    required this.vehicleId,
    required this.startDate,
    required this.endDate,
    this.specialInstructions,
    this.pickupLocation,
    this.dropoffLocation,
    this.promoCode,
  });

  Map<String, dynamic> toJson() => {
        "vehicle_id": vehicleId,
        "start_date": startDate.toIso8601String(),
        "end_date": endDate.toIso8601String(),
        if (specialInstructions != null && specialInstructions!.isNotEmpty)
          "special_instructions": specialInstructions,
        if (pickupLocation != null && pickupLocation!.isNotEmpty)
          "pickup_location": pickupLocation,
        if (dropoffLocation != null && dropoffLocation!.isNotEmpty)
          "dropoff_location": dropoffLocation,
        if (promoCode != null && promoCode!.isNotEmpty) "promo_code": promoCode,
      };

  CreateReservationRequest toFullRequest({
    required String createdChannel,
    required String vehicleModelId,
    required String branchId,
    required double dailyRate,
    required Map<String, dynamic> userData,
  }) {
    final durationDays = endDate.difference(startDate).inDays;
    final baseTotal = dailyRate * durationDays;
    final reservationCode = 'RES-${DateTime.now().millisecondsSinceEpoch}';

    return CreateReservationRequest(
      createdChannel: createdChannel,
      vehicleId: vehicleId,
      vehicleModelId: vehicleModelId,
      code: reservationCode, // REQUIRED FIELD
      pickup: BranchTime(branchId: branchId, at: startDate),
      dropoff: BranchTime(branchId: branchId, at: endDate),
      pricing: ReservationPricing(
        currency: 'USD',
        breakdown: [
          PriceBreakdownItem(
            label: 'Base daily rate',
            quantity: durationDays,
            unitAmount: dailyRate,
            total: baseTotal,
          ),
        ],
        fees: [
          ReservationFee(
            code: 'SERVICE_FEE',
            amount: 10.00,
          ),
        ],
        taxes: [
          ReservationTax(
            code: 'VAT',
            rate: 0.15,
            amount: baseTotal * 0.15,
          ),
        ],
        discounts: promoCode != null
            ? [
                ReservationDiscount(
                  promoCodeId: promoCode,
                  amount: 5.00,
                ),
              ]
            : [],
        grandTotal: baseTotal + 10.00 + (baseTotal * 0.15) -
            (promoCode != null ? 5.00 : 0.00),
        computedAt: DateTime.now(),
      ),
      paymentSummary: ReservationPaymentSummary(
        status: 'unpaid',
        paidTotal: 0.00,
        outstanding: baseTotal + 10.00 + (baseTotal * 0.15) -
            (promoCode != null ? 5.00 : 0.00),
      ),
      driverSnapshot: ReservationDriverSnapshot(
        fullName: userData['full_name'] ?? 'Unknown',
        phone: userData['phone'] ?? '',
        email: userData['email'] ?? '',
        driverLicense: ReservationDriverLicense(
          number: userData['driver_license']?['number'] ?? 'NOT_PROVIDED',
          country: userData['driver_license']?['country'] ?? 'ZW',
          licenseClass: userData['driver_license']?['class'] ?? 'Class 4',
          expiresAt: DateTime.now().add(const Duration(days: 365 * 5)),
          verified: false,
        ),
      ),
      notes: specialInstructions,
      userId: userData['id']?.toString(),
    );
  }
}