// rate_plan_response.dart - UPDATED VERSION


import 'rate_plan_model.dart';

class RatePlanResponse {
  final List<RatePlan> plans;
  final PaginationInfo pagination;

  RatePlanResponse({
    required this.plans,
    required this.pagination,
  });

  factory RatePlanResponse.fromJson(Map<String, dynamic> json) {
    // The API returns data in a nested structure
    final data = json['data'] ?? json;
    final items = data['items'] ?? data['plans'] ?? [];
    
    print('📊 Parsing ${items.length} rate plans from API response');
    
    return RatePlanResponse(
      plans: List<RatePlan>.from(
        items.map((x) => RatePlan.fromJson(x)),
      ),
      pagination: PaginationInfo.fromJson(data),
    );
  }

  Map<String, dynamic> toJson() => {
        'plans': plans.map((x) => x.toJson()).toList(),
        'pagination': pagination.toJson(),
      };
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
      totalPages: json['totalPages'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'limit': limit,
        'total': total,
        'totalPages': totalPages,
      };

  bool get hasNextPage => page < totalPages;
  bool get hasPrevPage => page > 1;
}