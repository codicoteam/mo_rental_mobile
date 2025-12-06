import 'package:get/get.dart';
import '../../../../domain/repositories/chat_repository.dart';
import '../../data/services/api_service.dart';
import '../chat/controllers/chat_controller.dart';

class ChatBinding implements Bindings {
  @override
  void dependencies() {
    // Make sure ApiService is available
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }
    
    // Initialize ChatRepository
    Get.lazyPut<ChatRepository>(() => ChatRepository(), fenix: true);
    
    // Initialize ChatController
    Get.lazyPut<ChatController>(() => ChatController(), fenix: true);
  }
}