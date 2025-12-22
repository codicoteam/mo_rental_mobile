// payment_webview_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../routes/app_routes.dart';

class PaymentWebviewScreen extends StatefulWidget {
  const PaymentWebviewScreen({super.key});

  @override
  State<PaymentWebviewScreen> createState() => _PaymentWebviewScreenState();
}

class _PaymentWebviewScreenState extends State<PaymentWebviewScreen> {
  late WebViewController _webViewController;
  bool _isLoading = true;
  bool _paymentCompleted = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    final url = args?['url'] ?? '';
    final reservationId = args?['reservationId'] ?? '';
    final paymentId = args?['paymentId'] ?? '';

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            
            // Check if payment is completed
            if (url.contains('success') || url.contains('completed')) {
              _handlePaymentSuccess(reservationId, paymentId);
            } else if (url.contains('failed') || url.contains('cancelled')) {
              _handlePaymentFailure();
            }
          },
          onWebResourceError: (WebResourceError error) {
            Get.snackbar(
              'Payment Error',
              'Unable to load payment page',
              backgroundColor: Colors.red,
            );
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow all navigation
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void _handlePaymentSuccess(String reservationId, String paymentId) {
    if (!_paymentCompleted) {
      _paymentCompleted = true;
      
      Future.delayed(Duration(seconds: 2), () {
        Get.offAllNamed(
          AppRoutes.paymentSuccess,
          arguments: {
            'reservationId': reservationId,
            'paymentId': paymentId,
          },
        );
      });
    }
  }

  void _handlePaymentFailure() {
    Get.back();
    Get.snackbar(
      'Payment Failed',
      'Please try again or use another payment method',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Secure Payment'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}