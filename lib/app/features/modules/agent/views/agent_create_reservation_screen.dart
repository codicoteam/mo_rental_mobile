import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../routes/app_routes.dart';
import '../../reservations/controllers/reservation_controller.dart';
import '../controllers/agent_customer_controller.dart';

class AgentCreateReservationScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const AgentCreateReservationScreen({
    super.key,
    this.initialData,
  });

  @override
  State<AgentCreateReservationScreen> createState() =>
      _AgentCreateReservationScreenState();
}

class _AgentCreateReservationScreenState extends State<AgentCreateReservationScreen>
    with SingleTickerProviderStateMixin {
  final ReservationController controller = Get.find<ReservationController>();
  final AgentCustomerController customerController = Get.find<AgentCustomerController>();
  final GetStorage storage = GetStorage();

  // Form state
  String? _selectedVehicleId;
  String? _selectedVehicleName;
  double? _selectedDailyRate;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _selectedVehicleModelId;
  final String _selectedBranchId = '6750f1e0c1a2b34de0abcd01';
  
  // NEW: Customer selection
  Map<String, dynamic>? _selectedCustomer;
  bool _bookingForSelf = false;
  
  // NEW: Agent-specific fields
  String? _agentNotes;
  bool _overrideAvailability = false;
  String? _priorityLevel; // normal, high, urgent

  // Form controllers
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _promoCodeController = TextEditingController();
  // ignore: unused_field
  final TextEditingController _customerSearchController = TextEditingController();

  // Form validation
  bool _isSubmitting = false;
  bool _isLoadingCustomers = false;
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
      _loadCustomers();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    setState(() {
      _isLoadingCustomers = true;
    });
    await customerController.fetchCustomers();
    setState(() {
      _isLoadingCustomers = false;
    });
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

  Future<void> _selectCustomer() async {
    final selectedCustomer = await Get.toNamed(
      AppRoutes.agentCustomerSelection,
    );

    if (selectedCustomer != null) {
      setState(() {
        _selectedCustomer = selectedCustomer;
        _bookingForSelf = false;
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

    // NEW: Validate customer selection
    if (!_bookingForSelf && (_selectedCustomer == null || _selectedCustomer!.isEmpty)) {
      Get.snackbar(
        'Missing Information',
        'Please select a customer or book for yourself',
        backgroundColor: Colors.orange,
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
      final durationDays = _selectedEndDate!.difference(_selectedStartDate!).inDays;
      
      // Determine the user ID (customer or agent)
      String userId;
      if (_bookingForSelf) {
        final userData = storage.read('user_data') ?? {};
        userId = userData['id'] ?? userData['_id'] ?? '';
      } else {
        userId = _selectedCustomer?['id'] ?? _selectedCustomer?['_id'] ?? '';
      }

      // Call controller to create reservation
     // In your _submitReservation() method:
final response = await controller.createReservation(
  vehicleId: _selectedVehicleId!,
  vehicleModelId: _selectedVehicleModelId!,
  pickupDate: _selectedStartDate!,
  dropoffDate: _selectedEndDate!,
  branchId: _selectedBranchId,
  dailyRate: _selectedDailyRate ?? 50.0,
  durationDays: durationDays,
  promoCode: _promoCodeController.text.isNotEmpty ? _promoCodeController.text : null,
  notes: _notesController.text.isNotEmpty ? _notesController.text : null,
  // NEW: Pass additional agent info
  createdByAgent: true,
  agentNotes: _agentNotes,
  customerId: _bookingForSelf ? null : userId,
  overrideAvailability: _overrideAvailability,
  priorityLevel: _priorityLevel,
);
      if (response != null && response.success) {
        // Success - show confirmation
        Get.dialog(
          AlertDialog(
            title: const Text('Reservation Created!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text(
                  _bookingForSelf 
                    ? 'Your reservation has been successfully created.'
                    : 'Reservation for ${_selectedCustomer?['full_name'] ?? 'customer'} has been created.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                if (response.data?.id != null) ...[
                  Text(
                    'Reservation ID: ${response.data!.id.substring(0, 8)}...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Total Amount: \$${(response.data?.totalAmount ?? _grandTotal).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _bookingForSelf ? 'Booked for yourself' : 'Booked for customer',
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  Get.until((route) => route.isFirst);
                },
                child: const Text('Go to Dashboard'),
              ),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  if (response.data?.id != null) {
                    Get.offAllNamed(
                      AppRoutes.agentReservationDetail,
                      arguments: {'reservationId': response.data!.id},
                    );
                  } else {
                    Get.offAllNamed(AppRoutes.agentReservationList);
                  }
                },
                child: const Text('View Reservation'),
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
        duration: const Duration(seconds: 5),
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

  double get _baseCost => (_selectedDailyRate ?? 0) * _durationDays;
  double get _taxAmount => _baseCost * 0.15;
  
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
    final hasVehicle = _selectedVehicleId != null && _selectedVehicleId!.isNotEmpty;
    final hasCustomer = _bookingForSelf || (_selectedCustomer != null && _selectedCustomer!.isNotEmpty);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Create Reservation (Agent)',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Agent Booking Mode'),
                  content: const Text(
                    'You can book vehicles for yourself or on behalf of customers. '
                    'Agent bookings have additional options and override permissions.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NEW: Customer Selection Section
              _buildSectionCard(
                title: 'Customer Selection',
                icon: Icons.person_search_rounded,
                children: [
                  // Booking Mode Toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildBookingModeOption(
                            title: 'Book for Customer',
                            subtitle: 'Select an existing customer',
                            icon: Icons.person_outline,
                            isSelected: !_bookingForSelf,
                            onTap: () {
                              setState(() {
                                _bookingForSelf = false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildBookingModeOption(
                            title: 'Book for Yourself',
                            subtitle: 'You are the customer',
                            icon: Icons.person_pin,
                            isSelected: _bookingForSelf,
                            onTap: () {
                              setState(() {
                                _bookingForSelf = true;
                                _selectedCustomer = null;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  if (!_bookingForSelf) ...[
                    // Customer Search/Selection
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Select customer',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            if (customerController.customers.isNotEmpty)
                              Text(
                                '${customerController.customers.length} customers',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        if (_isLoadingCustomers)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                color: const Color(0xFF047BC1),
                              ),
                            ),
                          )
                        else if (hasCustomer)
                          // Show selected customer
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFF047BC1).withOpacity(0.08),
                                  const Color(0xFF4F46E5).withOpacity(0.08),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF047BC1).withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF047BC1).withOpacity(0.1),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Color(0xFF047BC1),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedCustomer?['full_name'] ?? 'Unknown',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (_selectedCustomer?['email'] != null)
                                        Text(
                                          _selectedCustomer!['email'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      if (_selectedCustomer?['phone'] != null)
                                        Text(
                                          _selectedCustomer!['phone'],
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: _selectCustomer,
                                ),
                              ],
                            ),
                          )
                        else
                          // Customer selection button
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: _selectCustomer,
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.person_add_alt_1_rounded,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Select Customer',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Choose from existing customers',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
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
                  ] else ...[
                    // Show agent as customer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.shade100,
                            ),
                            child: const Icon(
                              Icons.security_rounded,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Booking as Agent',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                  ),
                                ),
                                Text(
                                  'You will be the primary driver',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // Vehicle Selection Section (same as before but compact)
              _buildSectionCard(
                title: 'Vehicle Selection',
                icon: Icons.directions_car_rounded,
                children: [
                  if (hasVehicle) ...[
                    // Selected vehicle display
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(4, 123, 193, 0.08),
                            Color.fromRGBO(79, 70, 229, 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF047BC1).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF047BC1).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.directions_car_rounded,
                              color: Color(0xFF047BC1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedVehicleName ?? 'Vehicle',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (_selectedDailyRate != null)
                                  Text(
                                    '\$${_selectedDailyRate!.toStringAsFixed(2)} / day',
                                    style: const TextStyle(
                                      color: Color(0xFF047BC1),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: _selectVehicle,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Vehicle selection prompt
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: _selectVehicle,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_car_outlined,
                                  size: 24,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Select Vehicle',
                                  style: TextStyle(
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
                  ],
                ],
              ),

              const SizedBox(height: 24),

              // Dates Section (same as before)
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

              // NEW: Agent Controls Section
              _buildSectionCard(
                title: 'Agent Controls',
                icon: Icons.settings_rounded,
                children: [
                  // Priority Level
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Priority Level',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildPriorityChip('Normal', 'normal'),
                          _buildPriorityChip('High', 'high'),
                          _buildPriorityChip('Urgent', 'urgent'),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Override Availability
                  Row(
                    children: [
                      Switch(
                        value: _overrideAvailability,
                        onChanged: (value) {
                          setState(() {
                            _overrideAvailability = value;
                          });
                        },
                        activeColor: const Color(0xFF047BC1),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Override Availability',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Book even if vehicle shows as unavailable',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Agent Notes
                  TextField(
                    onChanged: (value) => setState(() => _agentNotes = value),
                    decoration: InputDecoration(
                      hintText: 'Internal agent notes (optional)...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Cost Breakdown (only if vehicle selected)
              if (hasVehicle && _selectedDailyRate != null && _selectedDailyRate! > 0) ...[
                _buildSectionCard(
                  title: 'Cost Breakdown',
                  icon: Icons.receipt_long_rounded,
                  children: [
                    _buildCostRow('Base Rate ($_durationDays days)', _baseCost),
                    _buildCostRow('Service Fee', 10.00),
                    _buildCostRow('Tax (15%)', _taxAmount),
                    if (_promoCodeController.text.isNotEmpty)
                      _buildCostRow('Promo Discount', -5.00, isDiscount: true),
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

              // Promo Code & Notes (same as before)
              _buildSectionCard(
                title: 'Promo Code',
                icon: Icons.local_offer_rounded,
                children: [
                  TextField(
                    controller: _promoCodeController,
                    decoration: const InputDecoration(
                      hintText: 'Enter promo code...',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              _buildSectionCard(
                title: 'Additional Notes',
                icon: Icons.note_add_rounded,
                children: [
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      hintText: 'Special requests or instructions...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 4,
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
                      gradient: (hasVehicle && hasCustomer)
                          ? const LinearGradient(
                              colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                            )
                          : LinearGradient(
                              colors: [
                                Colors.grey.shade400,
                                Colors.grey.shade500,
                              ],
                            ),
                      boxShadow: (hasVehicle && hasCustomer)
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
                        onTap: (hasVehicle && hasCustomer && !_isSubmitting)
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
                                      (hasVehicle && hasCustomer)
                                          ? Icons.check_circle_outline_rounded
                                          : Icons.info_outline_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      (hasVehicle && hasCustomer)
                                          ? 'Confirm & Book Now'
                                          : 'Complete all fields first',
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF047BC1), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBookingModeOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF047BC1).withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF047BC1) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF047BC1) : Colors.grey.shade600,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF047BC1) : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? const Color(0xFF047BC1) : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
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
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(icon, color: const Color(0xFF4F46E5), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        date != null ? _formatDate(date) : 'Select Date',
                        style: TextStyle(
                          color: date != null ? Colors.black87 : Colors.grey.shade500,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCostRow(String label, double amount, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(
            '\$${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDiscount ? Colors.red : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip(String label, String value) {
    final isSelected = _priorityLevel == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _priorityLevel = selected ? value : null;
        });
      },
      selectedColor: const Color(0xFF047BC1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
      ),
    );
  }
}