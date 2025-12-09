// lib/features/modules/vehicles/models/vehicle_model.dart
class VehicleModel {
  final String id;
  final String make;
  final String model;
  final int year;
  final String vehicleClass;
  final String transmission;
  final String fuelType;
  final int seats;
  final int doors;
  final List<String> features;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  VehicleModel({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.vehicleClass,
    required this.transmission,
    required this.fuelType,
    required this.seats,
    required this.doors,
    required this.features,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🚗 Parsing VehicleModel JSON: $json');
      
      return VehicleModel(
        id: json['_id']?.toString() ?? '',
        make: json['make']?.toString() ?? 'Unknown',
        model: json['model']?.toString() ?? 'Unknown',
        year: json['year'] is int ? json['year'] : int.tryParse(json['year']?.toString() ?? '0') ?? 0,
        vehicleClass: json['class']?.toString() ?? 'standard',
        transmission: json['transmission']?.toString() ?? 'manual',
        fuelType: json['fuel_type']?.toString() ?? 'petrol',
        seats: json['seats'] is int ? json['seats'] : int.tryParse(json['seats']?.toString() ?? '5') ?? 5,
        doors: json['doors'] is int ? json['doors'] : int.tryParse(json['doors']?.toString() ?? '4') ?? 4,
        features: (json['features'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        images: (json['images'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        createdAt: json['createdAt'] != null 
            ? DateTime.parse(json['createdAt'].toString()).toLocal()
            : DateTime.now(),
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt'].toString()).toLocal()
            : DateTime.now(),
      );
    } catch (e) {
      print('❌ Error parsing VehicleModel: $e');
      print('❌ JSON causing error: $json');
      rethrow;
    }
  }

  String get fullName => '$make $model ($year)';
  
  String get displayInfo => '$vehicleClass • $transmission • $fuelType • $seats seats';
  
  bool hasFeature(String feature) => features.contains(feature.toLowerCase());
}