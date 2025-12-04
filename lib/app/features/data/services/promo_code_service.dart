import '../models/promo_code_model/promo_code_model.dart';

class PromoCodeService {
  static String? validatePromoCode(String code, List<PromoCode> activePromoCodes) {
    final promo = activePromoCodes.firstWhere(
      (p) => p.code.toLowerCase() == code.toLowerCase(),
      orElse: () => PromoCode(
        id: '',
        code: '',
        type: '',
        value: 0,
        isActive: false,
      ),
    );

    if (promo.code.isEmpty) return 'Invalid promo code';
    if (!promo.isActive) return 'Promo code is not active';
    if (!promo.isValid) return 'Promo code has expired or reached usage limit';
    
    return null;
  }

  static double applyPromoCode(PromoCode promo, double originalAmount) {
    if (!promo.isValid) return originalAmount;
    
    final discount = promo.calculateDiscount(originalAmount);
    return originalAmount - discount;
  }

  static Map<String, dynamic> getPromoCodeSummary(List<PromoCode> promoCodes) {
    final active = promoCodes.where((p) => p.isActive).length;
    final valid = promoCodes.where((p) => p.isValid).length;
    final percentage = promoCodes.where((p) => p.type == 'percentage').length;
    final fixed = promoCodes.where((p) => p.type == 'fixed').length;
    
    return {
      'total': promoCodes.length,
      'active': active,
      'valid': valid,
      'percentage': percentage,
      'fixed': fixed,
      'expired': promoCodes.length - valid,
    };
  }
}