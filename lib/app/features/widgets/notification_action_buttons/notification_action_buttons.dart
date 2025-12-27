import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

// CORRECT IMPORTS FOR YOUR PROJECT STRUCTURE
import '../../../../../domain/repositories/notification_repository.dart';
// FIX THIS IMPORT - Use the exact path from your controller
import '../../../../app/features/modules/agent/controllers/agent_notification_controller.dart';

class NotificationActionButtons extends StatelessWidget {
  final String notificationId;
  final Map<String, dynamic> notification;

  const NotificationActionButtons({
    super.key,
    required this.notificationId,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    // Create repository instance
    final repository = NotificationRepository();
    final status = notification['status']?.toString() ?? 'draft';

    return Column(
      children: [
        if (status == 'draft' || status == 'scheduled') ...[
          _buildActionButton(
            icon: Iconsax.edit,
            label: 'Edit',
            color: Colors.blue,
            onTap: () =>
                _showEditDialog(repository, notificationId, notification),
          ),
          SizedBox(height: 8),
        ],
        if (status == 'draft') ...[
          _buildActionButton(
            icon: Iconsax.calendar,
            label: 'Schedule',
            color: Colors.purple,
            onTap: () => _showScheduleDialog(repository, notificationId),
          ),
          SizedBox(height: 8),
        ],
        if (status == 'draft' || status == 'scheduled') ...[
          _buildActionButton(
            icon: Iconsax.send_2,
            label: 'Send Now',
            color: Colors.green,
            onTap: () => _sendNow(repository, notificationId),
          ),
          SizedBox(height: 8),
        ],
        if (status == 'draft' || status == 'scheduled') ...[
          _buildActionButton(
            icon: Iconsax.close_circle,
            label: 'Cancel',
            color: Colors.orange,
            onTap: () => _cancelNotification(repository, notificationId),
          ),
          SizedBox(height: 8),
        ],
        _buildActionButton(
          icon: Iconsax.copy,
          label: 'Duplicate',
          color: Colors.indigo,
          onTap: () => _duplicateNotification(repository, notificationId),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    );
  }

  void _showEditDialog(NotificationRepository repository, String notificationId,
      Map<String, dynamic> notification) {
    final titleController =
        TextEditingController(text: notification['title']?.toString() ?? '');
    final messageController =
        TextEditingController(text: notification['message']?.toString() ?? '');

    Get.dialog(
      AlertDialog(
        title: Text('Edit Notification'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final result = await repository.updateNotification(
                notificationId: notificationId,
                title: titleController.text,
                message: messageController.text,
              );

              if (result['success'] == true) {
                Get.snackbar(
                  'Success',
                  'Notification updated successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
                // Refresh the screen
                if (Get.isRegistered<AgentNotificationController>()) {
                  Get.find<AgentNotificationController>()
                      .loadNotificationDetail(notificationId);
                }
              } else {
                Get.snackbar(
                  'Error',
                  result['message']?.toString() ??
                      'Failed to update notification',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(
      NotificationRepository repository, String notificationId) {
    DateTime selectedDate = DateTime.now().add(Duration(days: 1));
    TimeOfDay selectedTime = TimeOfDay.now();

    Get.dialog(
      AlertDialog(
        title: Text('Schedule Notification'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select date:'),
              ElevatedButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: Get.context!,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (date != null) selectedDate = date;
                },
                child: Text('Pick Date'),
              ),
              SizedBox(height: 16),
              Text('Select time:'),
              ElevatedButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: Get.context!,
                    initialTime: selectedTime,
                  );
                  if (time != null) selectedTime = time;
                },
                child: Text('Pick Time'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final sendAt = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              ).toUtc();

              Get.back();

              final result = await repository.scheduleNotification(
                notificationId: notificationId,
                sendAt: sendAt.toIso8601String(),
              );

              if (result['success'] == true) {
                Get.snackbar(
                  'Success',
                  'Notification scheduled successfully',
                  backgroundColor: Colors.blue,
                  colorText: Colors.white,
                );
                // Refresh the screen
                if (Get.isRegistered<AgentNotificationController>()) {
                  Get.find<AgentNotificationController>()
                      .loadNotificationDetail(notificationId);
                }
              } else {
                Get.snackbar(
                  'Error',
                  result['message']?.toString() ??
                      'Failed to schedule notification',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _sendNow(
      NotificationRepository repository, String notificationId) async {
    Get.dialog(
      AlertDialog(
        title: Text('Send Notification'),
        content: Text(
            'Are you sure you want to send this notification immediately?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final result = await repository.sendNotificationImmediately(
                notificationId: notificationId,
              );

              if (result['success'] == true) {
                Get.snackbar(
                  'Success',
                  'Notification sent successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
                // Refresh the screen
                if (Get.isRegistered<AgentNotificationController>()) {
                  Get.find<AgentNotificationController>()
                      .loadNotificationDetail(notificationId);
                }
              } else {
                Get.snackbar(
                  'Error',
                  result['message']?.toString() ??
                      'Failed to send notification',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Send Now'),
          ),
        ],
      ),
    );
  }

  void _cancelNotification(
      NotificationRepository repository, String notificationId) async {
    Get.dialog(
      AlertDialog(
        title: Text('Cancel Notification'),
        content: Text(
            'Are you sure you want to cancel this notification? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final result = await repository.cancelNotification(
                notificationId: notificationId,
              );

              if (result['success'] == true) {
                Get.snackbar(
                  'Success',
                  'Notification cancelled successfully',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                // Refresh the screen
                if (Get.isRegistered<AgentNotificationController>()) {
                  Get.find<AgentNotificationController>()
                      .loadNotificationDetail(notificationId);
                }
              } else {
                Get.snackbar(
                  'Error',
                  result['message']?.toString() ??
                      'Failed to cancel notification',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _duplicateNotification(
      NotificationRepository repository, String notificationId) async {
    final result = await repository.duplicateNotification(
      notificationId: notificationId,
    );

    if (result['success'] == true) {
      Get.snackbar(
        'Success',
        'Notification duplicated successfully',
        backgroundColor: Colors.indigo,
        colorText: Colors.white,
      );
      // Refresh notifications list
      if (Get.isRegistered<AgentNotificationController>()) {
        Get.find<AgentNotificationController>()
            .loadAgentNotifications(refresh: true);
      }
    } else {
      Get.snackbar(
        'Error',
        result['message']?.toString() ?? 'Failed to duplicate notification',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
