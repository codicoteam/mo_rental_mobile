import 'package:get/get.dart';
import '../../data/services/api_service.dart';
import '../../data/services/rate_plan_service.dart';
import '../rate_plans/controllers/rate_plan_controller.dart';

class RatePlanBinding extends Bindings {
  @override
  void dependencies() {
    print('📦 Initializing RatePlanBinding dependencies');
    
    // Ensure ApiService is initialized first
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }
    
    // Then RatePlanService
    if (!Get.isRegistered<RatePlanService>()) {
      Get.put(RatePlanService(), permanent: true);
    }
    
    // Finally RatePlanController
    if (!Get.isRegistered<RatePlanController>()) {
      Get.put(RatePlanController(), permanent: true);
    }
  }
}