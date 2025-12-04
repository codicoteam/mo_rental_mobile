import 'package:get/get.dart';
import '../features/data/services/api_service.dart';
import '../features/modules/auth/controllers/auth_controller.dart';
import '../features/modules/welcome_screens/onboarding_screens/controllers/onboarding_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService());
   

     Get.lazyPut<OnboardingController>(() => OnboardingController());
    Get.lazyPut<AuthController>(() => AuthController());
  }
}