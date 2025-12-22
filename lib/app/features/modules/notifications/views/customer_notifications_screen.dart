// lib/modules/notifications/views/customer_notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../widgets/sidebar_widget/customer_sidebar_widget.dart';
import '../controllers/notification_controller.dart';

class CustomerNotificationsScreen extends StatelessWidget {
  const CustomerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomerSidebarWidget(
      initiallyOpen: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Notifications', style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          )),
          actions: [
            GetBuilder<NotificationController>(
              builder: (controller) {
                if (controller.unreadCount.value > 0) {
                  return IconButton(
                    onPressed: () => controller.markAllAsRead(),
                    icon: Icon(Iconsax.tick_circle),
                    tooltip: 'Mark all as read',
                  );
                }
                return SizedBox();
              },
            ),
          ],
        ),
        body: GetBuilder<NotificationController>(
          init: NotificationController(),
          builder: (controller) {
            if (controller.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }
            
            if (controller.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.notification, size: 80, color: Colors.grey.shade300),
                    SizedBox(height: 20),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'All your booking updates will appear here',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return RefreshIndicator(
              onRefresh: () => controller.loadNotifications(),
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: controller.notifications.length,
                itemBuilder: (context, index) {
                  final notification = controller.notifications[index];
                  return _buildNotificationCard(notification, controller);
                },
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildNotificationCard(Map<String, dynamic> notification, NotificationController controller) {
    final isUnread = notification['read'] == false;
    final date = DateTime.parse(notification['created_at']);
    final formattedDate = DateFormat('MMM dd, yyyy • HH:mm').format(date);
    final type = notification['type'] ?? 'system';
    
    // Different icons based on notification type
    IconData icon;
    Color color;
    
    switch (type) {
      case 'booking':
        icon = Iconsax.calendar;
        color = Color(0xFF047BC1);
        break;
      case 'payment':
        icon = Iconsax.dollar_circle;
        color = Color(0xFF10B981);
        break;
      case 'alert':
        icon = Iconsax.warning_2;
        color = Color(0xFFF59E0B);
        break;
      default:
        icon = Iconsax.notification;
        color = Color(0xFF6366F1);
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? color.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? color.withOpacity(0.3) : Colors.grey.shade200,
          width: isUnread ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification['title'] ?? 'Notification',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  notification['message'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (isUnread)
                      TextButton(
                        onPressed: () => controller.markAsRead(notification['_id']),
                        child: Text(
                          'Mark as read',
                          style: TextStyle(
                            fontSize: 12,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}