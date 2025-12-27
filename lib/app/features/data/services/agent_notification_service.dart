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
// Update getAllNotifications method in agent_notification_service.dart
  Future<Map<String, dynamic>> getAllNotifications({
    String? status,
    String? type,
    String? priority,
    bool? active,
    int page = 1,
    int limit = 20,
    String sort = '-created_at',
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

        // FIX: Based on your API response, it returns:
        // {"success":true,"items":[...]}
        List<dynamic> notifications = [];

        if (data is Map<String, dynamic>) {
          if (data['success'] == true) {
            notifications = data['items'] ?? [];
          } else {
            // If API structure is different
            notifications = data['notifications'] ?? data['data'] ?? [];
          }
        }

        print('📋 Total items in response: ${notifications.length}');

        return {
          'success': true,
          'items': notifications,
          'total': notifications.length, // API doesn't return total count
          'page': page,
          'pages': 1, // Simple pagination since API doesn't provide pages
        };
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('❌ Response: ${response.body}');
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 Error in getAllNotifications: $e');
      rethrow;
    }
  }

  // ========== API 3: GET SINGLE NOTIFICATION (GET /api/v1/notifications/{id}) ==========
  // In agent_notification_service.dart, update getNotificationById
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully loaded notification details');

        // FIX: Return proper structure based on API response
        if (data.containsKey('success') && data['success'] == true) {
          return {
            'success': true,
            'notification': data['notification'] ?? data,
          };
        } else {
          // If no success flag, assume the response is the notification
          return {
            'success': true,
            'notification': data,
          };
        }
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

  // lib/data/services/agent_notification_service.dart
// Add these methods to your existing AgentNotificationService class

// ========== API 4: UPDATE NOTIFICATION (PATCH /api/v1/notifications/{id}) ==========
  Future<Map<String, dynamic>> updateNotification({
    required String notificationId,
    String? title,
    String? message,
    String? type,
    String? priority,
    Map<String, dynamic>? audience,
    List<String>? channels,
    DateTime? sendAt,
    DateTime? expiresAt,
    String? status,
    bool? isActive,
    String? actionText,
    String? actionUrl,
    Map<String, dynamic>? data,
  }) async {
    try {
      print('📝 Updating notification: $notificationId');

      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/$notificationId');

      final body = <String, dynamic>{};

      // Add only provided fields to the update
      if (title != null) body['title'] = title;
      if (message != null) body['message'] = message;
      if (type != null) body['type'] = type;
      if (priority != null) body['priority'] = priority;
      if (audience != null) body['audience'] = audience;
      if (channels != null) body['channels'] = channels;
      if (sendAt != null) body['send_at'] = sendAt.toIso8601String();
      if (expiresAt != null) body['expires_at'] = expiresAt.toIso8601String();
      if (status != null) body['status'] = status;
      if (isActive != null) body['is_active'] = isActive;
      if (actionText != null) body['action_text'] = actionText;
      if (actionUrl != null) body['action_url'] = actionUrl;
      if (data != null) body['data'] = data;

      print('📤 Sending PATCH request to: $url');
      print('📋 Request body: ${jsonEncode(body)}');

      final response = await http
          .patch(
            url,
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Notification updated successfully');
        print('📋 Updated notification ID: ${result['notification']?['_id']}');
        return result;
      } else if (response.statusCode == 409) {
        final errorBody = jsonDecode(response.body);
        print('❌ Conflict: ${errorBody['message']}');
        throw Exception('Cannot modify a sent or cancelled notification');
      } else {
        final errorBody = jsonDecode(response.body);
        print('❌ Failed to update notification: ${errorBody['message']}');
        throw Exception(
            'Failed to update notification: ${errorBody['message']}');
      }
    } catch (e) {
      print('🔥 Error in updateNotification: $e');
      rethrow;
    }
  }

