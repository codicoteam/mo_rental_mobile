// lib/features/modules/notifications/views/agent_notification_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../widgets/agent_sidebar/agent_sidebar_widget.dart';
import '../../../widgets/notification_action_buttons/notification_action_buttons.dart';
import '../controllers/agent_notification_controller.dart';

class AgentNotificationDetailScreen extends StatelessWidget {
  AgentNotificationDetailScreen({super.key});

 // Ensure controller is initialized
final AgentNotificationController _controller = Get.put(AgentNotificationController());

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final notificationId = arguments?['notificationId'] as String?;

    // Load details when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (notificationId != null && _controller.selectedNotification.isEmpty) {
        _controller.loadNotificationDetail(notificationId);
      }
    });

    return AgentSidebarWidget(
      initiallyOpen: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Obx(() => Text(
                _controller.selectedNotification['title']?.toString() ??
                    'Notification Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )),
          actions: [
            IconButton(
              onPressed: () => _refreshDetails(),
              icon: Icon(Iconsax.refresh, color: Color(0xFF10B981)),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: GetBuilder<AgentNotificationController>(
          id: 'notification_detail',
          builder: (controller) {
            return _buildBody(controller);
          },
        ),
      ),
    );
  }

  Widget _buildBody(AgentNotificationController controller) {
    if (controller.isLoadingDetail.value &&
        controller.selectedNotification.isEmpty) {
      return _buildLoadingState();
    }

    if (controller.hasErrorDetail.value) {
      return _buildErrorState(controller);
    }

    final notification = controller.selectedNotification;
    if (notification.isEmpty) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          _buildHeader(notification),

          SizedBox(height: 16),

          // Title and message
          _buildContent(notification),

          SizedBox(height: 16),

          // Audience details
          _buildAudienceInfo(notification),

          SizedBox(height: 16),

          // Timing information
          _buildTimingInfo(notification),

          SizedBox(height: 16),

          // Additional data
          if (notification['data'] != null ||
              notification['action_text'] != null ||
              notification['action_url'] != null)
            _buildAdditionalData(notification),

          if ((notification['acknowledgements'] as List?)?.isNotEmpty ??
              false) ...[
            SizedBox(height: 16),
            _buildAcknowledgements(notification),
          ],

          SizedBox(height: 20),

          // DEBUG: Test button to verify UI
          ElevatedButton(
            onPressed: () {
              print('🔍 DEBUG: Test button pressed');
              print('🔍 Notification ID: ${notification['_id']}');
              print('🔍 Notification status: ${notification['status']}');
              print('🔍 Notification title: ${notification['title']}');
              print('🔍 Full notification data: $notification');
            },
            child: Text('Debug: Check Data'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
            ),
          ),
// Add this in your _buildBody method, right before the action buttons:

          SizedBox(height: 20),

// DEBUG: Check controller and data
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DEBUG INFO:',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.orange)),
                SizedBox(height: 8),
                Text(
                    'Controller Registered: ${Get.isRegistered<AgentNotificationController>()}'),
                Text('Notification ID: ${notification['_id'] ?? "NULL"}'),
                Text(
                    'Notification Status: ${notification['status'] ?? "NULL"}'),
                Text('Notification Title: ${notification['title'] ?? "NULL"}'),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    print('=== AGENT NOTIFICATION CONTROLLER DEBUG ===');
                    print(
                        'Is Registered: ${Get.isRegistered<AgentNotificationController>()}');
                    print(
                        'Selected Notification Keys: ${notification.keys.toList()}');
                    print('Selected Notification: $notification');
                    print('Controller HashCode: ${_controller.hashCode}');
                  },
                  child: Text('Print Debug Info'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

// Simple test button to verify UI works
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                print(
                    'Simple button works! Notification ID: ${notification['_id']}');
                print('Controller: $_controller');
              },
              child: Text('Test Simple Button'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          SizedBox(height: 20),


          // Action buttons with Container to ensure visibility
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: NotificationActionButtons(
              notificationId: notification['_id']?.toString() ?? '',
              notification: notification,
            ),
          ),

          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> notification) {
    final status = notification['status']?.toString() ?? 'draft';
    final title = notification['title']?.toString() ?? 'No Title';

    Color statusColor;
    String statusText;

    switch (status) {
      case 'draft':
        statusColor = Colors.orange;
        statusText = 'DRAFT';
        break;
      case 'scheduled':
        statusColor = Colors.blue;
        statusText = 'SCHEDULED';
        break;
      case 'sent':
        statusColor = Colors.green;
        statusText = 'SENT';
        break;
      default:
        statusColor = Colors.grey;
        statusText = status.toUpperCase();
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 120),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> notification) {
    final message = notification['message']?.toString() ?? '';
    final type = notification['type']?.toString() ?? 'info';

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.tag, size: 14, color: Color(0xFF10B981)),
              SizedBox(width: 6),
              Text(
                'Type:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 4),
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 100),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Message:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 6),
          Container(
            width: double.infinity,
            child: Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceInfo(Map<String, dynamic> notification) {
    final audience = notification['audience'] ?? {};
    final scope = audience['scope']?.toString() ?? 'all';
    final userId = audience['user_id']?.toString();
    final roles = (audience['roles'] as List<dynamic>?)
            ?.map((r) => r.toString())
            .toList() ??
        [];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.people, size: 16, color: Color(0xFF6366F1)),
              SizedBox(width: 6),
              Text(
                'Audience Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          _buildInfoRow('Scope:', scope.toUpperCase()),
          if (userId != null) _buildInfoRow('User ID:', userId),
          if (roles.isNotEmpty)
            _buildInfoRow('Roles:', roles.join(', ').toUpperCase()),
          if (scope == 'user' && userId == null)
            _buildInfoRow('Note:', 'Specific user notification'),
        ],
      ),
    );
  }

  Widget _buildTimingInfo(Map<String, dynamic> notification) {
    final createdAt = notification['created_at']?.toString();
    final updatedAt = notification['updated_at']?.toString();
    final sendAt = notification['send_at']?.toString();
    final sentAt = notification['sent_at']?.toString();
    final expiresAt = notification['expires_at']?.toString();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.clock, size: 16, color: Color(0xFFF59E0B)),
              SizedBox(width: 6),
              Text(
                'Timing Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          if (createdAt != null)
            _buildInfoRow('Created:', _formatDateTime(createdAt)),
          if (updatedAt != null)
            _buildInfoRow('Last Updated:', _formatDateTime(updatedAt)),
          if (sendAt != null)
            _buildInfoRow('Scheduled For:', _formatDateTime(sendAt)),
          if (sentAt != null)
            _buildInfoRow('Sent At:', _formatDateTime(sentAt)),
          if (expiresAt != null)
            _buildInfoRow('Expires At:', _formatDateTime(expiresAt)),
        ],
      ),
    );
  }

  Widget _buildAdditionalData(Map<String, dynamic> notification) {
    final data = notification['data'] as Map<String, dynamic>?;
    final actionText = notification['action_text']?.toString();
    final actionUrl = notification['action_url']?.toString();
    final priority = notification['priority']?.toString() ?? 'normal';
    final channels = (notification['channels'] as List<dynamic>?)
            ?.map((c) => c.toString())
            .toList() ??
        ['in_app'];

    if (data == null && actionText == null && actionUrl == null) {
      return SizedBox();
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 10),
          _buildInfoRow('Priority:', priority.toUpperCase()),
          _buildInfoRow('Channels:', channels.join(', ').toUpperCase()),
          if (actionText != null) _buildInfoRow('Action Text:', actionText),
          if (actionUrl != null) _buildInfoRow('Action URL:', actionUrl),
          if (data != null && data.isNotEmpty) ...[
            SizedBox(height: 6),
            Text(
              'Custom Data:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SelectableText(
                data.toString(),
                style: TextStyle(
                  fontFamily: 'Monospace',
                  fontSize: 10,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAcknowledgements(Map<String, dynamic> notification) {
    final acknowledgements =
        (notification['acknowledgements'] as List<dynamic>?) ?? [];

    if (acknowledgements.isEmpty) {
      return SizedBox();
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.tick_circle, size: 16, color: Color(0xFF10B981)),
              SizedBox(width: 6),
              Text(
                'Acknowledgements (${acknowledgements.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ...acknowledgements.map((ack) {
            final userId = ack['user_id']?.toString() ?? 'Unknown';
            final readAt = ack['read_at']?.toString();
            final actedAt = ack['acted_at']?.toString();
            final action = ack['action']?.toString();

            return Container(
              margin: EdgeInsets.only(bottom: 6),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'User: $userId',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2),
                  if (readAt != null)
                    Text('Read: ${_formatDateTime(readAt)}',
                        style: TextStyle(fontSize: 10)),
                  if (actedAt != null)
                    Text('Acted: ${_formatDateTime(actedAt)}',
                        style: TextStyle(fontSize: 10)),
                  if (action != null)
                    Text('Action: $action', style: TextStyle(fontSize: 10)),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              child: SelectableText(
                value,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ));
  }

  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy • HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF10B981)),
          SizedBox(height: 16),
          Text(
            'Loading notification details...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(AgentNotificationController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.warning_2,
            size: 50,
            color: Colors.orange,
          ),
          SizedBox(height: 16),
          Text(
            'Failed to load notification',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Obx(() => Text(
                  controller.errorMessageDetail.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                )),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _refreshDetails(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF10B981),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.notification,
            size: 60,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16),
          Text(
            'No notification details',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Select a notification to view details',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _refreshDetails() {
    final notification = _controller.selectedNotification;
    if (notification.isNotEmpty) {
      final notificationId = notification['_id']?.toString();
      if (notificationId != null) {
        _controller.loadNotificationDetail(notificationId);
      }
    }
  }
}
