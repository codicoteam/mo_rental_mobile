class RatePlanRequest {
  final String? branchId;
  final String? vehicleClass;
  final String? vehicleModelId;
  final String? vehicleId;
  final String? currency;
  final bool? active;
  final String? validOn;
  final int? page;
  final int? limit;

  RatePlanRequest({
    this.branchId,
    this.vehicleClass,
    this.vehicleModelId,
    this.vehicleId,
    this.currency,
    this.active,
    this.validOn,
    this.page,
    this.limit,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    
    if (branchId != null) params['branch_id'] = branchId;
    if (vehicleClass != null) params['vehicle_class'] = vehicleClass;
    if (vehicleModelId != null) params['vehicle_model_id'] = vehicleModelId;
    if (vehicleId != null) params['vehicle_id'] = vehicleId;
    if (currency != null) params['currency'] = currency;
    if (active != null) params['active'] = active.toString();
    if (validOn != null) params['valid_on'] = validOn;
    if (page != null) params['page'] = page.toString();
    if (limit != null) params['limit'] = limit.toString();
    
    return params;
  }
}