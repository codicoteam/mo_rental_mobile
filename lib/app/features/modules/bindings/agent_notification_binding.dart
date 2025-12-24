// lib/app/bindings/agent_notification_binding.dart
import 'package:get/get.dart';
import '../../data/services/agent_notification_service.dart';
import '../agent/controllers/agent_notification_controller.dart';

class AgentNotificationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AgentNotificationService>(() => AgentNotificationService(), fenix: true);
    Get.lazyPut<AgentNotificationController>(() => AgentNotificationController(), fenix: true);
  }
}