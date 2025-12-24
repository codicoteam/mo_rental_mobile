// lib/features/modules/notifications/views/customer_notifications_screen.dart
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
    // Initialize controller if not already initialized
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController());
    }

    return CustomerSidebarWidget(
      initiallyOpen: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Notifications',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              )),
          actions: [
            // Add mark all as read button
            GetBuilder<NotificationController>(
              init: NotificationController(),
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
            return _buildBody(controller);
          },
        ),
      ),
    );
  }

  Widget _buildBody(NotificationController controller) {
    if (controller.isLoading.value) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF047BC1),
            ),
            SizedBox(height: 20),
            Text(
              'Loading notifications...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (controller.hasError.value) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.warning_2,
              size: 60,
              color: Colors.orange,
            ),
            SizedBox(height: 20),
            Text(
              'Could not load notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                controller.errorMessage.value
                        .contains('buildMineAudienceFilter')
                    ? 'Server is currently experiencing issues. Please try again later.'
                    : controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => controller.loadNotifications(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF047BC1),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (controller.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.notification,
              size: 80,
              color: Colors.grey.shade300,
            ),
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
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => controller.loadNotifications(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF047BC1),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with unread count - USING STATEFUL WIDGET
        _buildHeader(controller),

        // Notifications list - USING SEPARATE WIDGET
        Expanded(
          child: _buildNotificationsList(controller),
        ),
      ],
    );
  }

  // Make this a separate widget
  Widget _buildHeader(NotificationController controller) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Notifications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Stay updated with your bookings',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          if (controller.unreadCount.value > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.notification_bing,
                      size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    '${controller.unreadCount.value} unread',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Make this a separate widget
  Widget _buildNotificationsList(NotificationController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.loadNotifications(),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.notifications.length,
        itemBuilder: (context, index) {
          final notification = controller.notifications[index];
          return _buildNotificationCard(notification, controller);
        },
      ),
    );
  }

  Widget _buildNotificationCard(
      Map<String, dynamic> notification, NotificationController controller) {
    final isUnread = notification['read'] == false;
    final date = DateTime.tryParse(notification['created_at'] ?? '');
    final formattedDate = date != null
        ? DateFormat('MMM dd, yyyy • HH:mm').format(date)
        : 'Unknown date';

    // Different icons based on notification type
    final type = notification['type']?.toString() ?? 'system';

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
      case 'system':
        icon = Iconsax.info_circle;
        color = Color(0xFF6366F1);
        break;
      default:
        icon = Iconsax.notification;
        color = Color(0xFF6B7280);
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
                        notification['title']?.toString() ?? 'Notification',
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
                  notification['message']?.toString() ?? '',
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
                    Row(
                      children: [
                        // Notification type badge
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            type.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        // Mark as read button
                        if (isUnread)
                          InkWell(
                            onTap: () => controller.markAsRead(
                                notification['_id']?.toString() ?? ''),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border:
                                    Border.all(color: color.withOpacity(0.3)),
                              ),
                              child: Text(
                                'Mark as read',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
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
