class UpdateProfileRequest {
  final String? fullName;
  final String? phone;

  UpdateProfileRequest({
    this.fullName,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (fullName != null && fullName!.isNotEmpty) {
      data['full_name'] = fullName;
    }
    
    if (phone != null && phone!.isNotEmpty) {
      data['phone'] = phone;
    }
    
    return data;
  }

  bool get isEmpty => (fullName == null || fullName!.isEmpty) && 
                      (phone == null || phone!.isEmpty);

  @override
  String toString() => 'UpdateProfileRequest(fullName: $fullName, phone: $phone)';
}