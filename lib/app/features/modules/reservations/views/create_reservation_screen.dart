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

class _CreateReservationScreenState extends State<CreateReservationScreen>
    with SingleTickerProviderStateMixin {
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
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

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

    // Initialize animation controller
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Create Reservation',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF047BC1),
        surfaceTintColor: Colors.white,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Selection Section
              _buildSectionCard(
                title: 'Vehicle Selection',
                icon: Icons.directions_car_rounded,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select your vehicle',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _selectVehicle,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.search_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Browse Vehicles',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (hasVehicle) ...[
                    // Show selected vehicle
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color.fromRGBO(4, 123, 193, 0.08),
                            Color.fromRGBO(79, 70, 229, 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF047BC1).withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF047BC1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_car_rounded,
                              color: Color(0xFF047BC1),
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedVehicleName ?? 'Vehicle',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'ID: ${_selectedVehicleId!.substring(0, 8)}...',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                if (_selectedDailyRate != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '\$${_selectedDailyRate!.toStringAsFixed(2)} / day',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF047BC1),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit_rounded,
                              color: const Color(0xFF4F46E5).withOpacity(0.8),
                            ),
                            onPressed: _selectVehicle,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Show vehicle selection prompt
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade100,
                            ),
                            child: Icon(
                              Icons.directions_car_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No Vehicle Selected',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Please select a vehicle to continue',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // Dates Section
              _buildSectionCard(
                title: 'Rental Period',
                icon: Icons.calendar_today_rounded,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          label: 'Pickup Date',
                          date: _selectedStartDate,
                          onTap: _selectStartDate,
                          icon: Icons.date_range_rounded,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDateField(
                          label: 'Return Date',
                          date: _selectedEndDate,
                          onTap: _selectEndDate,
                          icon: Icons.date_range_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4F46E5).withOpacity(0.05),
                          const Color(0xFF047BC1).withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF4F46E5).withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.access_time_rounded,
                            color: Color(0xFF4F46E5),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Rental Duration',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '$_durationDays days',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_selectedDailyRate != null && hasVehicle)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Subtotal',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '\$${(_selectedDailyRate! * _durationDays).toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Cost Breakdown (only if vehicle selected)
              if (hasVehicle &&
                  _selectedDailyRate != null &&
                  _selectedDailyRate! > 0) ...[
                _buildSectionCard(
                  title: 'Cost Breakdown',
                  icon: Icons.receipt_long_rounded,
                  children: [
                    _buildCostRow(
                      'Base Rate ($_durationDays days)',
                      _baseCost,
                    ),
                    _buildCostRow('Service Fee', 10.00),
                    _buildCostRow('Tax (15%)', _taxAmount),
                    if (_promoCodeController.text.isNotEmpty)
                      _buildCostRow(
                        'Promo Discount',
                        -5.00,
                        isDiscount: true,
                      ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            '\$${_grandTotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // Promo Code Field
              _buildSectionCard(
                title: 'Promo Code',
                icon: Icons.local_offer_rounded,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _promoCodeController,
                      decoration: const InputDecoration(
                        hintText: 'Enter promo code...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                  if (_promoCodeController.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(76, 175, 80, 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color.fromRGBO(76, 175, 80, 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Color.fromRGBO(76, 175, 80, 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.discount_rounded,
                              color: Color.fromRGBO(76, 175, 80, 1),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Discount applied: \$-5.00',
                            style: TextStyle(
                              color: const Color.fromRGBO(76, 175, 80, 1),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // Additional Notes
              _buildSectionCard(
                title: 'Additional Notes',
                icon: Icons.note_add_rounded,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        hintText: 'Special requests or instructions...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                      maxLines: 4,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // User Information
              _buildSectionCard(
                title: 'Your Information',
                icon: Icons.person_outline_rounded,
                children: [
                  FutureBuilder<Map<String, dynamic>>(
                    future: _getUserInfo(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                              const Color(0xFF047BC1),
                            ),
                          ),
                        );
                      }

                      if (snapshot.hasError || snapshot.data == null) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Unable to load user information',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      final userData = snapshot.data!;
                      return Column(
                        children: [
                          _buildInfoRow('Name', userData['full_name'] ?? 'Not provided'),
                          const Divider(height: 20),
                          _buildInfoRow('Email', userData['email'] ?? 'Not provided'),
                          const Divider(height: 20),
                          _buildInfoRow('Phone', userData['phone'] ?? 'Not provided'),
                          if (userData['driver_license'] != null) ...[
                            const Divider(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 80,
                                  child: Text(
                                    'License:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    userData['driver_license'],
                                    style: TextStyle(
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Column(
                children: [
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: hasVehicle
                          ? const LinearGradient(
                              colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                            )
                          : LinearGradient(
                              colors: [
                                Colors.grey.shade400,
                                Colors.grey.shade500,
                              ],
                            ),
                      boxShadow: hasVehicle
                          ? [
                              BoxShadow(
                                color: const Color(0xFF4F46E5).withOpacity(0.3),
                                blurRadius: 16,
                                spreadRadius: 0,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: hasVehicle && !_isSubmitting
                            ? _submitReservation
                            : null,
                        borderRadius: BorderRadius.circular(14),
                        child: Center(
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      hasVehicle
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.info_outline_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      hasVehicle
                                          ? 'Confirm & Book Now'
                                          : 'Select a Vehicle First',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: _isSubmitting ? null : () => Get.back(),
                        borderRadius: BorderRadius.circular(14),
                        child: const Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF047BC1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF047BC1),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(
                      icon,
                      color: const Color(0xFF4F46E5),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        date != null ? _formatDate(date) : 'Select Date',
                        style: TextStyle(
                          fontSize: 15,
                          color: date != null
                              ? Colors.black87
                              : Colors.grey.shade500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            '\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDiscount
                  ? const Color.fromRGBO(239, 68, 68, 1)
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
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