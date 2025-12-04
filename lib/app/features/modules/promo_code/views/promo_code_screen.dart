import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/promo_code_controller.dart';

class PromoCodeScreen extends StatelessWidget {
  const PromoCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // SIMPLE FIX: Initialize controller if not already done
    if (!Get.isRegistered<PromoCodeController>()) {
      Get.put(PromoCodeController());
    }
    
    final PromoCodeController controller = Get.find<PromoCodeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Promo Codes'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.fetchActivePromoCodes(printToTerminal: true);
              Get.snackbar(
                'Refreshing',
                'Fetching latest promo codes...',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    controller.error.value,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: controller.refreshPromoCodes,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        if (controller.activePromoCodes.isEmpty) {
          return const Center(
            child: Text('No active promo codes found'),
          );
        }

        return ListView.builder(
          itemCount: controller.activePromoCodes.length,
          itemBuilder: (context, index) {
            final promo = controller.activePromoCodes[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: promo.isValid ? Colors.green : Colors.grey,
                child: Text(promo.code[0]),
              ),
              title: Text(promo.code),
              subtitle: Text('${promo.type} - ${promo.value}'),
              trailing: promo.isValid 
                  ? const Icon(Icons.check, color: Colors.green)
                  : const Icon(Icons.close, color: Colors.red),
            );
          },
        );
      }),
    );
  }
}