// lib/features/modules/notifications/views/agent_notification_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../widgets/agent_sidebar/agent_sidebar_widget.dart';
import '../controllers/agent_notification_controller.dart';

class AgentNotificationDetailScreen extends StatelessWidget {
  AgentNotificationDetailScreen({super.key});

  final AgentNotificationController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments as Map<String, dynamic>?;
    final notificationId = arguments?['notificationId'] as String?;

    if (notificationId != null) {
      _controller.loadNotificationDetail(notificationId);
    }

    return AgentSidebarWidget(
      initiallyOpen: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Notification Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
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
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          _buildHeader(notification),

          SizedBox(height: 20),

          // Title and message
          _buildContent(notification),

          SizedBox(height: 20),

          // Audience details
          _buildAudienceInfo(notification),

          SizedBox(height: 20),

          // Timing information
          _buildTimingInfo(notification),

          SizedBox(height: 20),

          // Additional data
          _buildAdditionalData(notification),

          SizedBox(height: 20),

          // Acknowledgements
          _buildAcknowledgements(notification),
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> notification) {
    final message = notification['message']?.toString() ?? '';
    final type = notification['type']?.toString() ?? 'info';

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.tag, size: 16, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text(
                'Type:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(width: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Message:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade800,
              height: 1.5,
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.people, size: 20, color: Color(0xFF6366F1)),
              SizedBox(width: 8),
              Text(
                'Audience Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.clock, size: 20, color: Color(0xFFF59E0B)),
              SizedBox(width: 8),
              Text(
                'Timing Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 12),
          _buildInfoRow('Priority:', priority.toUpperCase()),
          _buildInfoRow('Channels:', channels.join(', ').toUpperCase()),
          if (actionText != null) _buildInfoRow('Action Text:', actionText),
          if (actionUrl != null) _buildInfoRow('Action URL:', actionUrl),
          if (data != null && data.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              'Custom Data:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                data.toString(),
                style: TextStyle(
                  fontFamily: 'Monospace',
                  fontSize: 12,
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
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.tick_circle, size: 20, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text(
                'Acknowledgements (${acknowledgements.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...acknowledgements.map((ack) {
            final userId = ack['user_id']?.toString() ?? 'Unknown';
            final readAt = ack['read_at']?.toString();
            final actedAt = ack['acted_at']?.toString();
            final action = ack['action']?.toString();

            return Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
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
                    ),
                  ),
                  SizedBox(height: 4),
                  if (readAt != null)
                    Text('Read: ${_formatDateTime(readAt)}',
                        style: TextStyle(fontSize: 12)),
                  if (actedAt != null)
                    Text('Acted: ${_formatDateTime(actedAt)}',
                        style: TextStyle(fontSize: 12)),
                  if (action != null)
                    Text('Action: $action', style: TextStyle(fontSize: 12)),
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
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy • HH:mm:ss').format(date);
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
          SizedBox(height: 20),
          Text(
            'Loading notification details...',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
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
            size: 60,
            color: Colors.orange,
          ),
          SizedBox(height: 20),
          Text(
            'Failed to load notification',
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
              controller.errorMessageDetail.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => _refreshDetails(),
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

  Widget _buildEmptyState() {
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
            'No notification details',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Select a notification to view details',
            style: TextStyle(
              color: Colors.grey.shade500,
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
