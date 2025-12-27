// lib/data/repositories/notification_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class NotificationRepository {
  final GetStorage storage = GetStorage();
  
  // Use the same base URL as your AgentNotificationService
  String get baseUrl => 'http://13.61.185.238:5050/api/v1/notifications';

  // Method to get headers with authentication token
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

  // 1. UPDATE NOTIFICATION (PATCH)
  Future<Map<String, dynamic>> updateNotification({
    required String notificationId,
    String? title,
    String? message,
    String? type,
    String? priority,
    // Add other fields as needed
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/$notificationId');
      
      final body = <String, dynamic>{};
      if (title != null) body['title'] = title;
      if (message != null) body['message'] = message;
      if (type != null) body['type'] = type;
      if (priority != null) body['priority'] = priority;
      
      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(body),
      );
      
      final result = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Notification updated successfully',
          'notification': result['notification'] ?? result,
        };
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': result['message'] ?? 'Cannot modify a sent or cancelled notification',
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to update notification',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // 2. SCHEDULE NOTIFICATION (POST)
  Future<Map<String, dynamic>> scheduleNotification({
    required String notificationId,
    required String sendAt,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/$notificationId/schedule');
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'send_at': sendAt}),
      );
      
      final result = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Notification scheduled successfully',
          'notification': result['notification'] ?? result,
        };
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': result['message'] ?? 'Cannot schedule a sent or cancelled notification',
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to schedule notification',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // 3. SEND IMMEDIATELY (POST)
  Future<Map<String, dynamic>> sendNotificationImmediately({
    required String notificationId,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/$notificationId/send');
      
      final response = await http.post(
        url,
        headers: headers,
      );
      
      final result = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Notification sent successfully',
          'notification': result['notification'] ?? result,
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to send notification',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // 4. CANCEL NOTIFICATION (POST)
  Future<Map<String, dynamic>> cancelNotification({
    required String notificationId,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/$notificationId/cancel');
      
      final response = await http.post(
        url,
        headers: headers,
      );
      
      final result = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Notification cancelled successfully',
          'notification': result['notification'] ?? result,
        };
      } else if (response.statusCode == 409) {
        return {
          'success': false,
          'message': result['message'] ?? 'Cannot cancel a sent notification',
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to cancel notification',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // 5. DUPLICATE NOTIFICATION
  Future<Map<String, dynamic>> duplicateNotification({
    required String notificationId,
  }) async {
    try {
      // First, get the original notification
      final original = await getNotificationDetail(notificationId);
      
      if (original['success'] != true) {
        return original;
      }
      
      final notificationData = original['notification'] ?? original['data'];
      if (notificationData == null) {
        return {
          'success': false,
          'message': 'No notification data found to duplicate',
        };
      }
      
      // Create a copy of the data
      final newData = Map<String, dynamic>.from(notificationData);
      
      // Remove auto-generated fields
      newData.remove('_id');
      newData.remove('__v');
      newData.remove('sent_at');
      
      // Set new values for the duplicate
      newData['status'] = 'draft';
      newData['send_at'] = null;
      newData['title'] = '${newData['title']?.toString() ?? 'Notification'} (Copy)';
      newData['created_at'] = DateTime.now().toIso8601String();
      newData['updated_at'] = DateTime.now().toIso8601String();
      
      // Create new notification with duplicated data
      final headers = await _getHeaders();
      final url = Uri.parse(baseUrl);
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(newData),
      );
      
      final result = jsonDecode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Notification duplicated successfully',
          'notification': result['notification'] ?? result,
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to duplicate notification',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  // Helper method to get notification detail
  Future<Map<String, dynamic>> getNotificationDetail(String notificationId) async {
    try {
      final headers = await _getHeaders();
      final url = Uri.parse('$baseUrl/$notificationId');
      
      final response = await http.get(
        url,
        headers: headers,
      );
      
      final result = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Notification details loaded',
          'notification': result['notification'] ?? result,
          'data': result['notification'] ?? result,
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Failed to load notification details',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}