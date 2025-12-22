// lib/app/features/modules/agent/bindings/agent_reservation_binding.dart
import 'package:get/get.dart';
import '../../../../../domain/repositories/reservation_repository.dart';
import '../../data/services/payment_service.dart'; // Add this
import '../agent/controllers/agent_customer_controller.dart';
import '../reservations/controllers/reservation_controller.dart';
import '../payments/controllers/payment_controller.dart'; // Add this

class AgentReservationBinding extends Bindings {
  @override
  void dependencies() {
    // First, register the repository
    Get.lazyPut(() => ReservationRepository(), fenix: true);
    
    // Then register controllers that depend on the repository
    Get.lazyPut(() => ReservationController(), fenix: true);
    Get.lazyPut(() => AgentCustomerController(), fenix: true);
    
    // Add PaymentController and PaymentService
    Get.lazyPut(() => PaymentService(), fenix: true);
    Get.lazyPut(() => PaymentController(), fenix: true);
  }
}