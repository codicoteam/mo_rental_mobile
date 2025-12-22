// payment_models.dart

// ==================== PAYMENT MODELS ====================

class PaymentInitiateRequest {
  final String reservationId;
  final String? driverBookingId;
  final double amount;
  final String currency;
  final String? promoCode;
  final String? reference;
  final String email;
  final String? lineItem;

  PaymentInitiateRequest({
    required this.reservationId,
    this.driverBookingId,
    required this.amount,
    this.currency = 'USD',
    this.promoCode,
    this.reference,
    required this.email,
    this.lineItem,
  });

  Map<String, dynamic> toJson() => {
    "reservation_id": reservationId,
    if (driverBookingId != null && driverBookingId!.isNotEmpty) 
      "driver_booking_id": driverBookingId,
    "amount": amount,
    "currency": currency,
    if (promoCode != null && promoCode!.isNotEmpty) "promo_code": promoCode,
    if (reference != null && reference!.isNotEmpty) "reference": reference,
    "email": email,
    if (lineItem != null && lineItem!.isNotEmpty) "lineItem": lineItem,
  };
}

class PaymentMobileRequest {
  final String reservationId;
  final String? driverBookingId;
  final double amount;
  final String currency;
  final String? promoCode;
  final String? reference;
  final String phone;
  final String mobileMethod;
  final String? lineItem;

  PaymentMobileRequest({
    required this.reservationId,
    this.driverBookingId,
    required this.amount,
    this.currency = 'USD',
    this.promoCode,
    this.reference,
    required this.phone,
    this.mobileMethod = 'ecocash',
    this.lineItem,
  });

  Map<String, dynamic> toJson() => {
    "reservation_id": reservationId,
    if (driverBookingId != null && driverBookingId!.isNotEmpty) 
      "driver_booking_id": driverBookingId,
    "amount": amount,
    "currency": currency,
    if (promoCode != null && promoCode!.isNotEmpty) "promo_code": promoCode,
    if (reference != null && reference!.isNotEmpty) "reference": reference,
    "phone": phone,
    "mobileMethod": mobileMethod,
    if (lineItem != null && lineItem!.isNotEmpty) "lineItem": lineItem,
  };
}

class PaymentInitiateResponse {
  final bool success;
  final String? redirectUrl;
  final String? pollUrl;
  final String? promoWarning;
  final Payment? payment;

  PaymentInitiateResponse({
    required this.success,
    this.redirectUrl,
    this.pollUrl,
    this.promoWarning,
    this.payment,
  });

  factory PaymentInitiateResponse.fromJson(Map<String, dynamic> json) {
    return PaymentInitiateResponse(
      success: json["success"] ?? false,
      redirectUrl: json["redirectUrl"],
      pollUrl: json["pollUrl"],
      promoWarning: json["promo_warning"],
      payment: json["payment"] != null 
          ? Payment.fromJson(json["payment"])
          : null,
    );
  }
}

class PaymentStatusResponse {
  final bool success;
  final Payment? payment;
  final String? status;
  final String? message;

  PaymentStatusResponse({
    required this.success,
    this.payment,
    this.status,
    this.message,
  });

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    return PaymentStatusResponse(
      success: json["success"] ?? false,
      payment: json["payment"] != null 
          ? Payment.fromJson(json["payment"])
          : null,
      status: json["status"] ?? json["payment"]?["paymentStatus"],
      message: json["message"],
    );
  }
}

