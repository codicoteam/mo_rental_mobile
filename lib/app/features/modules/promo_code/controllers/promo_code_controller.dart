import 'package:get/get.dart';
import '../../../../../domain/repositories/promo_code_repository.dart';
import '../../../data/models/promo_code_model/promo_code_model.dart';

class PromoCodeController extends GetxController {
  final PromoCodeRepository _repository = PromoCodeRepository();
  
  final RxList<PromoCode> activePromoCodes = <PromoCode>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onReady() {
    super.onReady();
    fetchActivePromoCodes();
  }

  Future<void> fetchActivePromoCodes({DateTime? at, bool printToTerminal = true}) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final promoCodes = await _repository.getActivePromoCodes(
        at: at,
        printToTerminal: printToTerminal,
      );
      
      activePromoCodes.value = promoCodes;
    } catch (e) {
      error.value = e.toString();
      print('❌ Error in controller: $e');
    } finally {
      isLoading.value = false;
    }
  }

  PromoCode? getPromoCodeByCode(String code) {
    return activePromoCodes.firstWhereOrNull(
      (promo) => promo.code.toLowerCase() == code.toLowerCase(),
    );
  }

  List<PromoCode> getValidPromoCodesForAmount(double amount) {
    return activePromoCodes.where((promo) => promo.isValid).toList();
  }

  void refreshPromoCodes() {
    fetchActivePromoCodes();
  }
}