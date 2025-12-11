import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../app/features/data/models/reservation_models/reservation_models.dart';


class ReservationRepository {
  final GetStorage _storage = GetStorage();

  ReservationRepository();

  // Get auth token
  String? _getAuthToken() {
    return _storage.read('auth_token');
  }

  // Get base URL from storage or use default
  String _getBaseUrl() {
    return _storage.read('api_base_url') ?? 'http://13.61.185.238:5050';
  }

  // Check vehicle availability
  Future<AvailabilityResponse> checkVehicleAvailability(AvailabilityRequest request) async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login.');
      }

      print('🚗 Checking vehicle availability...');
      print('📅 Request: ${request.toJson()}');

      final url = Uri.parse('${_getBaseUrl()}/api/v1/reservations/availability');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(const Duration(seconds: 15));

      print('📊 HTTP Response Status: ${response.statusCode}');
      print('📄 HTTP Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse['success'] == true && jsonResponse.containsKey('data')) {
          final availability = AvailabilityResponse.fromJson(jsonResponse['data']);
          print('✅ Availability check successful');
          print('   Available: ${availability.available}');
          if (availability.vehicle != null) {
            print('   Vehicle: ${availability.vehicle!.displayName}');
          }
          return availability;
        } else {
          throw Exception('API returned success: false - ${jsonResponse['message']}');
        }
      } else if (response.statusCode == 400) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        throw Exception('Validation error: ${jsonResponse['message']}');
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 500) {
        // Handle server error
        try {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          throw Exception('Server error: ${jsonResponse['message']}');
        } catch (_) {
          throw Exception('Internal server error');
        }
      } else {
        throw Exception('Request failed with status ${response.statusCode}');
      }
    } on SocketException {
      print('🌐 Network error: No internet connection');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (_) {
      print('⏰ Timeout while checking availability');
      throw Exception('Request timeout. Please try again.');
    } catch (e) {
      print('❌ Repository error in checkVehicleAvailability: $e');
      rethrow;
    }
  }

  // Create reservation (to be implemented later)
 // Add this method to your ReservationRepository class
Future<CreateReservationResponse> createReservation(CreateReservationRequest request) async {
  try {
    final token = _getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found. Please login.');
    }

    print('📝 Creating reservation...');
    print('📦 Request: ${request.toJson()}');

    final url = Uri.parse('${_getBaseUrl()}/api/v1/reservations');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    ).timeout(const Duration(seconds: 15));

    print('📊 HTTP Response Status: ${response.statusCode}');
    print('📄 HTTP Response Body: ${response.body}');

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    
    if (response.statusCode == 201) {
      print('✅ Reservation created successfully');
      return CreateReservationResponse.fromJson(jsonResponse);
    } else if (response.statusCode == 400) {
      final errorMsg = jsonResponse['message'] ?? 'Validation error';
      final details = jsonResponse['details'] ?? '';
      print('❌ Validation error: $errorMsg - $details');
      throw Exception('$errorMsg${details.isNotEmpty ? ': $details' : ''}');
    } else if (response.statusCode == 401) {
      throw Exception('Session expired. Please login again.');
    } else if (response.statusCode == 409) {
      throw Exception('Reservation code already exists. Please try a different code.');
    } else {
      final errorMsg = jsonResponse['message'] ?? 'Unknown error';
      throw Exception('Failed to create reservation: $errorMsg');
    }
  } on SocketException {
    print('🌐 Network error: No internet connection');
    throw Exception('No internet connection. Please check your network.');
  } on TimeoutException catch (_) {
    print('⏰ Timeout while creating reservation');
    throw Exception('Request timeout. Please try again.');
  } catch (e) {
    print('❌ Repository error in createReservation: $e');
    rethrow;
  }
}

  // Get reservations list with optional filters
