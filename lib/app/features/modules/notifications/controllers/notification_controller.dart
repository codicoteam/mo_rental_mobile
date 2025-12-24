// lib/features/modules/notifications/controllers/notification_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationService _notificationService = Get.find();
  final RxList<dynamic> notifications = <dynamic>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;

  // Add role-based properties
  final RxBool isAgent = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('🎯 NotificationController initialized');
    _checkUserRole();
    loadNotifications();
  }

  void _checkUserRole() {
    try {
      isAgent.value = _notificationService.isAgent;
      print('📱 User is ${isAgent.value ? 'Agent' : 'Customer'}');
    } catch (e) {
      print('❌ Error checking user role: $e');
      isAgent.value = false;
    }
  }

// In NotificationController, update loadNotifications method:
  Future<void> loadNotifications() async {
    try {
      print('🔄 Starting to load notifications...');
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final response = await _notificationService.getMyNotifications();

      // IMPORTANT: Check if response is null or empty
      // ignore: unnecessary_null_comparison
      if (response == null) {
        print('❌ Response is null');
        hasError.value = true;
        errorMessage.value = 'No response from server';
        return;
      }

      print('📋 Response received: success=${response['success']}');
      print('📋 Response keys: ${response.keys.toList()}');

      if (response['success'] == true) {
        print('✅ Successfully received notification data');
        notifications.value = response['data'] ?? [];
        unreadCount.value =
            notifications.where((n) => n['read'] == false).length;
        print('📋 Loaded ${notifications.length} notifications');
        print('📋 Unread count: $unreadCount');
      } else {
        print('⚠️ API returned success=false');
        print('⚠️ Message: ${response['message']}');
        hasError.value = true;
        errorMessage.value =
            response['message'] ?? 'Failed to load notifications';

        // Show snackbar only if there's a real error message
        if (errorMessage.value.isNotEmpty) {
          Get.snackbar(
            'Error',
            'Could not load notifications: ${errorMessage.value}',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('🔥 Error loading notifications: $e');
      print('🔥 Stack trace: ${e.toString()}');
      hasError.value = true;
      errorMessage.value = e.toString();

      Get.snackbar(
        'Error',
        'Failed to load notifications: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
      print('🏁 Finished loading notifications');
      print('🏁 isLoading: $isLoading');
      print('🏁 hasError: $hasError');
      print('🏁 errorMessage: $errorMessage');
      print('🏁 notifications length: ${notifications.length}');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);
      if (success) {
        // Update local state
        final index =
            notifications.indexWhere((n) => n['_id'] == notificationId);
        if (index != -1) {
          notifications[index]['read'] = true;
          unreadCount.value--;
          notifications.refresh();
        }
      }
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final unreadIds = notifications
          .where((n) => n['read'] == false)
          .map((n) => n['_id'] as String)
          .toList();

      if (unreadIds.isNotEmpty) {
        final success = await _notificationService.markBulkAsRead(unreadIds);
        if (success) {
          for (var notification in notifications) {
            notification['read'] = true;
          }
          unreadCount.value = 0;
          notifications.refresh();
        }
      }
    } catch (e) {
      print('Error marking all as read: $e');
    }
  }

  // For Agents only: Send notification to specific customer
  Future<void> sendCustomerNotification({
    required String customerId,
    required String title,
    required String message,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Check if user is agent
      if (!isAgent.value) {
        Get.snackbar('Error', 'Only agents can send notifications');
        return;
      }

      final success = await _notificationService.sendNotificationToCustomer(
        customerId: customerId,
        title: title,
        message: message,
        type: type,
        data: data,
      );

      if (success) {
        Get.snackbar('Success', 'Notification sent to customer');
      } else {
        Get.snackbar('Error', 'Failed to send notification');
      }
    } catch (e) {
      print('Error sending notification: $e');
      Get.snackbar('Error', 'Failed to send notification: ${e.toString()}');
    }
  }

  // For Agents only: Create system notification
  Future<void> createSystemNotification({
    required String title,
    required String message,
    List<String>? audience,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Check if user is agent
      if (!isAgent.value) {
        Get.snackbar('Error', 'Only agents can create system notifications');
        return;
      }

      final success = await _notificationService.createSystemNotification(
        title: title,
        message: message,
        audience: audience,
        type: type,
        data: data,
      );

      if (success) {
        Get.snackbar('Success', 'System notification created');
      } else {
        Get.snackbar('Error', 'Failed to create system notification');
      }
    } catch (e) {
      print('Error creating system notification: $e');
      Get.snackbar(
          'Error', 'Failed to create system notification: ${e.toString()}');
    }
  }

  // Clear all notifications from controller (useful for logout)
  void clearNotifications() {
    notifications.clear();
    unreadCount.value = 0;
    isLoading.value = false;
  }

  // Check if notification belongs to current user (additional validation)
  bool isMyNotification(Map<String, dynamic> notification) {
    // You might want to add user ID validation here
    return true; // For now, assume all fetched notifications belong to user
  }

  // Refresh notifications with force reload
  Future<void> refreshNotifications({bool force = false}) async {
    if (force || notifications.isEmpty) {
      await loadNotifications();
    }
  }

  // Get unread notifications only
  List<dynamic> get unreadNotifications {
    return notifications.where((n) => n['read'] == false).toList();
  }

  // Get notifications by type
  List<dynamic> getNotificationsByType(String type) {
    return notifications.where((n) => n['type'] == type).toList();
  }

  // Get today's notifications
  List<dynamic> get todaysNotifications {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return notifications.where((n) {
      if (n['created_at'] == null) return false;
      final created = DateTime.parse(n['created_at']);
      final createdDate = DateTime(created.year, created.month, created.day);
      return createdDate == today;
    }).toList();
  }
}
