// features/modules/branches/bindings/branch_binding.dart
import 'package:get/get.dart';

import '../../../../domain/repositories/branch_repository.dart';
import '../branches/controllers/branch_controller.dart';

class BranchBinding extends Bindings {
  @override
  void dependencies() {
    print('🔧 ==== BRANCH BINDING CALLED ====');
    print('🔧 Time: ${DateTime.now()}');
    print('🔧 Is BranchRepository registered? ${Get.isRegistered<BranchRepository>()}');
    print('🔧 Is BranchController registered? ${Get.isRegistered<BranchController>()}');
    
    Get.lazyPut<BranchRepository>(() => BranchRepository(), fenix: true);
    Get.lazyPut<BranchController>(() => BranchController(), fenix: true);
    
    print('🔧 ==== BRANCH BINDING COMPLETE ====');
  }
}