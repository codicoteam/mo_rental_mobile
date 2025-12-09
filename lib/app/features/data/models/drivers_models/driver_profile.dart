// lib/features/modules/drivers/models/driver_profile.dart
class DriverProfile {
  final String id;
  final User user;
  final String displayName;
  final String baseCity;
  final String baseRegion;
  final String baseCountry;
  final double hourlyRate;
  final String bio;
  final int yearsExperience;
  final List<String> languages;
  final IdentityDocument identityDocument;
  final DriverLicense driverLicense;
  final String status;
  final DateTime? approvedAt;
  final bool isAvailable;
  final double ratingAverage;
  final int ratingCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  DriverProfile({
    required this.id,
    required this.user,
    required this.displayName,
    required this.baseCity,
    required this.baseRegion,
    required this.baseCountry,
    required this.hourlyRate,
    required this.bio,
    required this.yearsExperience,
    required this.languages,
    required this.identityDocument,
    required this.driverLicense,
    required this.status,
    this.approvedAt,
    required this.isAvailable,
    required this.ratingAverage,
    required this.ratingCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DriverProfile.fromJson(Map<String, dynamic> json) {
    try {
      print('🚕 Parsing DriverProfile JSON: keys=${json.keys}');

      return DriverProfile(
        id: json['_id']?.toString() ?? '',
        user: User.fromJson(json['user_id'] ?? {}),
        displayName: json['display_name']?.toString() ?? '',
        baseCity: json['base_city']?.toString() ?? '',
        baseRegion: json['base_region']?.toString() ?? '',
        baseCountry: json['base_country']?.toString() ?? '',
        hourlyRate: json['hourly_rate'] is double
            ? json['hourly_rate']
            : (json['hourly_rate'] is int
                ? json['hourly_rate'].toDouble()
                : double.tryParse(json['hourly_rate']?.toString() ?? '0') ??
                    0.0),
        bio: json['bio']?.toString() ?? '',
        yearsExperience: json['years_experience'] is int
            ? json['years_experience']
            : int.tryParse(json['years_experience']?.toString() ?? '0') ?? 0,
        languages: (json['languages'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        identityDocument:
            IdentityDocument.fromJson(json['identity_document'] ?? {}),
        driverLicense: DriverLicense.fromJson(json['driver_license'] ?? {}),
        status: json['status']?.toString() ?? 'pending',
        approvedAt: json['approved_at'] != null
            ? DateTime.parse(json['approved_at'].toString()).toLocal()
            : null,
        isAvailable: json['is_available'] == true,
        ratingAverage: json['rating_average'] is double
            ? json['rating_average']
            : (json['rating_average'] is int
                ? json['rating_average'].toDouble()
                : double.tryParse(json['rating_average']?.toString() ?? '0') ??
                    0.0),
        ratingCount: json['rating_count'] is int
            ? json['rating_count']
            : int.tryParse(json['rating_count']?.toString() ?? '0') ?? 0,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString()).toLocal()
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'].toString()).toLocal()
            : DateTime.now(),
      );
    } catch (e) {
      print('❌ Error parsing DriverProfile: $e');
      print('❌ JSON causing error: $json');
      rethrow;
    }
  }

  String get hourlyRateFormatted => '\$${hourlyRate.toStringAsFixed(2)}/hour';

  String get experienceText =>
      '$yearsExperience year${yearsExperience != 1 ? 's' : ''} experience';

  String get languagesText => languages.join(', ');

  bool get isApproved => status.toLowerCase() == 'approved';

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'green';
      case 'pending':
        return 'orange';
      case 'rejected':
        return 'red';
      case 'suspended':
        return 'red';
      default:
        return 'grey';
    }
  }

  String get availabilityStatus =>
      isAvailable ? 'Available Now' : 'Not Available';
}

class User {
  final String id;
  final String fullName;

  User({
    required this.id,
    required this.fullName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? 'Unknown',
    );
  }
}

class IdentityDocument {
  final String type;
  final String imageUrl;

  IdentityDocument({
    required this.type,
    required this.imageUrl,
  });

  factory IdentityDocument.fromJson(Map<String, dynamic> json) {
    return IdentityDocument(
      type: json['type']?.toString() ?? 'national_id',
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'imageUrl': imageUrl,
    };
  }
}

class DriverLicense {
  final String number;
  final String imageUrl;
  final String country;
  final String licenseClass;
  final DateTime expiresAt;
  final bool verified;

  DriverLicense({
    required this.number,
    required this.imageUrl,
    required this.country,
    required this.licenseClass,
    required this.expiresAt,
    required this.verified,
  });

  factory DriverLicense.fromJson(Map<String, dynamic> json) {
    return DriverLicense(
      number: json['number']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
      licenseClass: json['class']?.toString() ?? '',
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'].toString()).toLocal()
          : DateTime.now().add(const Duration(days: 365)),
      verified: json['verified'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'imageUrl': imageUrl,
      'country': country,
      'class': licenseClass,
      'expires_at': expiresAt.toUtc().toIso8601String(),
      'verified': verified,
    };
  }
  
  bool get isExpired => expiresAt.isBefore(DateTime.now());
  
  String get expiresIn {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).toStringAsFixed(1)} years';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).toStringAsFixed(1)} months';
    } else {
      return '${difference.inDays} days';
    }
  }
}

// Request models for creating/updating driver profiles
class CreateDriverProfileRequest {
  final String displayName;
  final String baseCity;
  final String baseRegion;
  final String baseCountry;
  final double hourlyRate;
  final String bio;
  final int yearsExperience;
  final List<String> languages;
  final IdentityDocument identityDocument;
  final DriverLicense driverLicense;

  CreateDriverProfileRequest({
    required this.displayName,
    required this.baseCity,
    required this.baseRegion,
    required this.baseCountry,
    required this.hourlyRate,
    required this.bio,
    required this.yearsExperience,
    required this.languages,
    required this.identityDocument,
    required this.driverLicense,
  });

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'base_city': baseCity,
      'base_region': baseRegion,
      'base_country': baseCountry,
      'hourly_rate': hourlyRate,
      'bio': bio,
      'years_experience': yearsExperience,
      'languages': languages,
      'identity_document': identityDocument.toJson(),
      'driver_license': driverLicense.toJson(),
    };
  }
}

class UpdateDriverProfileRequest {
  final String? displayName;
  final String? baseCity;
  final String? baseRegion;
  final String? baseCountry;
  final double? hourlyRate;
  final String? bio;
  final int? yearsExperience;
  final List<String>? languages;
  final IdentityDocument? identityDocument;
  final DriverLicense? driverLicense;
  final bool? isAvailable;

  UpdateDriverProfileRequest({
    this.displayName,
    this.baseCity,
    this.baseRegion,
    this.baseCountry,
    this.hourlyRate,
    this.bio,
    this.yearsExperience,
    this.languages,
    this.identityDocument,
    this.driverLicense,
    this.isAvailable,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (displayName != null) data['display_name'] = displayName;
    if (baseCity != null) data['base_city'] = baseCity;
    if (baseRegion != null) data['base_region'] = baseRegion;
    if (baseCountry != null) data['base_country'] = baseCountry;
    if (hourlyRate != null) data['hourly_rate'] = hourlyRate;
    if (bio != null) data['bio'] = bio;
    if (yearsExperience != null) data['years_experience'] = yearsExperience;
    if (languages != null) data['languages'] = languages;
    if (identityDocument != null) data['identity_document'] = identityDocument!.toJson();
    if (driverLicense != null) data['driver_license'] = driverLicense!.toJson();
    if (isAvailable != null) data['is_available'] = isAvailable;
    
    return data;
  }
}