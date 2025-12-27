// lib/modules/notifications/views/create_notification_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../data/services/agent_notification_service.dart';
import '../../../widgets/agent_sidebar/agent_sidebar_widget.dart';
import '../../agent/controllers/agent_notification_controller.dart';

class CreateNotificationScreen extends StatefulWidget {
  const CreateNotificationScreen({super.key});

  @override
  State<CreateNotificationScreen> createState() => _CreateNotificationScreenState();
}

class _CreateNotificationScreenState extends State<CreateNotificationScreen> 
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  late final TextEditingController _titleController;
  late final TextEditingController _messageController;
  late final TextEditingController _customerIdController;
  
  // FIX: Use regular strings instead of RxString for local state
  String _notificationType = 'customer';
  String _audienceType = 'all';

  @override
  void initState() {
    super.initState();
    
    // Initialize tab controller with 3 tabs
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize controllers
    _titleController = TextEditingController();
    _messageController = TextEditingController();
    _customerIdController = TextEditingController();
    
    // Initialize dependencies
    _initializeDependencies();
    
    // Listen for tab changes
    _tabController.addListener(_handleTabChange);
  }

  void _initializeDependencies() {
    if (!Get.isRegistered<AgentNotificationService>()) {
      Get.put(AgentNotificationService());
    }
    
    if (!Get.isRegistered<AgentNotificationController>()) {
      Get.put(AgentNotificationController());
    }
  }

  AgentNotificationController get _controller => Get.find<AgentNotificationController>();

  void _handleTabChange() {
    if (_tabController.index == 1) {
      // When switching to Manage tab, refresh notifications
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.loadAgentNotifications(refresh: true);
      });
    } else if (_tabController.index == 2) {
      // When switching to Details tab
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.update(['notification_detail']);
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _titleController.dispose();
    _messageController.dispose();
    _customerIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AgentSidebarWidget(
      initiallyOpen: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Notifications',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                icon: Icon(Iconsax.add_circle),
                text: 'Create',
              ),
              Tab(
                icon: Icon(Iconsax.document_text),
                text: 'Manage',
              ),
              Tab(
                icon: Icon(Iconsax.eye),
                text: 'Details',
              ),
            ],
            labelColor: Color(0xFF10B981),
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: Color(0xFF10B981),
          ),
          actions: [
            // Send button - only show on Create tab
            if (_tabController.index == 0)
              IconButton(
                onPressed: () => _sendNotification(),
                icon: Icon(Iconsax.send_2, color: Color(0xFF10B981)),
                tooltip: 'Send notification',
              )
            else if (_tabController.index == 1)
              // Add create button on Manage tab too
              Container(
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF10B981).withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(0),
                  icon: Icon(Iconsax.add, size: 16),
                  label: Text('Create'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // TAB 1: Create Notification
            _buildCreateTab(),
            
            // TAB 2: Manage Notifications List (Simplified version)
            _buildManageTab(),
            
            // TAB 3: Notification Details (Simplified version)
            _buildDetailsTab(),
          ],
        ),
      ),
    );
  }

  // TAB 1: Create Notification Form
  Widget _buildCreateTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notification Type Selection
          Text(
            'Notification Type',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTypeButton(
                  label: 'To Customer',
                  value: 'customer',
                  icon: Iconsax.profile_tick,
                  isSelected: _notificationType == 'customer',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _buildTypeButton(
                  label: 'System Alert',
                  value: 'system',
                  icon: Iconsax.message_text,
                  isSelected: _notificationType == 'system',
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Audience Selection (for system alerts)
          if (_notificationType == 'system') ...[
            Text(
              'Audience',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildAudienceButton(
                    label: 'All Users',
                    value: 'all',
                    isSelected: _audienceType == 'all',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildAudienceButton(
                    label: 'Customers',
                    value: 'customers',
                    isSelected: _audienceType == 'customers',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildAudienceButton(
                    label: 'Agents',
                    value: 'agents',
                    isSelected: _audienceType == 'agents',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],

          // Customer ID Input (for customer notifications)
          if (_notificationType == 'customer') ...[
            Text(
              'Customer ID',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _customerIdController,
              decoration: InputDecoration(
                hintText: 'Enter customer ID',
                prefixIcon: Icon(Iconsax.profile_circle),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              ),
            ),
            SizedBox(height: 20),
          ],

          // Title Input
          Text(
            'Title',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _titleController,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: 'Enter notification title',
              prefixIcon: Icon(Iconsax.text),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),

          SizedBox(height: 16),

          // Message Input
          Text(
            'Message',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _messageController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Enter notification message',
              prefixIcon: Icon(Iconsax.message),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),

          SizedBox(height: 24),

          // Send Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF10B981).withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _sendNotification(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Send Notification',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: Simplified Manage Tab
  Widget _buildManageTab() {
    return GetBuilder<AgentNotificationController>(
      builder: (controller) {
        if (controller.isLoading.value && controller.agentNotifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF10B981)),
                SizedBox(height: 16),
                Text(
                  'Loading notifications...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.hasError.value && controller.agentNotifications.isEmpty) {
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
                  'Failed to load notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => controller.loadAgentNotifications(refresh: true),
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

        return Column(
          children: [
            // Quick stats
            _buildQuickStats(controller),
            
            // Notifications list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.refreshNotifications(),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: controller.agentNotifications.length + 
                      (controller.isLoading.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.agentNotifications.length) {
                      if (controller.currentPage.value < controller.totalPages.value) {
                        controller.loadNextPage();
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: CircularProgressIndicator(color: Color(0xFF10B981)),
                          ),
                        );
                      }
                      return SizedBox();
                    }

                    final notification = controller.agentNotifications[index];
                    return _buildNotificationItem(notification, controller);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStats(AgentNotificationController controller) {
    final stats = controller.notificationStats;
    
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', '${stats['total'] ?? 0}'),
          _buildStatItem('Draft', '${stats['draft'] ?? 0}'),
          _buildStatItem('Sent', '${stats['sent'] ?? 0}'),
          _buildStatItem('Today', '${stats['today'] ?? 0}'),
        ],
      )
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF10B981),
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification, AgentNotificationController controller) {
    final status = notification['status']?.toString() ?? 'draft';
    final title = notification['title']?.toString() ?? 'No Title';
    final message = notification['message']?.toString() ?? '';
    final createdAt = notification['created_at']?.toString();

    Color statusColor;
    switch (status) {
      case 'draft':
        statusColor = Colors.orange;
        break;
      case 'scheduled':
        statusColor = Colors.blue;
        break;
      case 'sent':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Load details and switch to Details tab
          controller.loadNotificationDetail(notification['_id']?.toString() ?? '');
          _tabController.animateTo(2);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      status.substring(0, 1).toUpperCase() + status.substring(1),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    createdAt != null
                        ? 'Created: ${DateFormat('MMM dd, HH:mm').format(DateTime.parse(createdAt))}'
                        : '',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Quick view button
                      controller.loadNotificationDetail(notification['_id']?.toString() ?? '');
                      _tabController.animateTo(2);
                    },
                    icon: Icon(Iconsax.eye, size: 14),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    tooltip: 'View details',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 3: Simplified Details Tab
  Widget _buildDetailsTab() {
    return GetBuilder<AgentNotificationController>(
      id: 'notification_detail',
      builder: (controller) {
        if (controller.isLoadingDetail.value && controller.selectedNotification.isEmpty) {
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

        if (controller.hasErrorDetail.value) {
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
                  child: Text(
                    controller.errorMessageDetail.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => controller.loadNotificationDetail(
                    controller.selectedNotification['_id']?.toString() ?? '',
                  ),
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

        final notification = controller.selectedNotification;
        if (notification.isEmpty) {
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
                  'No Notification Selected',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Select a notification from the "Manage" tab\nto view its details here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _tabController.animateTo(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Go to Manage Tab'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF10B981).withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['title']?.toString() ?? 'No Title',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      notification['message']?.toString() ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16),

              // Details
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow('Status', notification['status']?.toString() ?? 'N/A'),
                    _buildDetailRow('Type', notification['type']?.toString() ?? 'N/A'),
                    _buildDetailRow('Priority', notification['priority']?.toString() ?? 'N/A'),
                    if (notification['created_at'] != null)
                      _buildDetailRow('Created', _formatDateTime(notification['created_at'].toString())),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 12,
              ),
            ),
          ),
        ],
      )
    );
  }

  String _formatDateTime(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy • HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildTypeButton({
    required String label,
    required String value,
    required IconData icon,
    required bool isSelected,
  }) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _notificationType = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF10B981) : Colors.grey.shade100,
        foregroundColor: isSelected ? Colors.white : Colors.grey.shade700,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceButton({
    required String label,
    required String value,
    required bool isSelected,
  }) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _audienceType = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFF6366F1) : Colors.grey.shade100,
        foregroundColor: isSelected ? Colors.white : Colors.grey.shade700,
        padding: EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11),
        textAlign: TextAlign.center,
      ),
    );
  }

  void _sendNotification() async {
    // Validate inputs
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (_notificationType == 'customer' && _customerIdController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter customer ID',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Create audience object
    Map<String, dynamic> audience;
    if (_notificationType == 'customer') {
      audience = {
        'scope': 'user',
        'user_id': _customerIdController.text,
        'roles': ['customer']
      };
    } else {
      audience = {
        'scope': 'role',
        'roles': _getAudienceList(),
      };
    }

    try {
      // Show loading
      Get.dialog(
        Center(
          child: CircularProgressIndicator(color: Color(0xFF10B981)),
        ),
        barrierDismissible: false,
      );

      // Send notification
      final result = await _controller.createNewNotification(
        title: _titleController.text,
        message: _messageController.text,
        type: _notificationType == 'customer' ? 'info' : 'system',
        audience: audience,
        status: 'sent',
      );

      // Close loading dialog
      Get.back();

      if (result['success'] == true) {
        // Clear form
        _titleController.clear();
        _messageController.clear();
        _customerIdController.clear();

        // Show success message
        Get.snackbar(
          'Success',
          'Notification sent successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );

        // Switch to Manage tab and refresh
        _tabController.animateTo(1);
        _controller.loadAgentNotifications(refresh: true);
      } else {
        Get.snackbar(
          'Error',
          result['error']?.toString() ?? 'Failed to send notification',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to send notification: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  List<String> _getAudienceList() {
    switch (_audienceType) {
      case 'all':
        return ['all'];
      case 'customers':
        return ['customers'];
      case 'agents':
        return ['agents'];
      default:
        return ['all'];
    }
  }
}