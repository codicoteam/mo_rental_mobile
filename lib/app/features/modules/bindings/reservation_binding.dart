import 'package:get/get.dart';

import '../../../../domain/repositories/reservation_repository.dart';
import '../reservations/controllers/reservation_controller.dart';

class ReservationBinding implements Bindings {
  @override
  void dependencies() {
    print('🔧 ==== RESERVATION BINDING CALLED ====');
    print('🔧 Time: ${DateTime.now()}');
    
    // Check if already registered
    print('🔧 Is ReservationRepository registered? ${Get.isRegistered<ReservationRepository>()}');
    print('🔧 Is ReservationController registered? ${Get.isRegistered<ReservationController>()}');
    
    // Initialize ReservationRepository
    Get.lazyPut<ReservationRepository>(
      () {
        print('📦 Creating ReservationRepository instance');
        return ReservationRepository();
      },
      fenix: true,
    );
    
    // Initialize ReservationController
    Get.lazyPut<ReservationController>(
      () {
        print('🎮 Creating ReservationController instance');
        final controller = ReservationController();
        print('🎮 Controller created: $controller');
        return controller;
      },
      fenix: true,
    );
    
    print('🔧 ==== RESERVATION BINDING COMPLETE ====');
  }
}