// features/modules/reservations/views/create_reservation_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reservation_controller.dart';

class CreateReservationScreen extends StatelessWidget {
  final String vehicleId;
  final String vehicleName;
  final double dailyRate;
  final DateTime startDate;
  final DateTime endDate;

  const CreateReservationScreen({
    super.key,
    required this.vehicleId,
    required this.vehicleName,
    required this.dailyRate,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final ReservationController controller = Get.find<ReservationController>();
    final durationDays = endDate.difference(startDate).inDays;
    final totalCost = dailyRate * durationDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Reservation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reservation Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicleName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text('Pickup: ${_formatDate(startDate)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text('Return: ${_formatDate(endDate)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 20),
                        const SizedBox(width: 8),
                        Text('Duration: $durationDays days'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Cost:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${totalCost.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Additional Notes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Additional Notes (Optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: const InputDecoration(
                        hintText: 'Special requests or instructions...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        // You can store notes in controller if needed
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Confirm Booking Button
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // Create the reservation
                    final response = await controller.createReservation(
                      vehicleId: vehicleId,
                      pickupDate: startDate,
                      dropoffDate: endDate,
                      branchId: '6750f1e0c1a2b34de0abcd01',
                      dailyRate: dailyRate,
                      durationDays: durationDays,
                      notes: 'Booked via mobile app',
                    );
                    
                    if (response != null && response.success) {
                      // Show success message
                      Get.snackbar(
                        'Success',
                        'Reservation created successfully!',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                      
                      // Navigate back to home or reservation list
                      Get.until((route) => Get.currentRoute == '/home');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    'Confirm Booking',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              );
            }),
            
            const SizedBox(height: 10),
            
            // Back button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Get.back(); // Go back to availability screen
                },
                child: const Text('Back to Availability'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}