Future<List<Reservation>> getReservations({
  String? code,
  String? userId,
  String? status,
  String? vehicleId,
  String? vehicleModelId,
  String? createdBy,
  DateTime? pickupFrom,
  DateTime? pickupTo,
  DateTime? dropoffFrom,
  DateTime? dropoffTo,
}) async {
  try {
    final token = _getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found. Please login.');
    }

    print('📋 Fetching reservations list...');

    // Build query parameters
    final Map<String, String> queryParams = {};
    
    if (code != null && code.isNotEmpty) queryParams['code'] = code;
    if (userId != null && userId.isNotEmpty) queryParams['user_id'] = userId;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (vehicleId != null && vehicleId.isNotEmpty) queryParams['vehicle_id'] = vehicleId;
    if (vehicleModelId != null && vehicleModelId.isNotEmpty) queryParams['vehicle_model_id'] = vehicleModelId;
    if (createdBy != null && createdBy.isNotEmpty) queryParams['created_by'] = createdBy;
    if (pickupFrom != null) queryParams['pickup_from'] = pickupFrom.toIso8601String();
    if (pickupTo != null) queryParams['pickup_to'] = pickupTo.toIso8601String();
    if (dropoffFrom != null) queryParams['dropoff_from'] = dropoffFrom.toIso8601String();
    if (dropoffTo != null) queryParams['dropoff_to'] = dropoffTo.toIso8601String();

    // Build URL with query parameters
    final url = Uri.parse('${_getBaseUrl()}/api/v1/reservations').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    print('🔗 Fetching from URL: ${url.toString()}');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    print('📊 HTTP Response Status: ${response.statusCode}');
    print('📄 HTTP Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['success'] == true) {
        if (jsonResponse.containsKey('data')) {
          final List<dynamic> reservationsJson = jsonResponse['data'];
          
          if (reservationsJson.isEmpty) {
            print('ℹ️ No reservations found');
            return [];
          }
          
         final reservations = reservationsJson.map((json) {
  try {
    print('🔄 Parsing reservation JSON...');
    return Reservation.fromJson(json);
  } catch (e, stackTrace) {
    print('❌ Error parsing reservation: $e');
    print('📋 Stack trace: $stackTrace');
    print('📋 Problematic JSON: $json');
    return null;
  }
}).whereType<Reservation>().toList();
          
          print('✅ Successfully fetched ${reservations.length} reservation(s)');
          return reservations;
        } else {
          // Handle case where data might be empty or null
          print('ℹ️ No data field in response, returning empty list');
          return [];
        }
      } else {
        throw Exception('API returned success: false - ${jsonResponse['message']}');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else if (response.statusCode == 500) {
      throw Exception('Server error. Please try again later.');
    } else {
      throw Exception('Request failed with status ${response.statusCode}');
    }
  } on SocketException {
    print('🌐 Network error: No internet connection');
    throw Exception('No internet connection. Please check your network.');
  } on TimeoutException catch (_) {
    print('⏰ Timeout while fetching reservations');
    throw Exception('Request timeout. Please try again.');
  } catch (e) {
    print('❌ Repository error in getReservations: $e');
    rethrow;
  }
}

  // Get reservations list (to be implemented later)
 Future<Reservation> getReservationById(String id) async {
  try {
    final token = _getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found. Please login.');
    }

    print('📋 Fetching reservation by ID: $id');

    final url = Uri.parse('${_getBaseUrl()}/api/v1/reservations/$id');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    print('📊 HTTP Response Status: ${response.statusCode}');
    print('📄 HTTP Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      
      if (jsonResponse['success'] == true && jsonResponse.containsKey('data')) {
        final reservation = Reservation.fromJson(jsonResponse['data']);
        print('✅ Successfully fetched reservation: ${reservation.id}');
        return reservation;
      } else {
        throw Exception('API returned success: false - ${jsonResponse['message']}');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else if (response.statusCode == 404) {
      throw Exception('Reservation not found.');
    } else if (response.statusCode == 500) {
      throw Exception('Server error. Please try again later.');
    } else {
      throw Exception('Request failed with status ${response.statusCode}');
    }
  } on SocketException {
    print('🌐 Network error: No internet connection');
    throw Exception('No internet connection. Please check your network.');
  } on TimeoutException catch (_) {
    print('⏰ Timeout while fetching reservation');
    throw Exception('Request timeout. Please try again.');
  } catch (e) {
    print('❌ Repository error in getReservationById: $e');
    rethrow;
  }
}

  // Get reservation by ID (to be implemented later)

}