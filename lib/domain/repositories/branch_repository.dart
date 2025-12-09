// features/modules/branches/repositories/branch_repository.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

import '../../app/features/data/models/branch_models/branch_models.dart';

class BranchRepository {
  final GetStorage _storage = GetStorage();

  BranchRepository();

  // Get auth token
  String? _getAuthToken() {
    return _storage.read('auth_token');
  }

  // Get base URL from storage or use default
  String _getBaseUrl() {
    return _storage.read('api_base_url') ?? 'http://13.61.185.238:5050';
  }

  // Add this method to BranchRepository class
Future<List<Branch>> getNearbyBranches({
  required double longitude,
  required double latitude,
  int maxDistance = 5000, // Default 5km
}) async {
  try {
    final token = _getAuthToken();
    if (token == null) {
      throw Exception('No authentication token found. Please login.');
    }

    print('📍 Finding nearby branches...');
    print('   Location: lat=$latitude, lng=$longitude');
    print('   Max Distance: ${maxDistance}m (${maxDistance / 1000}km)');

    // Build query parameters
    final Map<String, String> queryParams = {
      'lng': longitude.toString(),
      'lat': latitude.toString(),
      'maxDistance': maxDistance.toString(),
    };

    // Build URL with query parameters
    final url = Uri.parse('${_getBaseUrl()}/api/v1/branches/nearby').replace(
      queryParameters: queryParams,
    );

    print('🔗 Nearby URL: ${url.toString()}');

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
        final List<dynamic> branchesJson = jsonResponse['data'] ?? [];
        
        if (branchesJson.isEmpty) {
          print('ℹ️ No nearby branches found within ${maxDistance}m');
          return [];
        }
        
        final branches = branchesJson.map((json) {
          try {
            return Branch.fromJson(json);
          } catch (e) {
            print('⚠️ Error parsing nearby branch: $e');
            return null;
          }
        }).whereType<Branch>().toList();
        
        print('✅ Found ${branches.length} nearby branch(es)');
        return branches;
      } else {
        throw Exception('API returned success: false - ${jsonResponse['message']}');
      }
    } else if (response.statusCode == 400) {
      throw Exception('Invalid location parameters.');
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
    print('⏰ Timeout while finding nearby branches');
    throw Exception('Request timeout. Please try again.');
  } catch (e) {
    print('❌ Repository error in getNearbyBranches: $e');
    rethrow;
  }
}

// Also add this helper method to get distance between two points
double calculateDistance(
  double lat1, double lon1,
  double lat2, double lon2,
) {
  const earthRadius = 6371000.0; // meters

  final dLat = _toRadians(lat2 - lat1);
  final dLon = _toRadians(lon2 - lon1);

  final a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_toRadians(lat1)) *
          cos(_toRadians(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);
  
  final c = 2 * atan2(sqrt(a), sqrt(1 - a));
  final distance = earthRadius * c;

  return distance;
}

