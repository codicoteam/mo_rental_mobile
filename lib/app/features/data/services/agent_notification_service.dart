// lib/data/services/agent_notification_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class AgentNotificationService extends GetxService {
  final GetStorage storage = GetStorage();

  String get _baseUrl => 'http://13.61.185.238:5050/api/v1/notifications';

  Future<Map<String, String>> _getHeaders() async {
    final token = storage.read('auth_token') ??
        storage.read('token') ??
        storage.read('access_token');

    return {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  // ========== API 1: CREATE NOTIFICATION (POST /api/v1/notifications) ==========
  Future<Map<String, dynamic>> createNotification({
    required String title,
    required String message,
    required String type,
    String? priority, // normal, high, urgent
    Map<String, dynamic>?
        audience, // { scope: 'user', user_id: '...', roles: ['customer'] }
    List<String>? channels, // ['in_app', 'email', 'sms']
    DateTime? sendAt, // Schedule for future
    DateTime? expiresAt,
    String? status, // draft, scheduled, sent
    bool? isActive,
    String? actionText,
    String? actionUrl,
    Map<String, dynamic>? data, // Additional data
  }) async {
    try {
      print('📝 Creating new notification');
      print('📋 Title: $title');
      print('📋 Type: $type');
      print('📋 Audience: ${audience?['scope'] ?? 'all'}');

      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/');

      final body = {
        'title': title,
        'message': message,
        'type': type,
        'priority': priority ?? 'normal',
        'audience': audience ??
            {
              'scope': 'all',
              'roles': ['customer']
            },
        'channels': channels ?? ['in_app'],
        'status': status ?? 'draft',
        'is_active': isActive ?? true,
        if (actionText != null) 'action_text': actionText,
        if (actionUrl != null) 'action_url': actionUrl,
        'data': data ?? {},
        if (sendAt != null) 'send_at': sendAt.toIso8601String(),
        if (expiresAt != null) 'expires_at': expiresAt.toIso8601String(),
      };

      print('📤 Sending request to: $url');
      print('📋 Request body: ${jsonEncode(body)}');

      final response = await http
          .post(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Notification created successfully');
        print('📋 Notification ID: ${result['notification']?['_id']}');
        return result;
      } else {
        final errorBody = jsonDecode(response.body);
        print('❌ Failed to create notification: ${errorBody['message']}');
        throw Exception(
            'Failed to create notification: ${errorBody['message']}');
      }
    } catch (e) {
      print('🔥 Error in createNotification: $e');
      rethrow;
    }
  }

  // ========== API 2: LIST ALL NOTIFICATIONS (GET /api/v1/notifications) ==========
  Future<Map<String, dynamic>> getAllNotifications({
    String? status, // draft, scheduled, sent
    String? type, // payment, info, alert, system
    String? priority, // normal, high, urgent
    bool? active,
    int page = 1,
    int limit = 20,
    String sort = '-created_at', // -created_at for newest first
  }) async {
    try {
      print('📋 Fetching all notifications for agent');
      print('📊 Parameters: page=$page, limit=$limit, status=$status');

      final headers = await _getHeaders();

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': sort,
      };

      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;
      if (priority != null) queryParams['priority'] = priority;
      if (active != null) queryParams['active'] = active.toString();

      final url = Uri.parse('$_baseUrl/').replace(queryParameters: queryParams);

      print('🌐 URL: $url');

      final response = await http
          .get(
            url,
            headers: headers,
          )
          .timeout(Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully loaded notifications');
        print('📋 Total items: ${data['total']}');
        print('📋 Current page: ${data['page']}');
        print('📋 Total pages: ${data['pages']}');
        return data;
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 Error in getAllNotifications: $e');
      rethrow;
    }
  }

  // ========== API 3: GET SINGLE NOTIFICATION (GET /api/v1/notifications/{id}) ==========
  Future<Map<String, dynamic>> getNotificationById(
      String notificationId) async {
    try {
      print('🔍 Fetching notification details for: $notificationId');

      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/$notificationId');

      print('🌐 URL: $url');

      final response = await http
          .get(
            url,
            headers: headers,
          )
          .timeout(Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully loaded notification details');
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('Notification not found');
      } else {
        throw Exception('Failed to load notification: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 Error in getNotificationById: $e');
      rethrow;
    }
  }

  // ========== HELPER METHODS ==========

  // Helper to create audience object
  // Helper to create audience object
  Map<String, dynamic> createAudience({
    String scope = 'all', // all, user, role
    String? userId,
    List<String>? roles,
  }) {
    final audience = <String, dynamic>{'scope': scope};

    if (userId != null && userId.isNotEmpty) {
      audience['user_id'] = userId;
    }

    if (roles != null && roles.isNotEmpty) {
      // This is correct - roles should be List<String>
      audience['roles'] = roles;
    } else if (scope == 'role' && roles == null) {
      // If scope is 'role' but no roles provided, default to ['customer']
      audience['roles'] = ['customer'];
    }

    return audience;
  }

  // Helper to get user ID for creating notifications
  String? get agentUserId {
    final userData = storage.read('user_data');
    return userData?['_id']?.toString() ?? userData?['id']?.toString();
  }

  // Check if user is agent
  bool get isAgent {
    final userData = storage.read('user_data');
    if (userData != null && userData['roles'] != null) {
      final roles = userData['roles'] as List<dynamic>;
      return roles
          .any((role) => role.toString().toLowerCase().contains('agent'));
    }
    return false;
  }

  // Get notification stats
  Map<String, dynamic> calculateStats(List<dynamic> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int draftCount = 0;
    int scheduledCount = 0;
    int sentCount = 0;
    int todayCount = 0;

    for (var notification in notifications) {
      final status = notification['status']?.toString() ?? 'draft';
      switch (status) {
        case 'draft':
          draftCount++;
          break;
        case 'scheduled':
          scheduledCount++;
          break;
        case 'sent':
          sentCount++;
          break;
      }

      // Check if created today
      final createdAt = notification['created_at']?.toString();
      if (createdAt != null) {
        try {
          final createdDate = DateTime.parse(createdAt);
          final createdDateOnly =
              DateTime(createdDate.year, createdDate.month, createdDate.day);
          if (createdDateOnly == today) {
            todayCount++;
          }
        } catch (e) {
          print('Error parsing date: $e');
        }
      }
    }

    return {
      'total': notifications.length,
      'draft': draftCount,
      'scheduled': scheduledCount,
      'sent': sentCount,
      'today': todayCount,
    };
  }

  // Send immediate notification (schedule for now)
  Future<Map<String, dynamic>> sendImmediateNotification({
    required String title,
    required String message,
    required Map<String, dynamic> audience,
    String type = 'info',
  }) async {
    return await createNotification(
      title: title,
      message: message,
      type: type,
      audience: audience,
      status: 'sent', // Immediate notifications are sent
      sendAt: DateTime.now(),
    );
  }

  // Schedule notification for future
  Future<Map<String, dynamic>> scheduleNotification({
    required String title,
    required String message,
    required Map<String, dynamic> audience,
    required DateTime sendAt,
    String type = 'info',
  }) async {
    return await createNotification(
      title: title,
      message: message,
      type: type,
      audience: audience,
      status: 'scheduled',
      sendAt: sendAt,
    );
  }

  // Debug info
  void printDebugInfo() {
    print('\n🔵🔵🔵 AGENT NOTIFICATION SERVICE DEBUG 🔵🔵🔵');
    print('Agent User ID: $agentUserId');
    print('Is Agent: $isAgent');
    print('Base URL: $_baseUrl');
    print('🔵🔵🔵 END DEBUG 🔵🔵🔵\n');
  }
}
