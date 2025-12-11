import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/reservation_controller.dart';

class CreateReservationScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const CreateReservationScreen({
    super.key,
    this.initialData,
  });

  @override
  State<CreateReservationScreen> createState() =>
      _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  final ReservationController controller = Get.find<ReservationController>();
  final GetStorage storage = GetStorage();

  // Form state
  String? _selectedVehicleId;
  String? _selectedVehicleName;
  double? _selectedDailyRate;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _selectedVehicleModelId;
  final String _selectedBranchId = '6750f1e0c1a2b34de0abcd01';

  // Form controllers
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _promoCodeController = TextEditingController();

  // Form validation
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Initialize with initial data if provided
    if (widget.initialData != null) {
      _selectedVehicleId = widget.initialData!['vehicleId'];
      _selectedVehicleName = widget.initialData!['vehicleName'];
      _selectedDailyRate = widget.initialData!['dailyRate'];
      _selectedStartDate = widget.initialData!['startDate'];
      _selectedEndDate = widget.initialData!['endDate'];
      _selectedVehicleModelId = widget.initialData!['vehicleModelId'];
    }

    // Set default dates if not provided
    _selectedStartDate ??= DateTime.now();
    _selectedEndDate ??= DateTime.now().add(const Duration(days: 1));
  }

  Future<void> _selectVehicle() async {
    final selectedVehicle = await Get.toNamed(
      AppRoutes.vehicleSelection,
      arguments: {'isSelectionMode': true},
    );

    if (selectedVehicle != null) {
      setState(() {
        _selectedVehicleId = selectedVehicle['vehicleId'];
        _selectedVehicleName = selectedVehicle['vehicleName'];
        _selectedDailyRate = selectedVehicle['dailyRate'];
        _selectedVehicleModelId = selectedVehicle['vehicleModelId'];
      });
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
        // Adjust end date if it's before start date
        if (_selectedEndDate != null && _selectedEndDate!.isBefore(picked)) {
          _selectedEndDate = picked.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ??
          (_selectedStartDate ?? DateTime.now()).add(const Duration(days: 1)),
      firstDate: _selectedStartDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  bool _validateForm() {
    if (_selectedVehicleId == null || _selectedVehicleId!.isEmpty) {
      Get.snackbar(
        'Missing Information',
        'Please select a vehicle',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (_selectedStartDate == null || _selectedEndDate == null) {
      Get.snackbar(
        'Missing Information',
        'Please select both pickup and return dates',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
      Get.snackbar(
        'Invalid Dates',
        'Return date must be after pickup date',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    if (_selectedStartDate!.isBefore(DateTime.now())) {
      Get.snackbar(
        'Invalid Dates',
        'Pickup date cannot be in the past',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  Future<void> _submitReservation() async {
    if (!_validateForm()) {
      return;
    }

    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Calculate duration
      final durationDays =
          _selectedEndDate!.difference(_selectedStartDate!).inDays;

      // Call controller to create reservation
      final response = await controller.createReservation(
        vehicleId: _selectedVehicleId!,
        vehicleModelId: _selectedVehicleModelId!, // Add this
        pickupDate: _selectedStartDate!,
        dropoffDate: _selectedEndDate!,
        branchId: _selectedBranchId,
        dailyRate: _selectedDailyRate ?? 50.0,
        durationDays: durationDays,
        promoCode: _promoCodeController.text.isNotEmpty
            ? _promoCodeController.text
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (response != null && response.success) {
        // Success - show confirmation and navigate
        Get.dialog(
          AlertDialog(
            title: Text('Reservation Created!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 64),
                SizedBox(height: 16),
                Text(
                  'Your reservation has been successfully created.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                if (response.data?.id != null) ...[
                  Text(
                    'Reservation ID: ${response.data!.id.substring(0, 8)}...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
                SizedBox(height: 8),
                Text(
                  'Total Amount: \$${(response.data?.totalAmount ?? _grandTotal).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
         actions: [
  TextButton(
    onPressed: () {
      Get.back(); // Close dialog
      Get.until((route) => route.isFirst); // Go to home
    },
    child: Text('Go to Home'),
  ),
  ElevatedButton(
    onPressed: () {
      Get.back(); // Close dialog
      // Navigate to the newly created reservation detail
      if (response.data?.id != null) {
        Get.offAllNamed(
          AppRoutes.reservationDetail,
          arguments: {'reservationId': response.data!.id},
        );
      } else {
        // Fallback to list if we don't have the ID
        Get.offAllNamed(AppRoutes.reservationList);
      }
    },
    child: Text('View Reservation'),
  ),
],
          ),
        );
      } else {
        throw Exception('Failed to create reservation');
      }
    } catch (e) {
      Get.snackbar(
        'Reservation Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Helper methods
  int get _durationDays {
    if (_selectedStartDate == null || _selectedEndDate == null) return 0;
    return _selectedEndDate!.difference(_selectedStartDate!).inDays;
  }

  double get _baseCost {
    return (_selectedDailyRate ?? 0) * _durationDays;
  }

  double get _taxAmount {
    return _baseCost * 0.15; // 15% tax
  }

  double get _grandTotal {
    final serviceFee = 10.00;
    final promoDiscount = _promoCodeController.text.isNotEmpty ? 5.00 : 0.00;
    return _baseCost + serviceFee + _taxAmount - promoDiscount;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final hasVehicle =
        _selectedVehicleId != null && _selectedVehicleId!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Reservation'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle Selection Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Vehicle',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: _selectVehicle,
                          tooltip: 'Select Vehicle',
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    if (hasVehicle) ...[
                      // Show selected vehicle
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.directions_car, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedVehicleName ?? 'Vehicle',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'ID: $_selectedVehicleId',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  if (_selectedDailyRate != null) ...[
                                    SizedBox(height: 4),
                                    Text(
                                      '\$${_selectedDailyRate!.toStringAsFixed(2)}/day',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: _selectVehicle,
                              tooltip: 'Change Vehicle',
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Show vehicle selection prompt
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.directions_car,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No Vehicle Selected',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Please select a vehicle to continue',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _selectVehicle,
                              icon: Icon(Icons.search),
                              label: Text('Browse Vehicles'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Dates Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dates',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 16),

                    // Start Date
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pickup Date',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              SizedBox(height: 4),
                              TextButton(
                                onPressed: _selectStartDate,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  backgroundColor: Colors.grey.shade50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 20, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedStartDate != null
                                            ? _formatDate(_selectedStartDate!)
                                            : 'Select Date',
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: 16),

                        // End Date
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Return Date',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              SizedBox(height: 4),
                              TextButton(
                                onPressed: _selectEndDate,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  backgroundColor: Colors.grey.shade50,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 20, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedEndDate != null
                                            ? _formatDate(_selectedEndDate!)
                                            : 'Select Date',
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Duration
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Duration: $_durationDays days'),
                          Spacer(),
                          if (_selectedDailyRate != null && hasVehicle)
                            Text(
                              '\$${(_selectedDailyRate! * _durationDays).toStringAsFixed(2)} total',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Cost Breakdown (only if vehicle selected)
            if (hasVehicle &&
                _selectedDailyRate != null &&
                _selectedDailyRate! > 0) ...[
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cost Breakdown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildCostRow(
                          'Base Rate ($_durationDays days)', _baseCost),
                      _buildCostRow('Service Fee', 10.00),
                      _buildCostRow('Tax (15%)', _taxAmount),
                      if (_promoCodeController.text.isNotEmpty)
                        _buildCostRow('Promo Discount', -5.00,
                            isDiscount: true),
                      Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '\$${_grandTotal.toStringAsFixed(2)}',
                            style: TextStyle(
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
              SizedBox(height: 20),
            ],

            // Promo Code Field
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Promo Code (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _promoCodeController,
                      decoration: InputDecoration(
                        hintText: 'Enter promo code...',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    if (_promoCodeController.text.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.discount, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Discount applied: \$-5.00',
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Additional Notes
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Additional Notes (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Special requests or instructions...',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // User Information
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _getUserInfo(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                              child: CircularProgressIndicator(value: 20));
                        }

                        if (snapshot.hasError || snapshot.data == null) {
                          return Text('Unable to load user information');
                        }

                        final userData = snapshot.data!;
                        return Column(
                          children: [
                            _buildInfoRow('Name',
                                userData['full_name'] ?? 'Not provided'),
                            _buildInfoRow(
                                'Email', userData['email'] ?? 'Not provided'),
                            _buildInfoRow(
                                'Phone', userData['phone'] ?? 'Not provided'),
                            if (userData['driver_license'] != null) ...[
                              SizedBox(height: 4),
                              Text(
                                'Driver License: ${userData['driver_license']}',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitReservation,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: hasVehicle ? Colors.green : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Processing...'),
                            ],
                          )
                        : Text(
                            hasVehicle
                                ? 'Confirm & Book Now'
                                : 'Select a Vehicle First',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDiscount ? Colors.red : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserInfo() async {
    final userData = storage.read('user_data') ?? {};
    return {
      'full_name': userData['full_name'],
      'email': userData['email'],
      'phone': userData['phone'],
      'driver_license': userData['driver_license'],
    };
  }
}
