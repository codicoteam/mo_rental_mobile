import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../routes/app_routes.dart';
import '../../../data/models/reservation_models/reservation_models.dart';
import '../../payments/controllers/payment_controller.dart';
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

class _AgentCreateReservationScreenState
    extends State<AgentCreateReservationScreen>
    with SingleTickerProviderStateMixin {
  final ReservationController controller = Get.find<ReservationController>();
  final AgentCustomerController customerController =
      Get.find<AgentCustomerController>();
  final PaymentController paymentController = Get.find<PaymentController>();
  final GetStorage storage = GetStorage();

  // Form state
  String? _selectedVehicleId;
  String? _selectedVehicleName;
  double? _selectedDailyRate;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  String? _selectedVehicleModelId;
  final String _selectedBranchId = '6750f1e0c1a2b34de0abcd01';

  // Customer selection
  Map<String, dynamic>? _selectedCustomer;
  bool _bookingForSelf = false;

  // Agent-specific fields
  String? _agentNotes;
  bool _overrideAvailability = false;
  String? _priorityLevel; // normal, high, urgent

  // Payment state - SEPARATED VARIABLES
  String?
      _selectedPaymentOption; // 'process', 'unpaid', 'cash_paid' - AGENT OPTION
  String? _selectedPaymentMethod; // 'card', 'ecocash' - ACTUAL PAYMENT METHOD
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _promoCodeController = TextEditingController();
  // ignore: unused_field
  final TextEditingController _customerSearchController =
      TextEditingController();

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
    _mobileNumberController.dispose();
    _notesController.dispose();
    _promoCodeController.dispose();
    _customerSearchController.dispose();
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

    // Validate customer selection
    if (!_bookingForSelf &&
        (_selectedCustomer == null || _selectedCustomer!.isEmpty)) {
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
      final durationDays =
          _selectedEndDate!.difference(_selectedStartDate!).inDays;

      // Determine the user ID (customer or agent)
      String userId;
      if (_bookingForSelf) {
        final userData = storage.read('user_data') ?? {};
        userId = userData['id'] ?? userData['_id'] ?? '';
      } else {
        userId = _selectedCustomer?['id'] ?? _selectedCustomer?['_id'] ?? '';
      }

      // Call controller to create reservation
      final response = await controller.createReservation(
        vehicleId: _selectedVehicleId!,
        vehicleModelId: _selectedVehicleModelId!,
        pickupDate: _selectedStartDate!,
        dropoffDate: _selectedEndDate!,
        branchId: _selectedBranchId,
        dailyRate: _selectedDailyRate ?? 50.0,
        durationDays: durationDays,
        promoCode: _promoCodeController.text.isNotEmpty
            ? _promoCodeController.text
            : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        // Pass additional agent info
        createdByAgent: true,
        agentNotes: _agentNotes,
        customerId: _bookingForSelf ? null : userId,
        overrideAvailability: _overrideAvailability,
        priorityLevel: _priorityLevel,
      );

      if (response != null && response.success && response.data != null) {
        // For agent bookings, show option to process payment or mark as unpaid
        await _showAgentPaymentOptions(response.data!);
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

  // Fixed mobile number validation
  bool _isValidZimbabweanMobile(String mobile) {
    if (mobile.isEmpty) return false;

    // Remove any non-digit characters and spaces
    final cleanMobile = mobile.replaceAll(RegExp(r'[^\d]'), '').trim();

    print('🔍 Validating mobile: "$mobile" -> cleaned: "$cleanMobile"');

    // Check for common Zimbabwean mobile formats:

    // 1. Starts with 0 and has 10 digits (e.g., 0771234567)
    if (cleanMobile.startsWith('0') && cleanMobile.length == 10) {
      final prefix = cleanMobile.substring(0, 3);
      // Valid Zimbabwean prefixes: 077 (Econet), 078 (NetOne), 071 (Telecel), 073 (Telecel)
      if (['077', '078', '071', '073'].contains(prefix)) {
        print('✅ Valid format: Starts with 0, 10 digits, prefix: $prefix');
        return true;
      }
    }

    // 2. Already in international format without +263 (e.g., 771234567) - 9 digits
    if (cleanMobile.length == 9 && RegExp(r'^7[1378]').hasMatch(cleanMobile)) {
      print('✅ Valid format: 9 digits, starts with 7[1378]');
      return true;
    }

    // 3. Full international format with 263 (e.g., 263771234567) - 12 digits
    if (cleanMobile.length == 12 && cleanMobile.startsWith('263')) {
      final prefix = cleanMobile.substring(3, 5); // Get the 2 digits after 263
      if (['77', '78', '71', '73'].contains(prefix)) {
        print('✅ Valid format: 12 digits with 263 prefix');
        return true;
      }
    }

    // 4. For numbers that might have been entered without leading 0 but with +263 prefix
    // User might have entered "780197542" thinking it's already international
    if (cleanMobile.length == 9 && cleanMobile.startsWith('7')) {
      final firstTwo = cleanMobile.substring(0, 2);
      if (['77', '78', '71', '73'].contains(firstTwo)) {
        print('✅ Valid format: 9 digits starting with 7, prefix: $firstTwo');
        return true;
      }
    }

    print(
        '❌ Invalid mobile format: $cleanMobile (length: ${cleanMobile.length})');
    return false;
  }

  // Agent-specific payment options dialog with StatefulBuilder
  Future<void> _showAgentPaymentOptions(Reservation reservation) async {
    print(
        '💰 Opening agent payment options dialog for reservation: ${reservation.id}');

    // Reset payment selections
    _selectedPaymentOption = null; // Reset agent option
    _selectedPaymentMethod = null; // Reset payment method
    _mobileNumberController.clear();

    await Get.dialog(
      StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text('Reservation Created Successfully!'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    _bookingForSelf
                        ? 'Your reservation has been created.'
                        : 'Reservation for ${_selectedCustomer?['full_name'] ?? 'customer'} has been created.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reservation ID: ${reservation.id.substring(0, 8)}...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Amount: \$${reservation.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Payment Options',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Payment Method Options for Agent
                  _buildAgentPaymentOptionInDialog(
                    title: 'Process Payment Now',
                    subtitle: 'Collect payment from customer',
                    icon: Icons.payment_rounded,
                    value: 'process',
                    setState: setStateDialog,
                  ),
                  const SizedBox(height: 8),

                  _buildAgentPaymentOptionInDialog(
                    title: 'Mark as Unpaid',
                    subtitle: 'Customer will pay later',
                    icon: Icons.schedule_rounded,
                    value: 'unpaid',
                    setState: setStateDialog,
                  ),
                  const SizedBox(height: 8),

                  _buildAgentPaymentOptionInDialog(
                    title: 'Mark as Paid (Cash)',
                    subtitle: 'Customer paid in cash',
                    icon: Icons.money_rounded,
                    value: 'cash_paid',
                    setState: setStateDialog,
                  ),

                  // Show payment method and mobile field only when "Process Payment Now" is selected
                  if (_selectedPaymentOption == 'process') ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Payment Method:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPaymentMethodChipInDialog(
                            'Card',
                            'card',
                            Icons.credit_card,
                            setState: setStateDialog,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPaymentMethodChipInDialog(
                            'Ecocash',
                            'ecocash',
                            Icons.phone_android,
                            setState: setStateDialog,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Customer Mobile Number (required for Ecocash):',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _mobileNumberController,
                      decoration: const InputDecoration(
                        hintText: '0771234567',
                        prefixText: '+263 ',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        print(
                            '📱 Agent entered customer mobile number: $value');
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Required for Ecocash payments (e.g., 0771234567)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  print('⏭️ Agent selected View Reservation without payment');
                  Get.back();
                  // Navigate to reservation detail without payment
                  Get.offAllNamed(
                    AppRoutes.agentReservationDetail,
                    arguments: {'reservationId': reservation.id},
                  );
                },
                child: const Text('View Reservation'),
              ),
              ElevatedButton(
                onPressed: () async {
                  print(
                      '💳 Agent clicked Continue with payment option: $_selectedPaymentOption');

                  if (_selectedPaymentOption == null) {
                    print('❌ ERROR: No payment option selected');
                    Get.snackbar(
                      'Payment Option Required',
                      'Please select a payment option',
                      backgroundColor: Colors.orange,
                      duration: const Duration(seconds: 3),
                    );
                    return;
                  }

                  if (_selectedPaymentOption == 'process') {
                    // Check if payment method (card/ecocash) is selected
                    if (_selectedPaymentMethod == null) {
                      print(
                          '❌ ERROR: No payment method selected for "Process Payment Now"');
                      Get.snackbar(
                        'Payment Method Required',
                        'Please select Card or Ecocash',
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 3),
                      );
                      return;
                    }

                    // Check mobile number for Ecocash
                    if (_selectedPaymentMethod == 'ecocash') {
                      if (_mobileNumberController.text.isEmpty) {
                        print('❌ ERROR: Mobile number required for Ecocash');
                        Get.snackbar(
                          'Mobile Number Required',
                          'Please enter a mobile number for Ecocash',
                          backgroundColor: Colors.orange,
                          duration: const Duration(seconds: 3),
                        );
                        return;
                      }

                      if (!_isValidZimbabweanMobile(
                          _mobileNumberController.text)) {
                        print(
                            '❌ ERROR: Invalid mobile number for Ecocash: ${_mobileNumberController.text}');
                        Get.snackbar(
                          'Invalid Mobile Number',
                          'Please enter a valid Zimbabwean mobile number (e.g., 0771234567)',
                          backgroundColor: Colors.orange,
                          duration: const Duration(seconds: 3),
                        );
                        return;
                      }
                    }
                  }

                  print(
                      '✅ Proceeding with agent payment option: $_selectedPaymentOption, method: $_selectedPaymentMethod');

                  // Close the dialog first
                  Get.back();

                  // Then process the payment
                  await _processAgentPayment(reservation);
                },
                child: const Text('Continue'),
              ),
            ],
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildAgentPaymentOptionInDialog({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required Function(void Function()) setState,
  }) {
    final isSelected = _selectedPaymentOption == value;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF047BC1).withOpacity(0.1)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? const Color(0xFF047BC1) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            print('🎯 Selected agent payment option: $value');
            setState(() {
              _selectedPaymentOption = value;
              // Reset payment method when option changes
              if (value != 'process') {
                _selectedPaymentMethod = null;
              }
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF047BC1)
                        : Colors.grey.shade200,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF047BC1)
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF047BC1),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodChipInDialog(
    String label,
    String value,
    IconData icon, {
    required Function(void Function()) setState,
  }) {
    final isSelected = _selectedPaymentMethod == value;

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPaymentMethod = selected ? value : null;
        });
      },
      selectedColor: const Color(0xFF047BC1),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
      ),
    );
  }

  Future<void> _processAgentPayment(Reservation reservation) async {
    try {
      switch (_selectedPaymentOption) {
        case 'process':
          await _processCustomerPayment(reservation);
          break;
        case 'unpaid':
          await _markAsUnpaid(reservation);
          break;
        case 'cash_paid':
          await _markAsCashPaid(reservation);
          break;
        default:
          print(
              '❌ ERROR: Unknown agent payment option: $_selectedPaymentOption');
          throw Exception('Unknown payment option');
      }
    } catch (e) {
      Get.snackbar(
        'Payment Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _processCustomerPayment(Reservation reservation) async {
  try {
    print('🔄 Starting agent customer payment process with method: $_selectedPaymentMethod');
    
    // DEBUG: Check what's in storage
    print('🔍 DEBUG: Checking storage for authentication...');
    final userData = storage.read('user_data');
    print('   User data type: ${userData.runtimeType}');
    print('   User data: $userData');
    
    if (userData != null && userData is Map) {
      print('   User data keys: ${userData.keys}');
      print('   Token in user_data: ${userData['token']}');
      print('   Access token in user_data: ${userData['access_token']}');
    }
    
    print('   Direct access_token from storage: ${storage.read('access_token')}');
    print('   Direct token from storage: ${storage.read('token')}');
    
    // Check if we have any token
    final token = userData?['token'] ?? 
                  userData?['access_token'] ?? 
                  storage.read('access_token') ?? 
                  storage.read('token');
    
    if (token == null || token.isEmpty) {
      print('❌ CRITICAL ERROR: No authentication token found anywhere!');
      Get.snackbar(
        'Authentication Error',
        'Your session has expired. Please log in again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
      return;
    }
    
    print('✅ Token found: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
    
    // Show processing dialog
    Get.dialog(
      const AlertDialog(
        title: Text('Processing Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Please wait while we process customer payment...'),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    
    // Use customer's email if available, otherwise use agent's email
    final userDataMap = userData as Map<String, dynamic>?;
    final agentEmail = userDataMap?['email'] ?? '';
    final customerEmail = _selectedCustomer?['email'] ?? agentEmail;
    
    print('📧 Using email: $customerEmail for payment');
    
    if (_selectedPaymentMethod == 'card') {
      print('💳 Processing card payment for reservation: ${reservation.id}');
      final paymentResponse = await paymentController.initiateCardPayment(
        reservationId: reservation.id,
        amount: reservation.totalAmount,
        email: customerEmail,
        promoCode: _promoCodeController.text.isNotEmpty ? _promoCodeController.text : null,
      );
      
      Get.back(); // Close processing dialog
      
      if (paymentResponse != null && paymentResponse.redirectUrl != null) {
        print('✅ Card payment initiated, redirecting to: ${paymentResponse.redirectUrl}');
        // Open the payment URL in webview
        Get.toNamed(
          AppRoutes.paymentWebview,
          arguments: {
            'url': paymentResponse.redirectUrl!,
            'reservationId': reservation.id,
            'paymentId': paymentResponse.payment?.id,
            'isAgentBooking': true,
          },
        );
      } else {
        print('❌ ERROR: Card payment initiation failed');
        Get.snackbar(
          'Payment Failed',
          'Could not initiate card payment',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else if (_selectedPaymentMethod == 'ecocash') {
      print('📱 Processing Ecocash payment with mobile: ${_mobileNumberController.text}');
      final paymentResponse = await paymentController.initiateMobilePayment(
        reservationId: reservation.id,
        amount: reservation.totalAmount,
        phone: _mobileNumberController.text,
        mobileMethod: 'ecocash',
        promoCode: _promoCodeController.text.isNotEmpty ? _promoCodeController.text : null,
      );
      
      Get.back(); // Close processing dialog
      
      if (paymentResponse != null) {
        print('✅ Ecocash payment initiated successfully');
        if (paymentResponse.payment?.pollUrl != null) {
          print('📡 Polling URL available, showing polling screen');
          // Show polling screen
          Get.toNamed(
            AppRoutes.paymentPolling,
            arguments: {
              'paymentId': paymentResponse.payment!.id,
              'reservationId': reservation.id,
              'isAgentBooking': true,
            },
          );
        } else {
          print('📋 No polling URL, showing instructions');
          // Show instructions for mobile payment
          _showMobilePaymentInstructions(reservation);
        }
      } else {
        print('❌ ERROR: Ecocash payment initiation failed');
        Get.snackbar(
          'Payment Failed',
          'Could not initiate mobile payment',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      print('❌ ERROR: Unknown payment method: $_selectedPaymentMethod');
      throw Exception('Unknown payment method');
    }
  } catch (e) {
    print('❌ ERROR in _processCustomerPayment: $e');
    Get.back(); // Close processing dialog
    rethrow;
  }
}

  Future<void> _markAsUnpaid(Reservation reservation) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Marked as Unpaid'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule, size: 48, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'Reservation has been marked as unpaid.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Amount due: \$${reservation.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Customer: ${_selectedCustomer?['full_name'] ?? 'Self'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(
                AppRoutes.agentReservationDetail,
                arguments: {'reservationId': reservation.id},
              );
            },
            child: const Text('View Reservation'),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsCashPaid(Reservation reservation) async {
    Get.dialog(
      AlertDialog(
        title: const Text('Marked as Paid (Cash)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.money, size: 48, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'Reservation has been marked as paid in cash.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Amount received: \$${reservation.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Customer: ${_selectedCustomer?['full_name'] ?? 'Self'}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Please ensure cash is collected and recorded in the system.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(
                AppRoutes.agentReservationDetail,
                arguments: {'reservationId': reservation.id},
              );
            },
            child: const Text('Confirm & View'),
          ),
        ],
      ),
    );
  }

  void _showMobilePaymentInstructions(Reservation reservation) {
    Get.dialog(
      AlertDialog(
        title: const Text('Ecocash Payment Instructions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone_android, size: 48, color: Colors.green),
            const SizedBox(height: 16),
            const Text(
              'To complete payment:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(
              '1. Customer should dial *151*2#\n'
              '2. Select "Pay Bill"\n'
              '3. Enter merchant code: CAR123\n'
              '4. Enter amount: \$${reservation.totalAmount.toStringAsFixed(2)}\n'
              '5. Enter reference: ${reservation.id.substring(0, 8)}',
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Payment will be confirmed automatically.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.offAllNamed(
                AppRoutes.agentReservationDetail,
                arguments: {'reservationId': reservation.id},
              );
            },
            child: const Text('View Reservation'),
          ),
        ],
      ),
    );
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
    final hasVehicle =
        _selectedVehicleId != null && _selectedVehicleId!.isNotEmpty;
    final hasCustomer = _bookingForSelf ||
        (_selectedCustomer != null && _selectedCustomer!.isNotEmpty);

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
              // Customer Selection Section
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
                                    color: const Color(0xFF047BC1)
                                        .withOpacity(0.1),
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: Color(0xFF047BC1),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _selectedCustomer?['full_name'] ??
                                            'Unknown',
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

              // Vehicle Selection Section
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

              // Agent Controls Section
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
              if (hasVehicle &&
                  _selectedDailyRate != null &&
                  _selectedDailyRate! > 0) ...[
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

              // Promo Code & Notes
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
        ));
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
              color:
                  isSelected ? const Color(0xFF047BC1) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color:
                    isSelected ? const Color(0xFF047BC1) : Colors.grey.shade600,
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
                  color: isSelected
                      ? const Color(0xFF047BC1)
                      : Colors.grey.shade600,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(icon, color: const Color(0xFF4F46E5), size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        date != null ? _formatDate(date) : 'Select Date',
                        style: TextStyle(
                          color: date != null
                              ? Colors.black87
                              : Colors.grey.shade500,
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
        ));
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