// ========== API 5: SCHEDULE NOTIFICATION (POST /api/v1/notifications/{id}/schedule) ==========
  Future<Map<String, dynamic>> scheduleNotification({
    required String notificationId,
    required DateTime sendAt,
  }) async {
    try {
      print('📅 Scheduling notification: $notificationId');
      print('📅 Send at: $sendAt');

      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/$notificationId/schedule');

      final body = {
        'send_at': sendAt.toIso8601String(),
      };

      print('📤 Sending POST request to: $url');
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

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Notification scheduled successfully');
        print(
            '📋 Scheduled notification ID: ${result['notification']?['_id']}');
        return result;
      } else if (response.statusCode == 409) {
        final errorBody = jsonDecode(response.body);
        print('❌ Conflict: ${errorBody['message']}');
        throw Exception('Cannot schedule a sent or cancelled notification');
      } else {
        final errorBody = jsonDecode(response.body);
        print('❌ Failed to schedule notification: ${errorBody['message']}');
        throw Exception(
            'Failed to schedule notification: ${errorBody['message']}');
      }
    } catch (e) {
      print('🔥 Error in scheduleNotification: $e');
      rethrow;
    }
  }

// ========== API 6: SEND NOTIFICATION IMMEDIATELY (POST /api/v1/notifications/{id}/send) ==========
  Future<Map<String, dynamic>> sendNotificationImmediately({
    required String notificationId,
  }) async {
    try {
      print('🚀 Sending notification immediately: $notificationId');

      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/$notificationId/send');

      print('📤 Sending POST request to: $url');

      final response = await http
          .post(
            url,
            headers: headers,
          )
          .timeout(Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Notification sent successfully');
        print('📋 Sent notification ID: ${result['notification']?['_id']}');
        return result;
      } else {
        final errorBody = jsonDecode(response.body);
        print('❌ Failed to send notification: ${errorBody['message']}');
        throw Exception('Failed to send notification: ${errorBody['message']}');
      }
    } catch (e) {
      print('🔥 Error in sendNotificationImmediately: $e');
      rethrow;
    }
  }

// ========== API 7: CANCEL NOTIFICATION (POST /api/v1/notifications/{id}/cancel) ==========
  Future<Map<String, dynamic>> cancelNotification({
    required String notificationId,
  }) async {
    try {
      print('❌ Cancelling notification: $notificationId');

      final headers = await _getHeaders();
      final url = Uri.parse('$_baseUrl/$notificationId/cancel');

      print('📤 Sending POST request to: $url');

      final response = await http
          .post(
            url,
            headers: headers,
          )
          .timeout(Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Notification cancelled successfully');
        print(
            '📋 Cancelled notification ID: ${result['notification']?['_id']}');
        return result;
      } else if (response.statusCode == 409) {
        final errorBody = jsonDecode(response.body);
        print('❌ Conflict: ${errorBody['message']}');
        throw Exception('Cannot cancel a sent notification');
      } else {
        final errorBody = jsonDecode(response.body);
        print('❌ Failed to cancel notification: ${errorBody['message']}');
        throw Exception(
            'Failed to cancel notification: ${errorBody['message']}');
      }
    } catch (e) {
      print('🔥 Error in cancelNotification: $e');
      rethrow;
    }
  }

// ========== HELPER METHODS ==========

// Helper to check if notification can be modified
  bool canModifyNotification(Map<String, dynamic> notification) {
    final status = notification['status']?.toString() ?? 'draft';
    return status == 'draft' || status == 'scheduled';
  }

// Helper to check if notification can be sent
  bool canSendNotification(Map<String, dynamic> notification) {
    final status = notification['status']?.toString() ?? 'draft';
    return status == 'draft' || status == 'scheduled';
  }

// Helper to check if notification can be cancelled
  bool canCancelNotification(Map<String, dynamic> notification) {
    final status = notification['status']?.toString() ?? 'draft';
    return status == 'draft' || status == 'scheduled';
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

  // Debug info
  void printDebugInfo() {
    print('\n🔵🔵🔵 AGENT NOTIFICATION SERVICE DEBUG 🔵🔵🔵');
    print('Agent User ID: $agentUserId');
    print('Is Agent: $isAgent');
    print('Base URL: $_baseUrl');
    print('🔵🔵🔵 END DEBUG 🔵🔵🔵\n');
  }
}
