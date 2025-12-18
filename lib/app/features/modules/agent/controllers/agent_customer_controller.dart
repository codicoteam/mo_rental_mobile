import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AgentCustomerController extends GetxController {
  final GetStorage storage = GetStorage();
  
  final RxList<Map<String, dynamic>> customers = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    try {
      isLoading.value = true;
      error.value = '';
      customers.clear();

      final token = storage.read('auth_token');
      if (token == null) {
        throw Exception('Please login first');
      }

      final baseUrl = storage.read('api_base_url') ?? 'http://13.61.185.238:5050';
      
      // Fetch all customers (users with role 'customer')
      final url = Uri.parse('$baseUrl/api/v1/users?role=customer&limit=100');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          if (jsonResponse['data'] is List) {
            customers.value = List<Map<String, dynamic>>.from(jsonResponse['data']);
          } else if (jsonResponse['data'] is Map && jsonResponse['data'].containsKey('users')) {
            customers.value = List<Map<String, dynamic>>.from(jsonResponse['data']['users']);
          } else if (jsonResponse['data'] is Map && jsonResponse['data'].containsKey('results')) {
            customers.value = List<Map<String, dynamic>>.from(jsonResponse['data']['results']);
          } else if (jsonResponse['data'] is Map && jsonResponse['data'].containsKey('items')) {
            customers.value = List<Map<String, dynamic>>.from(jsonResponse['data']['items']);
          } else {
            // Try to extract any list from the data
            final dataMap = jsonResponse['data'] as Map<String, dynamic>;
            for (var value in dataMap.values) {
              if (value is List) {
                customers.value = List<Map<String, dynamic>>.from(value);
                break;
              }
            }
          }
          print('✅ Loaded ${customers.length} customers');
        } else {
          throw Exception(jsonResponse['message'] ?? 'Failed to fetch customers');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      error.value = e.toString();
      print('❌ Error fetching customers: $e');
      Get.snackbar(
        'Error',
        'Failed to load customers: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get filteredCustomers {
    if (searchQuery.value.isEmpty) {
      return customers;
    }
    
    final query = searchQuery.value.toLowerCase();
    return customers.where((customer) {
      final name = customer['full_name']?.toString().toLowerCase() ?? '';
      final email = customer['email']?.toString().toLowerCase() ?? '';
      final phone = customer['phone']?.toString().toLowerCase() ?? '';
      final id = customer['id']?.toString().toLowerCase() ?? 
                customer['_id']?.toString().toLowerCase() ?? '';
      
      return name.contains(query) || 
             email.contains(query) || 
             phone.contains(query) ||
             id.contains(query);
    }).toList();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void clearSearch() {
    searchQuery.value = '';
  }

  Future<void> refreshCustomers() async {
    await fetchCustomers();
  }
}