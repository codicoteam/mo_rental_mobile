// lib/features/modules/notifications/controllers/agent_notification_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/agent_notification_service.dart';

class AgentNotificationController extends GetxController {
  final AgentNotificationService _service = Get.find();

  // State for notification list
  final RxList<dynamic> agentNotifications = <dynamic>[].obs;
  final RxMap<String, dynamic> notificationStats = <String, dynamic>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;

  // State for single notification
  final RxMap<String, dynamic> selectedNotification = <String, dynamic>{}.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxBool hasErrorDetail = false.obs;
  final RxString errorMessageDetail = ''.obs;

  // Filter states
  final RxString filterStatus =
      ''.obs; // 'draft', 'scheduled', 'sent', or empty for all
  final RxString filterType = ''.obs;
  final RxString filterPriority = ''.obs;

  @override
  void onInit() {
    super.onInit();
    print('🎯 AgentNotificationController initialized');
    loadAgentNotifications();
  }

  // ========== LOAD ALL AGENT NOTIFICATIONS ==========
  Future<void> loadAgentNotifications(
      {int page = 1, bool refresh = false}) async {
    try {
      print('🔄 Loading agent notifications...');
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      if (refresh) {
        currentPage.value = 1;
      }

      final response = await _service.getAllNotifications(
        status: filterStatus.value.isEmpty ? null : filterStatus.value,
        type: filterType.value.isEmpty ? null : filterType.value,
        priority: filterPriority.value.isEmpty ? null : filterPriority.value,
        page: page,
        limit: 20,
      );

      if (response['success'] == true) {
        if (page == 1) {
          agentNotifications.value = response['items'] ?? [];
        } else {
          agentNotifications.addAll(response['items'] ?? []);
        }

        currentPage.value = response['page'] ?? 1;
        totalPages.value = response['pages'] ?? 1;
        totalItems.value = response['total'] ?? 0;

        // Calculate stats
        notificationStats.value = _service.calculateStats(agentNotifications);

        print('✅ Loaded ${agentNotifications.length} notifications');
        // ignore: invalid_use_of_protected_member
        print('📊 Stats: ${notificationStats.value}');
        print('📊 Page: ${currentPage.value}/${totalPages.value}');
      } else {
        hasError.value = true;
        errorMessage.value =
            response['message'] ?? 'Failed to load notifications';
      }
    } catch (e) {
      print('🔥 Error loading agent notifications: $e');
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
    }
  }

  // ========== LOAD SINGLE NOTIFICATION DETAILS ==========
  Future<void> loadNotificationDetail(String notificationId) async {
    try {
      print('🔍 Loading notification detail: $notificationId');
      isLoadingDetail.value = true;
      hasErrorDetail.value = false;
      errorMessageDetail.value = '';

      final response = await _service.getNotificationById(notificationId);

      if (response['success'] == true) {
        selectedNotification.value = response['notification'] ?? {};
        print('✅ Loaded notification detail: ${selectedNotification['title']}');
      } else {
        hasErrorDetail.value = true;
        errorMessageDetail.value =
            response['message'] ?? 'Failed to load notification';
      }
    } catch (e) {
      print('🔥 Error loading notification detail: $e');
      hasErrorDetail.value = true;
      errorMessageDetail.value = e.toString();
    } finally {
      isLoadingDetail.value = false;
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

  // ========== FILTER METHODS ==========
  void applyFilters({
    String? status,
    String? type,
    String? priority,
  }) {
    if (status != null) filterStatus.value = status;
    if (type != null) filterType.value = type;
    if (priority != null) filterPriority.value = priority;

    loadAgentNotifications(refresh: true);
  }

  void clearFilters() {
    filterStatus.value = '';
    filterType.value = '';
    filterPriority.value = '';

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
    return agentNotifications.firstWhereOrNull((n) => n['_id'] == id);
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
}
