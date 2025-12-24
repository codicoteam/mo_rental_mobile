// lib/features/modules/notifications/views/agent_notification_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../widgets/agent_sidebar/agent_sidebar_widget.dart';
import '../controllers/agent_notification_controller.dart';
import 'agent_notification_detail_screen.dart';

class AgentNotificationListScreen extends StatelessWidget {
  const AgentNotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    if (!Get.isRegistered<AgentNotificationController>()) {
      Get.put(AgentNotificationController());
    }

    return AgentSidebarWidget(
      initiallyOpen: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Notification Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              )),
          actions: [
            // Filter button
            IconButton(
              onPressed: () => _showFilterDialog(),
              icon: Icon(Iconsax.filter, color: Color(0xFF10B981)),
              tooltip: 'Filter notifications',
            ),
            // Create button
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
                onPressed: () => Get.toNamed('/notifications/create'),
                icon: Icon(Iconsax.add, size: 18),
                label: Text('Create'),
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
        body: GetBuilder<AgentNotificationController>(
          builder: (controller) {
            return _buildBody(controller);
          },
        ),
      ),
    );
  }

  Widget _buildBody(AgentNotificationController controller) {
    if (controller.isLoading.value && controller.agentNotifications.isEmpty) {
      return _buildLoadingState();
    }

    if (controller.hasError.value && controller.agentNotifications.isEmpty) {
      return _buildErrorState(controller);
    }

    return Column(
      children: [
        // Stats header
        _buildStatsHeader(controller),

        // Filter chips (if any filter applied)
        _buildFilterChips(controller),

        // Notifications list
        Expanded(
          child: _buildNotificationsList(controller),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF10B981)),
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
            'Failed to load notifications',
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
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: () => controller.loadAgentNotifications(refresh: true),
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

  Widget _buildStatsHeader(AgentNotificationController controller) {
    final stats = controller.notificationStats;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              _buildStatCard(
                title: 'Total',
                value: '${stats['total'] ?? 0}',
                color: Colors.white,
              ),
              SizedBox(width: 10),
              _buildStatCard(
                title: 'Draft',
                value: '${stats['draft'] ?? 0}',
                color: Colors.white,
              ),
              SizedBox(width: 10),
              _buildStatCard(
                title: 'Scheduled',
                value: '${stats['scheduled'] ?? 0}',
                color: Colors.white,
              ),
              SizedBox(width: 10),
              _buildStatCard(
                title: 'Sent',
                value: '${stats['sent'] ?? 0}',
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(AgentNotificationController controller) {
    final hasFilters = controller.filterStatus.value.isNotEmpty ||
        controller.filterType.value.isNotEmpty ||
        controller.filterPriority.value.isNotEmpty;

    if (!hasFilters) return SizedBox();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (controller.filterStatus.value.isNotEmpty)
            Chip(
              label: Text('Status: ${controller.filterStatus.value}'),
              deleteIcon: Icon(Iconsax.close_circle, size: 14),
              onDeleted: () => controller.applyFilters(status: ''),
            ),
          if (controller.filterType.value.isNotEmpty)
            Chip(
              label: Text('Type: ${controller.filterType.value}'),
              deleteIcon: Icon(Iconsax.close_circle, size: 14),
              onDeleted: () => controller.applyFilters(type: ''),
            ),
          if (controller.filterPriority.value.isNotEmpty)
            Chip(
              label: Text('Priority: ${controller.filterPriority.value}'),
              deleteIcon: Icon(Iconsax.close_circle, size: 14),
              onDeleted: () => controller.applyFilters(priority: ''),
            ),
          if (hasFilters)
            TextButton(
              onPressed: () => controller.clearFilters(),
              child:
                  Text('Clear All', style: TextStyle(color: Color(0xFF10B981))),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(AgentNotificationController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.refreshNotifications(),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: controller.agentNotifications.length +
            (controller.isLoading.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.agentNotifications.length) {
            if (controller.currentPage.value < controller.totalPages.value) {
              controller.loadNextPage();
              return _buildLoadingMore();
            }
            return SizedBox();
          }

          final notification = controller.agentNotifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final status = notification['status']?.toString() ?? 'draft';
    final type = notification['type']?.toString() ?? 'info';
    final title = notification['title']?.toString() ?? 'No Title';
    final message = notification['message']?.toString() ?? '';
    final createdAt = notification['created_at']?.toString();
    final audience = notification['audience']?['scope']?.toString() ?? 'all';

    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case 'draft':
        statusColor = Colors.orange;
        statusIcon = Iconsax.edit;
        break;
      case 'scheduled':
        statusColor = Colors.blue;
        statusIcon = Iconsax.clock;
        break;
      case 'sent':
        statusColor = Colors.green;
        statusIcon = Iconsax.tick_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Iconsax.info_circle;
    }

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => Get.to(
          () => AgentNotificationDetailScreen(),
          arguments: {'notificationId': notification['_id']},
        ),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusColor),
                        SizedBox(width: 4),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Iconsax.tag, size: 14, color: Colors.grey.shade500),
                      SizedBox(width: 4),
                      Text(
                        type.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(width: 12),
                      Icon(Iconsax.people,
                          size: 14, color: Colors.grey.shade500),
                      SizedBox(width: 4),
                      Text(
                        audience.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    createdAt != null
                        ? DateFormat('MMM dd, HH:mm')
                            .format(DateTime.parse(createdAt))
                        : '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
      {required String title, required String value, required Color color}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                fontSize: 20,
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
      ),
    );
  }

  Widget _buildLoadingMore() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: CircularProgressIndicator(color: Color(0xFF10B981)),
      ),
    );
  }

  void _showFilterDialog() {
    final controller = Get.find<AgentNotificationController>();

    String selectedStatus = controller.filterStatus.value;
    String selectedType = controller.filterType.value;
    String selectedPriority = controller.filterPriority.value;

    Get.dialog(
      AlertDialog(
        title: Text('Filter Notifications'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status filter
              DropdownButtonFormField<String>(
                value: selectedStatus.isEmpty ? null : selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: '', child: Text('All Status')),
                  DropdownMenuItem(value: 'draft', child: Text('Draft')),
                  DropdownMenuItem(
                      value: 'scheduled', child: Text('Scheduled')),
                  DropdownMenuItem(value: 'sent', child: Text('Sent')),
                ],
                onChanged: (value) => selectedStatus = value ?? '',
              ),

              SizedBox(height: 16),

              // Type filter
              DropdownButtonFormField<String>(
                value: selectedType.isEmpty ? null : selectedType,
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: '', child: Text('All Types')),
                  DropdownMenuItem(value: 'info', child: Text('Info')),
                  DropdownMenuItem(value: 'payment', child: Text('Payment')),
                  DropdownMenuItem(value: 'alert', child: Text('Alert')),
                  DropdownMenuItem(value: 'system', child: Text('System')),
                ],
                onChanged: (value) => selectedType = value ?? '',
              ),

              SizedBox(height: 16),

              // Priority filter
              DropdownButtonFormField<String>(
                value: selectedPriority.isEmpty ? null : selectedPriority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: '', child: Text('All Priorities')),
                  DropdownMenuItem(value: 'normal', child: Text('Normal')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                ],
                onChanged: (value) => selectedPriority = value ?? '',
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
            onPressed: () {
              controller.applyFilters(
                status: selectedStatus,
                type: selectedType,
                priority: selectedPriority,
              );
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            child: Text('Apply Filters'),
          ),
        ],
      ),
    );
  }
}
