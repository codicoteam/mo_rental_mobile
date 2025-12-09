// lib/features/modules/vehicles/models/vehicle.dart


import '../branch_models/branch_models.dart';
import 'vehicle_model.dart';

class Vehicle {
  final String id;
  final String vin;
  final String plateNumber;
  final VehicleModel vehicleModel;
  final Branch branch;
  final int odometerKm;
  final String color;
  final String status;
  final String availabilityState;
  final List<String> photos;
  final DateTime? lastServiceAt;
  final int? lastServiceOdometerKm;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.vin,
    required this.plateNumber,
    required this.vehicleModel,
    required this.branch,
    required this.odometerKm,
    required this.color,
    required this.status,
    required this.availabilityState,
    required this.photos,
    this.lastServiceAt,
    this.lastServiceOdometerKm,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    try {
      print('🚙 Parsing Vehicle JSON: keys=${json.keys}');
      
      // Parse vehicle model
      final vehicleModelJson = json['vehicle_model_id'];
      if (vehicleModelJson == null) {
        print('⚠️ Vehicle model is null in JSON');
      }
      final vehicleModel = VehicleModel.fromJson(vehicleModelJson);
      
      // Parse branch
      final branchJson = json['branch_id'];
      if (branchJson == null) {
        print('⚠️ Branch is null in JSON');
      }
      final branch = Branch.fromJson(branchJson);
      
      return Vehicle(
        id: json['_id']?.toString() ?? '',
        vin: json['vin']?.toString() ?? '',
        plateNumber: json['plate_number']?.toString() ?? '',
        vehicleModel: vehicleModel,
        branch: branch,
        odometerKm: json['odometer_km'] is int 
            ? json['odometer_km'] 
            : int.tryParse(json['odometer_km']?.toString() ?? '0') ?? 0,
        color: json['color']?.toString() ?? 'Unknown',
        status: json['status']?.toString() ?? 'unknown',
        availabilityState: json['availability_state']?.toString() ?? 'unknown',
        photos: (json['photos'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        lastServiceAt: json['last_service_at'] != null 
            ? DateTime.parse(json['last_service_at'].toString()).toLocal()
            : null,
        lastServiceOdometerKm: json['last_service_odometer_km'] is int 
            ? json['last_service_odometer_km'] 
            : json['last_service_odometer_km'] != null 
                ? int.tryParse(json['last_service_odometer_km'].toString())
                : null,
        metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'].toString()).toLocal()
            : DateTime.now(),
        updatedAt: json['updated_at'] != null 
            ? DateTime.parse(json['updated_at'].toString()).toLocal()
            : DateTime.now(),
      );
    } catch (e) {
      print('❌ Error parsing Vehicle: $e');
      print('❌ JSON causing error: $json');
      rethrow;
    }
  }

  String get displayName => '$plateNumber - ${vehicleModel.fullName}';
  
  String get locationInfo => '${branch.name} (${branch.code})';
  
  bool get isAvailable => availabilityState.toLowerCase() == 'available';
  
  bool get isActive => status.toLowerCase() == 'active';
  
  bool get needsService {
    if (lastServiceOdometerKm == null) return true;
    const serviceIntervalKm = 10000;
    return odometerKm - lastServiceOdometerKm! > serviceIntervalKm;
  }
}