double _toRadians(double degrees) {
  return degrees * pi / 180;
}

  // Get all branches
  Future<List<Branch>> getAllBranches() async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login.');
      }

      print('🏢 Fetching all branches...');

      final url = Uri.parse('${_getBaseUrl()}/api/v1/branches');

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
          final List<dynamic> branchesJson = jsonResponse['data'] ?? [];
          
          if (branchesJson.isEmpty) {
            print('ℹ️ No branches found');
            return [];
          }
          
          final branches = branchesJson.map((json) {
            try {
              return Branch.fromJson(json);
            } catch (e) {
              print('⚠️ Error parsing branch: $e');
              return null;
            }
          }).whereType<Branch>().toList();
          
          print('✅ Successfully fetched ${branches.length} branch(es)');
          return branches;
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
      print('⏰ Timeout while fetching branches');
      throw Exception('Request timeout. Please try again.');
    } catch (e) {
      print('❌ Repository error in getAllBranches: $e');
      rethrow;
    }
  }

  // Search branches with filters
  Future<List<Branch>> searchBranches({
    String? city,
    String? region,
    bool? active,
    String? query,
  }) async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login.');
      }

      print('🔍 Searching branches...');

      // Build query parameters
      final Map<String, String> queryParams = {};
      
      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (region != null && region.isNotEmpty) queryParams['region'] = region;
      if (active != null) queryParams['active'] = active.toString();
      if (query != null && query.isNotEmpty) queryParams['q'] = query;

      // Build URL with query parameters
      final url = Uri.parse('${_getBaseUrl()}/api/v1/branches/search').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('🔗 Searching from URL: ${url.toString()}');

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
          final List<dynamic> branchesJson = jsonResponse['data'] ?? [];
          
          if (branchesJson.isEmpty) {
            print('ℹ️ No branches found for search');
            return [];
          }
          
          final branches = branchesJson.map((json) {
            try {
              return Branch.fromJson(json);
            } catch (e) {
              print('⚠️ Error parsing branch: $e');
              return null;
            }
          }).whereType<Branch>().toList();
          
          print('✅ Successfully found ${branches.length} branch(es)');
          return branches;
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
      print('⏰ Timeout while searching branches');
      throw Exception('Request timeout. Please try again.');
    } catch (e) {
      print('❌ Repository error in searchBranches: $e');
      rethrow;
    }
  }

  // Check if branch is open
  Future<BranchStatusResponse> checkBranchOpenStatus({
    required String branchId,
    DateTime? at,
  }) async {
    try {
      final token = _getAuthToken();
      if (token == null) {
        throw Exception('No authentication token found. Please login.');
      }

      print('⏰ Checking if branch $branchId is open...');

      // Build query parameters
      final Map<String, String> queryParams = {};
      if (at != null) queryParams['at'] = at.toIso8601String();

      // Build URL with query parameters
      final url = Uri.parse('${_getBaseUrl()}/api/v1/branches/$branchId/is-open').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('🔗 Checking from URL: ${url.toString()}');

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
          final status = BranchStatusResponse.fromJson(jsonResponse['data']);
          print('✅ Branch is ${status.open ? "OPEN" : "CLOSED"} at ${status.at}');
          return status;
        } else {
          throw Exception('API returned success: false - ${jsonResponse['message']}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 404) {
        throw Exception('Branch not found.');
      } else if (response.statusCode == 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        throw Exception('Request failed with status ${response.statusCode}');
      }
    } on SocketException {
      print('🌐 Network error: No internet connection');
      throw Exception('No internet connection. Please check your network.');
    } on TimeoutException catch (_) {
      print('⏰ Timeout while checking branch status');
      throw Exception('Request timeout. Please try again.');
    } catch (e) {
      print('❌ Repository error in checkBranchOpenStatus: $e');
      rethrow;
    }
  }

  // Get active branches only
  Future<List<Branch>> getActiveBranches() async {
    try {
      final allBranches = await getAllBranches();
      final activeBranches = allBranches.where((branch) => branch.active).toList();
      print('✅ Found ${activeBranches.length} active branch(es)');
      return activeBranches;
    } catch (e) {
      print('❌ Error getting active branches: $e');
      rethrow;
    }
  }

  // Get branches by city
  Future<List<Branch>> getBranchesByCity(String city) async {
    try {
      final branches = await searchBranches(city: city);
      print('✅ Found ${branches.length} branch(es) in $city');
      return branches;
    } catch (e) {
      print('❌ Error getting branches by city: $e');
      rethrow;
    }
  }

  // Get branches by region
  Future<List<Branch>> getBranchesByRegion(String region) async {
    try {
      final branches = await searchBranches(region: region);
      print('✅ Found ${branches.length} branch(es) in $region');
      return branches;
    } catch (e) {
      print('❌ Error getting branches by region: $e');
      rethrow;
    }
  }

  // Get branch by ID (from list)
  Future<Branch?> getBranchById(String id) async {
    try {
      final branches = await getAllBranches();
      final branch = branches.firstWhere(
        (branch) => branch.id == id,
        orElse: () => throw Exception('Branch not found'),
      );
      print('✅ Found branch: ${branch.name}');
      return branch;
    } catch (e) {
      print('❌ Error getting branch by ID: $e');
      return null;
    }
  }
}