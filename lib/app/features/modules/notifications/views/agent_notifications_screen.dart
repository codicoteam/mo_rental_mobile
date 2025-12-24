// lib/features/modules/notifications/views/agent_notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../widgets/agent_sidebar/agent_sidebar_widget.dart';
import '../controllers/notification_controller.dart';
import 'create_notification_screen.dart';

class AgentNotificationsScreen extends StatelessWidget {
  const AgentNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already initialized
    if (!Get.isRegistered<NotificationController>()) {
      Get.put(NotificationController());
    }

    return AgentSidebarWidget(
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
            // Send notification FAB for agents
            Container(
              margin: EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF10B981).withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => Get.to(() => CreateNotificationScreen()),
                icon: Icon(Iconsax.send_2, size: 18),
                label: Text('Send'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
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

// In AgentNotificationsScreen's _buildBody method:
  Widget _buildBody(NotificationController controller) {
    print('🔄 Building UI state');
    print('📊 isLoading: ${controller.isLoading.value}');
    print('📊 hasError: ${controller.hasError.value}');
    print('📊 errorMessage: ${controller.errorMessage.value}');
    print('📊 notifications length: ${controller.notifications.length}');

    if (controller.isLoading.value) {
      print('📱 Showing loading state');
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF10B981),
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

    // Check error state FIRST
    if (controller.hasError.value) {
      print('📱 Showing error state: ${controller.errorMessage.value}');
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
                backgroundColor: Color(0xFF10B981),
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

    // Check empty state
    if (controller.notifications.isEmpty) {
      print('📱 Showing empty state');
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
              'You\'ll see notifications here when you have them',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    print(
        '📱 Showing notifications list with ${controller.notifications.length} items');
    return Column(
      children: [
        // Header with stats
        _buildStatsHeader(controller),

        // Notifications list
        Expanded(
          child: _buildNotificationsList(controller),
        ),
      ],
    );
  }

  // Make this a separate widget
  Widget _buildStatsHeader(NotificationController controller) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF0EA5E9)],
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatCard(
                      title: 'Total',
                      value: controller.notifications.length.toString(),
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    _buildStatCard(
                      title: 'Unread',
                      value: controller.unreadCount.value.toString(),
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    _buildStatCard(
                      title: 'Today',
                      value: controller.todaysNotifications.length.toString(),
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (controller.unreadCount.value > 0)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: IconButton(
                onPressed: () => controller.markAllAsRead(),
                icon: Icon(Iconsax.tick_circle, color: Colors.white),
                tooltip: 'Mark all as read',
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

  Widget _buildStatCard(
      {required String title, required String value, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
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

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? Color(0xFF10B981).withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread
              ? Color(0xFF10B981).withOpacity(0.3)
              : Colors.grey.shade200,
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
          // Status indicator
          Container(
            width: 8,
            height: 8,
            margin: EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              color: isUnread ? Color(0xFF10B981) : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),

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
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'NEW',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8),
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
                        if (notification['type'] == 'system')
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(0xFF6366F1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'SYSTEM',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF6366F1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        SizedBox(width: 8),
                        if (isUnread)
                          IconButton(
                            onPressed: () => controller.markAsRead(
                                notification['_id']?.toString() ?? ''),
                            icon: Icon(Iconsax.tick_circle,
                                size: 20, color: Color(0xFF10B981)),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
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
