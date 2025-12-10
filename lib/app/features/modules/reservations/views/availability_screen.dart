import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../domain/repositories/reservation_repository.dart';
import '../../../data/models/reservation_models/reservation_models.dart';
import '../controllers/reservation_controller.dart';
import '../../../../routes/app_routes.dart'; // ADD THIS IMPORT

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  late ReservationController _controller;
  final TextEditingController _vehicleIdController = TextEditingController();
  DateTime? _pickedStartDate;
  DateTime? _pickedEndDate;

  @override
  void initState() {
    super.initState();

    // Initialize controller safely
    _initializeController();

    // Initialize with default dates
    _pickedStartDate = DateTime.now();
    _pickedEndDate = DateTime.now().add(const Duration(days: 1));
  }

  void _initializeController() {
    try {
      // Check if controller exists, if not create it
      if (!Get.isRegistered<ReservationController>()) {
        // First check if repository exists
        if (!Get.isRegistered<ReservationRepository>()) {
          Get.lazyPut(() => ReservationRepository(), fenix: true);
        }
        Get.lazyPut(() => ReservationController(), fenix: true);
        print('🛠️ Manually initialized ReservationController');
      }

      _controller = Get.find<ReservationController>();

      // Set initial dates if controller has them
      _pickedStartDate = _controller.selectedStartDate.value;
      _pickedEndDate = _controller.selectedEndDate.value;
    } catch (e) {
      print('❌ Error initializing controller: $e');
      // Create a fallback controller
      Get.lazyPut(() => ReservationController(), fenix: true);
      _controller = Get.find<ReservationController>();
    }
  }

  @override
  void dispose() {
    _vehicleIdController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _pickedStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _pickedStartDate = picked;
        _controller.setStartDate(picked);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _pickedEndDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: _pickedStartDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _pickedEndDate = picked;
        _controller.setEndDate(picked);
      });
    }
  }

  void _checkAvailability() {
    if (_pickedStartDate == null || _pickedEndDate == null) {
      Get.snackbar(
        'Missing Dates',
        'Please select both start and end dates',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_pickedEndDate!.isBefore(_pickedStartDate!)) {
      Get.snackbar(
        'Invalid Dates',
        'End date must be after start date',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (_pickedStartDate!.isBefore(DateTime.now())) {
      Get.snackbar(
        'Invalid Dates',
        'Start date cannot be in the past',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // FIX: Normalize dates to remove time component
    final normalizedStartDate = DateTime(
      _pickedStartDate!.year,
      _pickedStartDate!.month,
      _pickedStartDate!.day,
    );

    final normalizedEndDate = DateTime(
      _pickedEndDate!.year,
      _pickedEndDate!.month,
      _pickedEndDate!.day,
    );

    print('📅 Normalized Start Date: $normalizedStartDate');
    print('📅 Normalized End Date: $normalizedEndDate');

    _controller.checkAvailability(
      vehicleId: _vehicleIdController.text.trim().isEmpty
          ? null
          : _vehicleIdController.text.trim(),
      startDate: normalizedStartDate,
      endDate: normalizedEndDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Vehicle Availability'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.clearResults,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vehicle ID Input (Optional)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vehicle ID (Optional)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _vehicleIdController,
                      decoration: const InputDecoration(
                        hintText: 'Enter specific vehicle ID',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.directions_car),
                      ),
                      onChanged: (value) => _controller.setVehicleId(value),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Leave empty to check all available vehicles',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Date Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Dates',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Start Date
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        const Text('Start Date:',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _selectStartDate(context),
                          child: Text(
                            DateFormat('MMM dd, yyyy')
                                .format(_pickedStartDate!),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // End Date
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        const Text('End Date:',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _selectEndDate(context),
                          child: Text(
                            DateFormat('MMM dd, yyyy').format(_pickedEndDate!),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Duration
                    Builder(builder: (context) {
                      final duration =
                          _pickedEndDate!.difference(_pickedStartDate!).inDays;
                      return Row(
                        children: [
                          const Icon(Icons.access_time, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Duration: $duration day${duration != 1 ? 's' : ''}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Check Availability Button
            Obx(() {
              if (_controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ElevatedButton(
                onPressed: _checkAvailability,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Check Availability',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }),

            const SizedBox(height: 20),

            // Results Section
            Obx(() {
              if (_controller.error.value.isNotEmpty) {
                return Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.error, color: Colors.red),
                            SizedBox(width: 8),
                            Text(
                              'Error',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(_controller.error.value),
                      ],
                    ),
                  ),
                );
              }

              final result = _controller.availabilityResult.value;
              if (result == null) {
                return const SizedBox();
              }

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Availability Status
                      Row(
                        children: [
                          Icon(
                            result.available
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: result.available ? Colors.green : Colors.red,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            result.available ? 'AVAILABLE' : 'NOT AVAILABLE',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color:
                                  result.available ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Message
                      if (result.message != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(result.message!),
                        ),

                      // Vehicle Info
                      if (result.vehicle != null) ...[
                        _buildVehicleInfo(result.vehicle!),
                        const SizedBox(height: 16),
                      ],

                      // Conflicts
                      if (result.conflicts != null &&
                          result.conflicts!.isNotEmpty) ...[
                        const Text(
                          'Conflicts:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...result.conflicts!
                            .map((conflict) => _buildConflictCard(conflict)),
                      ],

                      // Estimated Cost
                      if (result.available && result.vehicle != null)
                        _buildEstimatedCost(result.vehicle!),

                      const SizedBox(height: 16),

                      // Action Buttons - CORRECTED VERSION
                      // In the _buildVehicleInfo method or wherever your Book Now button is:
                      if (result.available && result.vehicle != null)
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  // Navigate to CreateReservationScreen with parameters
                                  Get.toNamed(
                                    AppRoutes.createReservation,
                                    arguments: {
                                      // Use arguments, NOT parameters
                                      'vehicleId': result.vehicle!.id,
                                      'vehicleName':
                                          result.vehicle!.displayName,
                                      'dailyRate': result.vehicle!.dailyRate,
                                      'startDate': _pickedStartDate!,
                                      'endDate': _pickedEndDate!,
                                    },
                                  );
                                },
                                icon: const Icon(Icons.book_online),
                                label: const Text('Book Now'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 20),

            // Information Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'How it works',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Enter a vehicle ID to check specific vehicle availability',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '2. Leave vehicle ID empty to search all available vehicles',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '3. Select your desired pickup and return dates',
                      style: TextStyle(fontSize: 14),
                    ),
                    const Text(
                      '4. Click "Check Availability" to see if the vehicle is free',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleInfo(VehicleInfo vehicle) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vehicle Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.directions_car, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    vehicle.displayName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.confirmation_number, size: 20),
                const SizedBox(width: 8),
                Text('Plate: ${vehicle.licensePlate}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people, size: 20),
                const SizedBox(width: 8),
                Text('Seats: ${vehicle.seatingCapacity}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 20),
                const SizedBox(width: 8),
                Text(vehicle.formattedDailyRate),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConflictCard(Conflict conflict) {
    return Card(
      color: Colors.orange.shade50,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reservation Conflict',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 4),
            Text('From: ${DateFormat('MMM dd, yyyy').format(conflict.start)}'),
            Text('To: ${DateFormat('MMM dd, yyyy').format(conflict.end)}'),
            if (conflict.status != null) Text('Status: ${conflict.status}'),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimatedCost(VehicleInfo vehicle) {
    final duration = _pickedEndDate!.difference(_pickedStartDate!).inDays;
    final cost = duration * vehicle.dailyRate;

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estimated Cost',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calculate, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$duration days × \$${vehicle.dailyRate}/day',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.money, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Total: \$${cost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
