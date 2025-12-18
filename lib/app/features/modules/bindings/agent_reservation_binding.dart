// lib/app/features/modules/agent/bindings/agent_reservation_binding.dart
import 'package:get/get.dart';

import '../../../../../domain/repositories/reservation_repository.dart'; // Add this import
import '../agent/controllers/agent_customer_controller.dart';
import '../reservations/controllers/reservation_controller.dart';

class AgentReservationBinding extends Bindings {
  @override
  void dependencies() {
    // First, register the repository
    Get.lazyPut(() => ReservationRepository(), fenix: true);
    
    // Then register controllers that depend on the repository
    Get.lazyPut(() => ReservationController(), fenix: true);
    Get.lazyPut(() => AgentCustomerController(), fenix: true);
  }
}