// lib/app/bindings/notification_binding.dart
import 'package:get/get.dart';
import '../../data/services/notification_service.dart';
import '../notifications/controllers/notification_controller.dart';

class NotificationBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationService>(() => NotificationService(), fenix: true);
    Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);
  }
}