class Payment {
  final String id;
  final String reservationId;
  final String? driverBookingId;
  final String userId;
  final String provider;
  final String method;
  final double amount;
  final String currency;
  final String paymentStatus;
  final String? pollUrl;
  final double pricePaid;
  final bool promotionApplied;
  final double promotionDiscount;
  final DateTime? boughtAt;
  final String? providerRef;
  final DateTime? capturedAt;
  final String? paynowInvoiceId;
  final List<Refund> refunds;
  final String? promoCodeId;
  final String? promoCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  Payment({
    required this.id,
    required this.reservationId,
    this.driverBookingId,
    required this.userId,
    required this.provider,
    required this.method,
    required this.amount,
    required this.currency,
    required this.paymentStatus,
    this.pollUrl,
    required this.pricePaid,
    required this.promotionApplied,
    required this.promotionDiscount,
    this.boughtAt,
    this.providerRef,
    this.capturedAt,
    this.paynowInvoiceId,
    this.refunds = const [],
    this.promoCodeId,
    this.promoCode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    // Helper function to parse amounts
    double parseAmount(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      if (value is Map && value.containsKey('\$numberDecimal')) {
        return double.tryParse(value['\$numberDecimal'].toString()) ?? 0.0;
      }
      return 0.0;
    }

    return Payment(
      id: json["_id"] ?? json["id"] ?? '',
      reservationId: json["reservation_id"] ?? '',
      driverBookingId: json["driver_booking_id"],
      userId: json["user_id"] ?? '',
      provider: json["provider"] ?? 'paynow',
      method: json["method"] ?? '',
      amount: parseAmount(json["amount"]),
      currency: json["currency"] ?? 'USD',
      paymentStatus: json["paymentStatus"] ?? json["status"] ?? 'pending',
      pollUrl: json["pollUrl"],
      pricePaid: parseAmount(json["pricePaid"]),
      promotionApplied: json["promotionApplied"] ?? false,
      promotionDiscount: parseAmount(json["promotionDiscount"]),
      boughtAt: json["boughtAt"] != null 
          ? DateTime.parse(json["boughtAt"].toString())
          : null,
      providerRef: json["provider_ref"],
      capturedAt: json["captured_at"] != null 
          ? DateTime.parse(json["captured_at"].toString())
          : null,
      paynowInvoiceId: json["paynow_invoice_id"],
      refunds: json["refunds"] != null 
          ? List<Refund>.from(json["refunds"].map((x) => Refund.fromJson(x)))
          : [],
      promoCodeId: json["promo_code_id"],
      promoCode: json["promo_code"],
      createdAt: json["created_at"] != null 
          ? DateTime.parse(json["created_at"].toString())
          : DateTime.now(),
      updatedAt: json["updated_at"] != null 
          ? DateTime.parse(json["updated_at"].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "reservation_id": reservationId,
    if (driverBookingId != null) "driver_booking_id": driverBookingId,
    "user_id": userId,
    "provider": provider,
    "method": method,
    "amount": amount,
    "currency": currency,
    "payment_status": paymentStatus,
    if (pollUrl != null) "pollUrl": pollUrl,
    "price_paid": pricePaid,
    "promotion_applied": promotionApplied,
    "promotion_discount": promotionDiscount,
    if (boughtAt != null) "bought_at": boughtAt!.toIso8601String(),
    if (providerRef != null) "provider_ref": providerRef,
    if (capturedAt != null) "captured_at": capturedAt!.toIso8601String(),
    if (paynowInvoiceId != null) "paynow_invoice_id": paynowInvoiceId,
    "refunds": List<dynamic>.from(refunds.map((x) => x.toJson())),
    if (promoCodeId != null) "promo_code_id": promoCodeId,
    if (promoCode != null) "promo_code": promoCode,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';
  bool get isPending => paymentStatus.toLowerCase() == 'pending';
  bool get isFailed => paymentStatus.toLowerCase() == 'failed';
  bool get isCancelled => paymentStatus.toLowerCase() == 'cancelled';

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';
  String get statusText => paymentStatus.toUpperCase();
}

class Refund {
  final double amount;
  final String? providerRef;
  final DateTime at;

  Refund({
    required this.amount,
    this.providerRef,
    required this.at,
  });

  factory Refund.fromJson(Map<String, dynamic> json) {
    return Refund(
      amount: (json["amount"] ?? 0).toDouble(),
      providerRef: json["provider_ref"],
      at: json["at"] != null 
          ? DateTime.parse(json["at"].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    "amount": amount,
    if (providerRef != null) "provider_ref": providerRef,
    "at": at.toIso8601String(),
  };
}