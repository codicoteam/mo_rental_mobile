class RatePlanResponse {
  final List<RatePlan> plans;
  final PaginationInfo pagination;

  RatePlanResponse({
    required this.plans,
    required this.pagination,
  });

  factory RatePlanResponse.fromJson(Map<String, dynamic> json) {
    return RatePlanResponse(
      plans: List<RatePlan>.from(
        (json['plans'] ?? []).map((x) => RatePlan.fromJson(x)),
      ),
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class RatePlan {
  final String id;
  final String name;
  final String description;
  final String branchId;
  final String vehicleClass;
  final String? vehicleModelId;
  final String? vehicleId;
  final double dailyRate;
  final double weeklyRate;
  final double monthlyRate;
  final String currency;
  final int minRentalDays;
  final int maxRentalDays;
  final bool isActive;
  final DateTime validFrom;
  final DateTime validTo;
  final DateTime createdAt;
  final DateTime updatedAt;

  RatePlan({
    required this.id,
    required this.name,
    required this.description,
    required this.branchId,
    required this.vehicleClass,
    this.vehicleModelId,
    this.vehicleId,
    required this.dailyRate,
    required this.weeklyRate,
    required this.monthlyRate,
    required this.currency,
    required this.minRentalDays,
    required this.maxRentalDays,
    required this.isActive,
    required this.validFrom,
    required this.validTo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RatePlan.fromJson(Map<String, dynamic> json) {
    return RatePlan(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      branchId: json['branch_id'] ?? '',
      vehicleClass: json['vehicle_class'] ?? '',
      vehicleModelId: json['vehicle_model_id'],
      vehicleId: json['vehicle_id'],
      dailyRate: (json['daily_rate'] ?? 0.0).toDouble(),
      weeklyRate: (json['weekly_rate'] ?? 0.0).toDouble(),
      monthlyRate: (json['monthly_rate'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      minRentalDays: json['min_rental_days'] ?? 1,
      maxRentalDays: json['max_rental_days'] ?? 30,
      isActive: json['is_active'] ?? false,
      validFrom: DateTime.parse(json['valid_from'] ?? DateTime.now().toIso8601String()),
      validTo: DateTime.parse(json['valid_to'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'description': description,
    'branch_id': branchId,
    'vehicle_class': vehicleClass,
    'vehicle_model_id': vehicleModelId,
    'vehicle_id': vehicleId,
    'daily_rate': dailyRate,
    'weekly_rate': weeklyRate,
    'monthly_rate': monthlyRate,
    'currency': currency,
    'min_rental_days': minRentalDays,
    'max_rental_days': maxRentalDays,
    'is_active': isActive,
    'valid_from': validFrom.toIso8601String(),
    'valid_to': validTo.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  // Helper methods
  String get formattedDailyRate => '$currency $dailyRate/day';
  String get formattedWeeklyRate => '$currency $weeklyRate/week';
  String get formattedMonthlyRate => '$currency $monthlyRate/month';
  
  String get validityPeriod => 
      '${validFrom.day}/${validFrom.month}/${validFrom.year} - ${validTo.day}/${validTo.month}/${validTo.year}';
}

class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 1,
    );
  }

  bool get hasNextPage => page < totalPages;
  bool get hasPrevPage => page > 1;
}