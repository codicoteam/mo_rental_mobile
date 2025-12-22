// payment_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../data/models/payment_models/payment_models.dart';
import '../../../data/services/payment_service.dart';


class PaymentController extends GetxController {
  final PaymentService _paymentService = PaymentService();
  final GetStorage _storage = GetStorage();
  
  // Observables
  final Rx<Payment?> currentPayment = Rx<Payment?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString paymentStatus = 'idle'.obs; // idle, processing, success, failed

  Future<PaymentInitiateResponse?> initiateCardPayment({
    required String reservationId,
    required double amount,
    String? email,
    String? promoCode,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      paymentStatus.value = 'processing';

      final userData = _storage.read('user_data') ?? {};
      final userEmail = email ?? userData['email'] ?? '';

      if (userEmail.isEmpty) {
        throw Exception('User email is required for payment');
      }

      final response = await _paymentService.initiatePayment(
        reservationId: reservationId,
        amount: amount,
        email: userEmail,
        promoCode: promoCode,
      );

      if (response.success && response.redirectUrl != null) {
        currentPayment.value = response.payment;
        paymentStatus.value = 'redirecting';
        return response;
      } else {
        throw Exception(response.promoWarning ?? 'Payment initiation failed');
      }
    } catch (e) {
      error.value = e.toString();
      paymentStatus.value = 'failed';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<PaymentInitiateResponse?> initiateMobilePayment({
    required String reservationId,
    required double amount,
    required String phone,
    required String mobileMethod,
    String? promoCode,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      paymentStatus.value = 'processing';

      final response = await _paymentService.initiateMobilePayment(
        reservationId: reservationId,
        amount: amount,
        phone: phone,
        mobileMethod: mobileMethod,
        promoCode: promoCode,
      );

      if (response.success) {
        currentPayment.value = response.payment;
        
        // If there's a poll URL, start polling
        if (response.pollUrl != null && response.payment != null) {
          paymentStatus.value = 'polling';
          await _pollPaymentStatus(response.payment!.id);
        } else {
          paymentStatus.value = 'pending';
        }
        
        return response;
      } else {
        throw Exception(response.promoWarning ?? 'Mobile payment failed');
      }
    } catch (e) {
      error.value = e.toString();
      paymentStatus.value = 'failed';
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _pollPaymentStatus(String paymentId) async {
    try {
      final status = await _paymentService.pollPaymentStatus(paymentId: paymentId);
      
      if (status.success && status.payment != null) {
        currentPayment.value = status.payment;
        
        if (status.payment!.isPaid) {
          paymentStatus.value = 'success';
          Get.snackbar(
            'Payment Successful',
            'Your payment has been processed successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else if (status.payment!.isFailed || status.payment!.isCancelled) {
          paymentStatus.value = 'failed';
          Get.snackbar(
            'Payment Failed',
            status.message ?? 'Payment could not be processed',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      paymentStatus.value = 'timeout';
      Get.snackbar(
        'Payment Status',
        'Payment status check timed out. Please check your transaction history.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  Future<Payment?> getPaymentDetails(String paymentId) async {
    try {
      isLoading.value = true;
      final payment = await _paymentService.getPayment(paymentId);
      currentPayment.value = payment;
      return payment;
    } catch (e) {
      error.value = e.toString();
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  void resetPaymentState() {
    currentPayment.value = null;
    isLoading.value = false;
    error.value = '';
    paymentStatus.value = 'idle';
  }
}