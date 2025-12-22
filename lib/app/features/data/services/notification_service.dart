// lib/data/services/notification_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class NotificationService extends GetxService {
  final GetStorage storage = GetStorage();
  
  // Use the same base URL pattern from your existing services
  String get _baseUrl => 'http://13.61.185.238:5050/api/v1/notifications';
  
  Future<Map<String, String>> _getHeaders() async {
    // Use your existing token storage pattern
    final token = storage.read('auth_token') ?? 
                 storage.read('token') ?? 
                 storage.read('access_token');
    
    return {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
  
  // Get notifications for current user
  Future<Map<String, dynamic>> getMyNotifications({
    bool onlyUnread = false,
    bool includeFuture = false,
    int page = 1,
    int limit = 20,
    String sort = '-created_at',
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/mine')
          .replace(queryParameters: {
            'onlyUnread': onlyUnread.toString(),
            'includeFuture': includeFuture.toString(),
            'page': page.toString(),
            'limit': limit.toString(),
            'sort': sort,
          });
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getMyNotifications: $e');
      rethrow;
    }
  }
  
  // Mark single notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/$notificationId/read');
      
      final response = await http.post(url, headers: headers);
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error in markAsRead: $e');
      return false;
    }
  }
  
  // Bulk mark notifications as read
  Future<bool> markBulkAsRead(List<String> notificationIds) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/bulk/read');
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'ids': notificationIds}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error in markBulkAsRead: $e');
      return false;
    }
  }
  
  // ========== ADD THESE MISSING METHODS ==========
  
  // Send notification to specific customer (for agents)
  Future<bool> sendNotificationToCustomer({
    required String customerId,
    required String title,
    required String message,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final headers = await _getHeaders();
      
      // Check if endpoint exists - you may need to create this endpoint
      final url = Uri.parse('$_baseUrl/send');
      
      final body = {
        'recipientId': customerId,
        'title': title,
        'message': message,
        'type': type ?? 'direct',
        'data': data ?? {},
      };
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error in sendNotificationToCustomer: $e');
      return false;
    }
  }
  
  // Create system notification (for agents)
  Future<bool> createSystemNotification({
    required String title,
    required String message,
    List<String>? audience,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      final headers = await _getHeaders();
      
      // Check if endpoint exists - you may need to create this endpoint
      final url = Uri.parse('$_baseUrl/system');
      
      final body = {
        'title': title,
        'message': message,
        'audience': audience ?? ['all'],
        'type': type ?? 'system',
        'data': data ?? {},
      };
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error in createSystemNotification: $e');
      return false;
    }
  }
  
  // ========== ROLE CHECK METHODS ==========
  
  // Get user role from your existing auth system
  String? get _userRole {
    final userData = storage.read('user_data');
    if (userData != null && userData['roles'] != null) {
      final roles = userData['roles'] as List<dynamic>;
      return roles.isNotEmpty ? roles[0].toString() : 'customer';
    }
    return 'customer';
  }
  
  bool get isAgent => _userRole?.contains('agent') == true;
  bool get isCustomer => !isAgent;
  
  // Get all notifications (for agents to view all)
  Future<Map<String, dynamic>> getAllNotifications({
    int page = 1,
    int limit = 50,
    String sort = '-created_at',
  }) async {
    try {
      // Only agents should access this
      if (!isAgent) {
        throw Exception('Unauthorized: Only agents can view all notifications');
      }
      
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/all')
          .replace(queryParameters: {
            'page': page.toString(),
            'limit': limit.toString(),
            'sort': sort,
          });
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load all notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllNotifications: $e');
      rethrow;
    }
  }
  
  // Delete notification (for agents)
  Future<bool> deleteNotification(String notificationId) async {
    try {
      // Only agents should access this
      if (!isAgent) {
        throw Exception('Unauthorized: Only agents can delete notifications');
      }
      
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/$notificationId');
      
      final response = await http.delete(url, headers: headers);
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error in deleteNotification: $e');
      return false;
    }
  }
  
  // Get notification statistics (for agents dashboard)
  Future<Map<String, dynamic>> getNotificationStats() async {
    try {
      // Only agents should access this
      if (!isAgent) {
        throw Exception('Unauthorized: Only agents can view notification stats');
      }
      
      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/stats');
      
      final response = await http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load notification stats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getNotificationStats: $e');
      rethrow;
    }
  }
}