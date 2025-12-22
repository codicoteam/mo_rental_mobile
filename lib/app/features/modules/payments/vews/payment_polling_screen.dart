// payment_polling_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/payment_controller.dart';

class PaymentPollingScreen extends StatefulWidget {
  const PaymentPollingScreen({super.key});

  @override
  State<PaymentPollingScreen> createState() => _PaymentPollingScreenState();
}

class _PaymentPollingScreenState extends State<PaymentPollingScreen> {
  final PaymentController paymentController = Get.find<PaymentController>();
  late String paymentId;
  late String reservationId;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    paymentId = args?['paymentId'] ?? '';
    reservationId = args?['reservationId'] ?? '';
    
    // Start listening to payment status
    _startPolling();
  }

  void _startPolling() async {
    // The controller is already polling, just listen to changes
    ever(paymentController.paymentStatus, (status) {
      if (status == 'success') {
        // Navigate to success screen
        Get.offAllNamed(
          AppRoutes.paymentSuccess,
          arguments: {
            'reservationId': reservationId,
            'paymentId': paymentId,
          },
        );
      } else if (status == 'failed' || status == 'timeout') {
        // Show error and go back
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Processing'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF047BC1)),
              strokeWidth: 3,
            ),
            SizedBox(height: 20),
            Obx(() {
              final status = paymentController.paymentStatus.value;
              return Column(
                children: [
                  Text(
                    _getStatusMessage(status),
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  if (status == 'polling')
                    Text(
                      'Please check your phone for payment prompt',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              );
            }),
            SizedBox(height: 30),
            Obx(() {
              if (paymentController.error.value.isNotEmpty) {
                return Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Text(
                    paymentController.error.value,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return SizedBox();
            }),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel Payment'),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'processing':
        return 'Initiating payment...';
      case 'polling':
        return 'Waiting for payment confirmation...';
      case 'success':
        return 'Payment successful!';
      case 'failed':
        return 'Payment failed';
      case 'timeout':
        return 'Payment check timed out';
      default:
        return 'Processing payment...';
    }
  }
}