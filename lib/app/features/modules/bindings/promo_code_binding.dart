import 'package:get/get.dart';
import '../../../../domain/repositories/promo_code_repository.dart';
import '../../data/services/api_service.dart';
import '../promo_code/controllers/promo_code_controller.dart';

class PromoCodeBinding implements Bindings {
  @override
  void dependencies() {
    // Initialize ApiService if not already done
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService());
    }
    
    // Initialize repository
    Get.lazyPut<PromoCodeRepository>(() => PromoCodeRepository());
    
    // Initialize controller
    Get.lazyPut<PromoCodeController>(() => PromoCodeController());
  }
}