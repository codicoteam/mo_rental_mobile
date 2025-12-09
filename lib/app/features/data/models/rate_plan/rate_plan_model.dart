// rate_plan.dart

class RatePlan {
  final String id;
  final String name;
  final String? notes;  
  final Branch? branch;
  final Vehicle? vehicle;
  final String vehicleClass;
  final String? vehicleModelId;
  final String? vehicleId;
  final double dailyRate;
  final double weeklyRate;
  final double monthlyRate;
  final double weekendRate;  
  final String currency;
  final bool isActive;
  final DateTime validFrom;  
  final DateTime validTo;    
  final List<SeasonalOverride> seasonalOverrides;
  final List<Tax> taxes;
  final List<Fee> fees;
  final DateTime createdAt;
  final DateTime updatedAt;

  RatePlan({
    required this.id,
    required this.name,
    this.notes,
    this.branch,
    this.vehicle,
    required this.vehicleClass,
    this.vehicleModelId,
    this.vehicleId,
    required this.dailyRate,
    required this.weeklyRate,
    required this.monthlyRate,
    required this.weekendRate,
    required this.currency,
    required this.isActive,
    required this.validFrom,
    required this.validTo,
    this.seasonalOverrides = const [],
    this.taxes = const [],
    this.fees = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper method to parse decimal numbers from MongoDB format
  static double _parseDecimal(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is Map && value.containsKey(r'$numberDecimal')) {
      return double.tryParse(value[r'$numberDecimal'].toString()) ?? 0.0;
    }
    return double.tryParse(value.toString()) ?? 0.0;
  }

  factory RatePlan.fromJson(Map<String, dynamic> json) {
    // Parse branch
    Branch? branch;
    if (json['branch_id'] != null && json['branch_id'] is Map) {
      branch = Branch.fromJson(json['branch_id']);
    }

    // Parse vehicle
    Vehicle? vehicle;
    if (json['vehicle_id'] != null && json['vehicle_id'] is Map) {
      vehicle = Vehicle.fromJson(json['vehicle_id']);
    }

    return RatePlan(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      notes: json['notes'],
      branch: branch,
      vehicle: vehicle,
      vehicleClass: json['vehicle_class'] ?? '',
      vehicleModelId: json['vehicle_model_id'],
      vehicleId: json['vehicle_id'] is String ? json['vehicle_id'] : null,
      dailyRate: _parseDecimal(json['daily_rate']),
      weeklyRate: _parseDecimal(json['weekly_rate']),
      monthlyRate: _parseDecimal(json['monthly_rate']),
      weekendRate: _parseDecimal(json['weekend_rate'] ?? 0),
      currency: json['currency'] ?? 'USD',
      isActive: json['active'] ?? false,
      validFrom: json['valid_from'] != null
          ? DateTime.parse(json['valid_from'])
          : DateTime.now(),
      validTo: json['valid_to'] != null
          ? DateTime.parse(json['valid_to'])
          : DateTime.now(),
      seasonalOverrides: (json['seasonal_overrides'] as List?)?.map((x) {
            return SeasonalOverride.fromJson(x);
          }).toList() ??
          [],
      taxes: (json['taxes'] as List?)?.map((x) {
            return Tax.fromJson(x);
          }).toList() ??
          [],
      fees: (json['fees'] as List?)?.map((x) {
            return Fee.fromJson(x);
          }).toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'notes': notes,
        'branch_id': branch?.toJson(),
        'vehicle_id': vehicle?.toJson(),
        'vehicle_class': vehicleClass,
        'vehicle_model_id': vehicleModelId,
        'daily_rate': dailyRate,
        'weekly_rate': weeklyRate,
        'monthly_rate': monthlyRate,
        'weekend_rate': weekendRate,
        'currency': currency,
        'active': isActive,
        'valid_from': validFrom.toIso8601String(),
        'valid_to': validTo.toIso8601String(),
        'seasonal_overrides':
            seasonalOverrides.map((x) => x.toJson()).toList(),
        'taxes': taxes.map((x) => x.toJson()).toList(),
        'fees': fees.map((x) => x.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  // Helper methods
  String get formattedDailyRate => '$currency $dailyRate/day';
  String get formattedWeeklyRate => '$currency $weeklyRate/week';
  String get formattedMonthlyRate => '$currency $monthlyRate/month';
  String get formattedWeekendRate => '$currency $weekendRate/weekend';

  String get validityPeriod =>
      '${validFrom.day}/${validFrom.month}/${validFrom.year} - ${validTo.day}/${validTo.month}/${validTo.year}';

  double get totalTaxRate {
    return taxes.fold(0.0, (sum, tax) => sum + tax.rate);
  }

  double calculateTotal(double basePrice) {
    double total = basePrice;

    // Add taxes
    total += basePrice * totalTaxRate;

    // Add fees
    for (var fee in fees) {
      total += fee.amount;
    }

    return total;
  }
}

class Branch {
  final String id;
  final String name;

  Branch({
    required this.id,
    required this.name,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
      };
}

class Vehicle {
  final String id;
  final String vin;
  final String plateNumber;
  final String color;
  final String status;
  final String availabilityState;
  final int odometerKm;
  final List<String> photos;
  final Map<String, dynamic> metadata;

  Vehicle({
    required this.id,
    required this.vin,
    required this.plateNumber,
    required this.color,
    required this.status,
    required this.availabilityState,
    required this.odometerKm,
    required this.photos,
    required this.metadata,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'] ?? '',
      vin: json['vin'] ?? '',
      plateNumber: json['plate_number'] ?? '',
      color: json['color'] ?? '',
      status: json['status'] ?? '',
      availabilityState: json['availability_state'] ?? '',
      odometerKm: json['odometer_km'] ?? 0,
      photos: List<String>.from(json['photos'] ?? []),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'vin': vin,
        'plate_number': plateNumber,
        'color': color,
        'status': status,
        'availability_state': availabilityState,
        'odometer_km': odometerKm,
        'photos': photos,
        'metadata': metadata,
      };
}

class SeasonalOverride {
  final String id;
  final Season season;
  final double dailyRate;
  final double weeklyRate;
  final double monthlyRate;
  final double weekendRate;

  SeasonalOverride({
    required this.id,
    required this.season,
    required this.dailyRate,
    required this.weeklyRate,
    required this.monthlyRate,
    required this.weekendRate,
  });

  factory SeasonalOverride.fromJson(Map<String, dynamic> json) {
    return SeasonalOverride(
      id: json['_id'] ?? '',
      season: Season.fromJson(json['season'] ?? {}),
      dailyRate: RatePlan._parseDecimal(json['daily_rate']),
      weeklyRate: RatePlan._parseDecimal(json['weekly_rate']),
      monthlyRate: RatePlan._parseDecimal(json['monthly_rate']),
      weekendRate: RatePlan._parseDecimal(json['weekend_rate']),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'season': season.toJson(),
        'daily_rate': dailyRate,
        'weekly_rate': weeklyRate,
        'monthly_rate': monthlyRate,
        'weekend_rate': weekendRate,
      };
}

class Season {
  final String name;
  final DateTime start;
  final DateTime end;

  Season({
    required this.name,
    required this.start,
    required this.end,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      name: json['name'] ?? '',
      start: json['start'] != null ? DateTime.parse(json['start']) : DateTime.now(),
      end: json['end'] != null ? DateTime.parse(json['end']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
      };
}

class Tax {
  final String id;
  final String code;
  final double rate;

  Tax({
    required this.id,
    required this.code,
    required this.rate,
  });

  factory Tax.fromJson(Map<String, dynamic> json) {
    return Tax(
      id: json['_id'] ?? '',
      code: json['code'] ?? '',
      rate: (json['rate'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'code': code,
        'rate': rate,
      };
}

class Fee {
  final String id;
  final String code;
  final double amount;

  Fee({
    required this.id,
    required this.code,
    required this.amount,
  });

  factory Fee.fromJson(Map<String, dynamic> json) {
    return Fee(
      id: json['_id'] ?? '',
      code: json['code'] ?? '',
      amount: RatePlan._parseDecimal(json['amount']),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'code': code,
        'amount': amount,
      };
}