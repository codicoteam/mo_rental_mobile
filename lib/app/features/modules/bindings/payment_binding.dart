import 'package:get/get.dart';
import '../../data/services/payment_service.dart';
import '../payments/controllers/payment_controller.dart';

class PaymentBinding implements Bindings {
  @override
  void dependencies() {
    // Initialize PaymentService
    Get.lazyPut<PaymentService>(() => PaymentService(), fenix: true);
    
    // Initialize PaymentController
    Get.lazyPut<PaymentController>(() => PaymentController(), fenix: true);
  }
}