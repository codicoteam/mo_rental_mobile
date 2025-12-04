class PromoCode {
  final String id;
  final String code;
  final String type;
  final double value;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final int? usageLimit;
  final int? timesUsed;
  final bool isActive;
  final String? description;

  PromoCode({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    this.validFrom,
    this.validUntil,
    this.usageLimit,
    this.timesUsed,
    required this.isActive,
    this.description,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['_id'] ?? json['id'] ?? '',
      code: json['code'] ?? '',
      type: json['type'] ?? '',
      value: (json['value'] ?? 0).toDouble(),
      validFrom: json['validFrom'] != null 
          ? DateTime.parse(json['validFrom']) 
          : null,
      validUntil: json['validUntil'] != null 
          ? DateTime.parse(json['validUntil']) 
          : null,
      usageLimit: json['usageLimit'],
      timesUsed: json['timesUsed'],
      isActive: json['isActive'] ?? false,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'type': type,
      'value': value,
      'validFrom': validFrom?.toIso8601String(),
      'validUntil': validUntil?.toIso8601String(),
      'usageLimit': usageLimit,
      'timesUsed': timesUsed,
      'isActive': isActive,
      'description': description,
    };
  }

  bool get isValid {
    final now = DateTime.now();
    final isNotExpired = validUntil == null || now.isBefore(validUntil!);
    final hasStarted = validFrom == null || now.isAfter(validFrom!);
    final hasUsesLeft = usageLimit == null || timesUsed == null || timesUsed! < usageLimit!;
    
    return isActive && isNotExpired && hasStarted && hasUsesLeft;
  }

  double calculateDiscount(double originalPrice) {
    if (type == 'percentage') {
      return originalPrice * (value / 100);
    } else if (type == 'fixed') {
      return value;
    }
    return 0;
  }

  @override
  String toString() {
    return '''
Promo Code: $code
Type: $type
Value: ${type == 'percentage' ? '$value%' : '\$$value'}
Valid Until: ${validUntil?.toLocal().toString() ?? 'No expiry'}
Uses: ${timesUsed ?? 0}/${usageLimit ?? 'Unlimited'}
Active: $isActive
Valid: $isValid
Description: ${description ?? 'No description'}
---''';
  }
}