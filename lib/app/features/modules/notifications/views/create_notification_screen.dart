// lib/modules/notifications/views/create_notification_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../widgets/agent_sidebar/agent_sidebar_widget.dart';
import '../controllers/notification_controller.dart';

class CreateNotificationScreen extends StatelessWidget {
  CreateNotificationScreen({super.key});

  final NotificationController _controller = Get.find();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _customerIdController = TextEditingController();
  final RxString _notificationType = 'customer'.obs;
  final RxString _audienceType = 'specific'.obs;

  @override
  Widget build(BuildContext context) {
    return AgentSidebarWidget(
      initiallyOpen: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Send Notification', style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          )),
          actions: [
            IconButton(
              onPressed: () => _sendNotification(),
              icon: Icon(Iconsax.send_2, color: Color(0xFF10B981)),
              tooltip: 'Send notification',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20),
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
              Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      label: 'To Customer',
                      value: 'customer',
                      icon: Iconsax.profile_tick,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildTypeButton(
                      label: 'System Alert',
                      value: 'system',
                      icon: Iconsax.message_text, // Changed from broadcast
                    ),
                  ),
                ],
              )),
              
              SizedBox(height: 30),
              
              // Audience Selection (for system alerts)
              Obx(() => _notificationType.value == 'system' ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildAudienceButton(
                          label: 'Customers',
                          value: 'customers',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: _buildAudienceButton(
                          label: 'Agents',
                          value: 'agents',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ) : SizedBox()),
              
              // Customer ID Input (for customer notifications)
              Obx(() => _notificationType.value == 'customer' ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ) : SizedBox()),
              
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
                  prefixIcon: Icon(Iconsax.text), // Changed from title
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              
              SizedBox(height: 20),
              
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
                ),
              ),
              
              SizedBox(height: 30),
              
              // Send Button
              Container(
                width: double.infinity,
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
                child: ElevatedButton(
                  onPressed: () => _sendNotification(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
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
        ),
      ),
    );
  }
  
  Widget _buildTypeButton({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Obx(() => ElevatedButton(
      onPressed: () => _notificationType.value = value,
      style: ElevatedButton.styleFrom(
        backgroundColor: _notificationType.value == value
            ? Color(0xFF10B981)
            : Colors.grey.shade100,
        foregroundColor: _notificationType.value == value
            ? Colors.white
            : Colors.grey.shade700,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          SizedBox(height: 8),
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    ));
  }
  
  Widget _buildAudienceButton({
    required String label,
    required String value,
  }) {
    return Obx(() => ElevatedButton(
      onPressed: () => _audienceType.value = value,
      style: ElevatedButton.styleFrom(
        backgroundColor: _audienceType.value == value
            ? Color(0xFF6366F1)
            : Colors.grey.shade100,
        foregroundColor: _audienceType.value == value
            ? Colors.white
            : Colors.grey.shade700,
        padding: EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label, style: TextStyle(fontSize: 12)),
    ));
  }
  
  void _sendNotification() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill in all fields');
      return;
    }
    
    if (_notificationType.value == 'customer' && _customerIdController.text.isEmpty) {
      Get.snackbar('Error', 'Please enter customer ID');
      return;
    }
    
    if (_notificationType.value == 'customer') {
      await _controller.sendCustomerNotification(
        customerId: _customerIdController.text,
        title: _titleController.text,
        message: _messageController.text,
      );
    } else {
      // For system notifications
      await _controller.createSystemNotification(
        title: _titleController.text,
        message: _messageController.text,
        audience: _getAudienceList(),
      );
    }
    
    Get.back();
  }
  
  List<String> _getAudienceList() {
    switch (_audienceType.value) {
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