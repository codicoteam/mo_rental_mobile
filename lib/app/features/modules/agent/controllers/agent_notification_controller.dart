// lib/features/modules/notifications/controllers/agent_notification_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/agent_notification_service.dart';

class AgentNotificationController extends GetxController {
  final AgentNotificationService _service = Get.find();

  // Reactive variables
  final RxList<dynamic> agentNotifications = <dynamic>[].obs;
  final RxMap<String, dynamic> notificationStats = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;

  final RxMap<String, dynamic> selectedNotification = <String, dynamic>{}.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxBool hasErrorDetail = false.obs;
  final RxString errorMessageDetail = ''.obs;

  // Filter states
  final RxString filterStatus = ''.obs;
  final RxString filterType = ''.obs;
  final RxString filterPriority = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('🎯 AgentNotificationController initialized');
    loadAgentNotifications();
  }

  // ========== LOAD NOTIFICATIONS ==========
  Future<void> loadAgentNotifications({
    int page = 1,
    bool refresh = false,
  }) async {
    try {
      if (isLoading.value) return; // Prevent multiple calls
      
      print('🔄 Loading agent notifications...');
      isLoading(true);
      hasError(false);
      errorMessage('');

      if (refresh) {
        currentPage(page);
        agentNotifications.clear(); // Clear existing items
      }

      final response = await _service.getAllNotifications(
        status: filterStatus.value.isEmpty ? null : filterStatus.value,
        type: filterType.value.isEmpty ? null : filterType.value,
        priority: filterPriority.value.isEmpty ? null : filterPriority.value,
        page: page,
        limit: 20,
      );

      print('🔍 Response structure: ${response.keys.toList()}');
      
      if (response['success'] == true) {
        final items = response['items'] as List<dynamic>;
        print('📋 Received ${items.length} items');
        
        if (page == 1) {
          // Use assignAll for RxList
          agentNotifications.assignAll(items);
        } else {
          agentNotifications.addAll(items);
        }

        // Update pagination
        currentPage(response['page'] as int? ?? page);
        totalPages(response['pages'] as int? ?? 1);
        totalItems(response['total'] as int? ?? items.length);

        // Calculate stats
        notificationStats(_service.calculateStats(agentNotifications.toList()));

        print('✅ Loaded ${agentNotifications.length} notifications');
        print('📊 Stats: ${notificationStats}');
        print('📊 Page: ${currentPage.value}/${totalPages.value}');
      } else {
        hasError(true);
        errorMessage(response['message'] ?? 'Failed to load notifications');
        print('❌ API returned false: ${errorMessage.value}');
      }
    } catch (e) {
      print('🔥 Error loading agent notifications: $e');
      hasError(true);
      errorMessage(e.toString());

      Get.snackbar(
        'Error',
        'Failed to load notifications: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
      update(); // Trigger UI update
    }
  }

  // ========== LOAD NOTIFICATION DETAILS ==========
  Future<void> loadNotificationDetail(String notificationId) async {
    try {
      print('🔍 Loading notification detail: $notificationId');
      isLoadingDetail(true);
      hasErrorDetail(false);
      errorMessageDetail('');
      update(['notification_detail']);

      final response = await _service.getNotificationById(notificationId);

      print('🔍 Detail response keys: ${response.keys.toList()}');
      
      if (response['success'] == true) {
        final notificationData = Map<String, dynamic>.from(response['notification'] ?? {});
        selectedNotification(notificationData);
        
        print('✅ Loaded notification detail: ${notificationData['title']}');
        print('🔍 Selected notification keys: ${notificationData.keys.toList()}');
      } else {
        hasErrorDetail(true);
        errorMessageDetail(response['message'] ?? 'Failed to load notification');
        print('❌ Detail API returned false: ${errorMessageDetail.value}');
      }
    } catch (e) {
      print('🔥 Error loading notification detail: $e');
      hasErrorDetail(true);
      errorMessageDetail(e.toString());
      
      Get.snackbar(
        'Error',
        'Failed to load notification details: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingDetail(false);
      update(['notification_detail']);
    }
  }

  // ========== CREATE NEW NOTIFICATION ==========
  Future<Map<String, dynamic>> createNewNotification({
    required String title,
    required String message,
    required String type,
    Map<String, dynamic>? audience,
    DateTime? sendAt,
    String status = 'draft',
  }) async {
    try {
      print('📝 Creating new notification: $title');

      final response = await _service.createNotification(
        title: title,
        message: message,
        type: type,
        audience: audience ?? _service.createAudience(),
        sendAt: sendAt,
        status: status,
      );

      if (response['success'] == true) {
        Get.snackbar(
          'Success',
          'Notification created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh the list
        loadAgentNotifications(refresh: true);

        return {'success': true, 'notification': response['notification']};
      } else {
        throw Exception(response['message'] ?? 'Failed to create notification');
      }
    } catch (e) {
      print('🔥 Error creating notification: $e');

      Get.snackbar(
        'Error',
        'Failed to create notification: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return {'success': false, 'error': e.toString()};
    }
  }

  // ========== UPDATE NOTIFICATION ==========
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

      final response = await _service.updateNotification(
        notificationId: notificationId,
        title: title,
        message: message,
        type: type,
        priority: priority,
        audience: audience,
        channels: channels,
        sendAt: sendAt,
        expiresAt: expiresAt,
        status: status,
        isActive: isActive,
        actionText: actionText,
        actionUrl: actionUrl,
        data: data,
      );

      if (response['success'] == true) {
        Get.snackbar(
          'Success',
          'Notification updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh the notification details
        await loadNotificationDetail(notificationId);
        
        // Refresh the list
        await loadAgentNotifications(refresh: true);

        return {'success': true, 'notification': response['notification']};
      } else {
        throw Exception(response['message'] ?? 'Failed to update notification');
      }
    } catch (e) {
      print('🔥 Error updating notification: $e');

      Get.snackbar(
        'Error',
        'Failed to update notification: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return {'success': false, 'error': e.toString()};
    }
  }

  // ========== SCHEDULE NOTIFICATION ==========
  Future<Map<String, dynamic>> scheduleNotification({
    required String notificationId,
    required DateTime sendAt,
  }) async {
    try {
      print('📅 Scheduling notification: $notificationId');

      final response = await _service.scheduleNotification(
        notificationId: notificationId,
        sendAt: sendAt,
      );

      if (response['success'] == true) {
        Get.snackbar(
          'Success',
          'Notification scheduled successfully',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );

        // Refresh the notification details
        await loadNotificationDetail(notificationId);
        
        // Refresh the list
        await loadAgentNotifications(refresh: true);

        return {'success': true, 'notification': response['notification']};
      } else {
        throw Exception(response['message'] ?? 'Failed to schedule notification');
      }
    } catch (e) {
      print('🔥 Error scheduling notification: $e');

      Get.snackbar(
        'Error',
        'Failed to schedule notification: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return {'success': false, 'error': e.toString()};
    }
  }

  // ========== SEND NOTIFICATION IMMEDIATELY ==========
  Future<Map<String, dynamic>> sendNotificationImmediately({
    required String notificationId,
  }) async {
    try {
      print('🚀 Sending notification immediately: $notificationId');

      final response = await _service.sendNotificationImmediately(
        notificationId: notificationId,
      );

      if (response['success'] == true) {
        Get.snackbar(
          'Success',
          'Notification sent successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Refresh the notification details
        await loadNotificationDetail(notificationId);
        
        // Refresh the list
        await loadAgentNotifications(refresh: true);

        return {'success': true, 'notification': response['notification']};
      } else {
        throw Exception(response['message'] ?? 'Failed to send notification');
      }
    } catch (e) {
      print('🔥 Error sending notification: $e');

      Get.snackbar(
        'Error',
        'Failed to send notification: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return {'success': false, 'error': e.toString()};
    }
  }

  // ========== CANCEL NOTIFICATION ==========
  Future<Map<String, dynamic>> cancelNotification({
    required String notificationId,
  }) async {
    try {
      print('❌ Cancelling notification: $notificationId');

      final response = await _service.cancelNotification(
        notificationId: notificationId,
      );

      if (response['success'] == true) {
        Get.snackbar(
          'Success',
          'Notification cancelled successfully',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );

        // Refresh the notification details
        await loadNotificationDetail(notificationId);
        
        // Refresh the list
        await loadAgentNotifications(refresh: true);

        return {'success': true, 'notification': response['notification']};
      } else {
        throw Exception(response['message'] ?? 'Failed to cancel notification');
      }
    } catch (e) {
      print('🔥 Error cancelling notification: $e');

      Get.snackbar(
        'Error',
        'Failed to cancel notification: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return {'success': false, 'error': e.toString()};
    }
  }

  // ========== QUICK ACTION METHODS ==========

  // Quick update title and message
  Future<Map<String, dynamic>> quickUpdateNotification({
    required String notificationId,
    required String title,
    required String message,
  }) async {
    return await updateNotification(
      notificationId: notificationId,
      title: title,
      message: message,
    );
  }

  // Reschedule notification
  Future<Map<String, dynamic>> rescheduleNotification({
    required String notificationId,
    required DateTime newSendAt,
  }) async {
    return await scheduleNotification(
      notificationId: notificationId,
      sendAt: newSendAt,
    );
  }

  // Duplicate notification
  Future<Map<String, dynamic>> duplicateNotification({
    required String notificationId,
  }) async {
    try {
      // First, get the original notification
      final original = getNotificationByIdFromCache(notificationId);
      if (original == null) {
        throw Exception('Notification not found in cache');
      }

      // Create a new notification with same data
      final response = await createNewNotification(
        title: '${original['title']} (Copy)',
        message: original['message']?.toString() ?? '',
        type: original['type']?.toString() ?? 'info',
        audience: original['audience'] != null 
            ? Map<String, dynamic>.from(original['audience'] as Map)
            : _service.createAudience(),
        status: 'draft',
      );

      return response;
    } catch (e) {
      print('🔥 Error duplicating notification: $e');

      Get.snackbar(
        'Error',
        'Failed to duplicate notification: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      return {'success': false, 'error': e.toString()};
    }
  }

  // ========== FILTER METHODS ==========
  void applyFilters({
    String? status,
    String? type,
    String? priority,
  }) {
    if (status != null) filterStatus(status);
    if (type != null) filterType(type);
    if (priority != null) filterPriority(priority);

    loadAgentNotifications(refresh: true);
  }

  void clearFilters() {
    filterStatus('');
    filterType('');
    filterPriority('');

    loadAgentNotifications(refresh: true);
  }

  // ========== HELPER METHODS ==========
  List<dynamic> get draftNotifications {
    return agentNotifications.where((n) => n['status'] == 'draft').toList();
  }

  List<dynamic> get scheduledNotifications {
    return agentNotifications.where((n) => n['status'] == 'scheduled').toList();
  }

  List<dynamic> get sentNotifications {
    return agentNotifications.where((n) => n['status'] == 'sent').toList();
  }

  List<dynamic> get todayNotifications {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return agentNotifications.where((n) {
      final createdAt = n['created_at']?.toString();
      if (createdAt == null) return false;
      try {
        final createdDate = DateTime.parse(createdAt);
        final createdDateOnly =
            DateTime(createdDate.year, createdDate.month, createdDate.day);
        return createdDateOnly == today;
      } catch (e) {
        return false;
      }
    }).toList();
  }

  // Get notification by ID from cache
  Map<String, dynamic>? getNotificationByIdFromCache(String id) {
    try {
      return agentNotifications.firstWhereOrNull((n) => n['_id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Refresh notifications
  Future<void> refreshNotifications() async {
    await loadAgentNotifications(refresh: true);
  }

  // Load next page for pagination
  Future<void> loadNextPage() async {
    if (currentPage.value < totalPages.value && !isLoading.value) {
      await loadAgentNotifications(page: currentPage.value + 1);
    }
  }

  // Clear selected notification
  void clearSelectedNotification() {
    selectedNotification.clear();
    hasErrorDetail(false);
    errorMessageDetail('');
    update(['notification_detail']);
  }

  // Helper method to get notification stats safely
  Map<String, dynamic> get stats => notificationStats;

  // Helper method to get selected notification safely
  Map<String, dynamic> get selectedNotificationData {
    try {
      return Map<String, dynamic>.from(selectedNotification);
    } catch (e) {
      return {};
    }
  }

  // Check if selected notification is empty
  bool get isSelectedNotificationEmpty => selectedNotification.isEmpty;

  // ========== STATUS CHECK METHODS ==========
  bool canModifySelectedNotification() {
    if (selectedNotification.isEmpty) return false;
    return _service.canModifyNotification(selectedNotification);
  }

  bool canSendSelectedNotification() {
    if (selectedNotification.isEmpty) return false;
    return _service.canSendNotification(selectedNotification);
  }

  bool canCancelSelectedNotification() {
    if (selectedNotification.isEmpty) return false;
    return _service.canCancelNotification(selectedNotification);
  }

  String get selectedNotificationStatus {
    if (selectedNotification.isEmpty) return '';
    return selectedNotification['status']?.toString() ?? 'draft';
  }

  bool get isSelectedNotificationDraft {
    return selectedNotificationStatus == 'draft';
  }

  bool get isSelectedNotificationScheduled {
    return selectedNotificationStatus == 'scheduled';
  }

  bool get isSelectedNotificationSent {
    return selectedNotificationStatus == 'sent';
  }

  bool get isSelectedNotificationCancelled {
    return selectedNotificationStatus == 'cancelled';
  }
}