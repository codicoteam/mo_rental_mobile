import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../../domain/repositories/reservation_repository.dart';
import '../../../data/models/reservation_models/reservation_models.dart';

class ReservationController extends GetxController {
  late ReservationRepository _repository;

  final Rx<AvailabilityResponse?> availabilityResult =
      Rx<AvailabilityResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final Rx<DateTime> selectedStartDate = Rx<DateTime>(DateTime.now());
  final Rx<DateTime> selectedEndDate =
      Rx<DateTime>(DateTime.now().add(const Duration(days: 1)));
  final RxString selectedVehicleId = ''.obs;
  final RxList<Reservation> reservationsList = <Reservation>[].obs;
  final RxBool isLoadingReservations = false.obs;
  final RxString reservationsError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _repository = Get.find<ReservationRepository>();
    print('🎮 ReservationController initialized');
  }

  // Check vehicle availability
  Future<void> checkAvailability({
    String? vehicleId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      availabilityResult.value = null;

      // Validate dates
      if (endDate.isBefore(startDate)) {
        throw Exception('End date must be after start date');
      }

      if (startDate.isBefore(DateTime.now())) {
        throw Exception('Start date cannot be in the past');
      }

      final request = AvailabilityRequest(
        vehicleId: vehicleId,
        start: startDate,
        end: endDate,
      );

      final result = await _repository.checkVehicleAvailability(request);
      availabilityResult.value = result;

      if (result.available) {
        print('✅ Vehicle is available for selected dates');
      } else {
        print('❌ Vehicle is not available for selected dates');
        if (result.conflicts != null && result.conflicts!.isNotEmpty) {
          print('   Conflicts found: ${result.conflicts!.length}');
        }
      }
    } catch (e) {
      error.value = e.toString();
      print('❌ Error checking availability: $e');
      Get.snackbar(
        'Availability Check Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== CREATE RESERVATION (UPDATED WITH AGENT PARAMETERS) ====================
  Future<CreateReservationResponse?> createReservation({
    required String vehicleId,
    required String vehicleModelId,
    required DateTime pickupDate,
    required DateTime dropoffDate,
    required String branchId,
    required double dailyRate,
    int durationDays = 1,
    String? promoCode,
    String? notes,
    // NEW AGENT PARAMETERS (with defaults)
    bool createdByAgent = false,
    String? agentNotes,
    String? customerId,
    bool overrideAvailability = false,
    String? priorityLevel,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Get current user data
      final storage = GetStorage();
      final userData = storage.read('user_data') ?? {};

      // Determine the actual user ID to use
      String userId;
      if (customerId != null && customerId.isNotEmpty) {
        // Agent is booking for a specific customer
        userId = customerId;
      } else {
        // Regular customer booking or agent booking for themselves
        userId = userData['id'] ?? userData['_id'] ?? '';
      }

      // Create pricing breakdown
      final baseTotal = dailyRate * durationDays;

      // Generate a unique reservation code
      final reservationCode = createdByAgent 
          ? 'AGENT-${DateTime.now().millisecondsSinceEpoch}'
          : 'RES-${DateTime.now().millisecondsSinceEpoch}';

      final pricing = ReservationPricing(
        currency: 'USD',
        breakdown: [
          PriceBreakdownItem(
            label: 'Base daily rate',
            quantity: durationDays,
            unitAmount: dailyRate,
            total: baseTotal,
          ),
        ],
        fees: [
          ReservationFee(
            code: 'SERVICE_FEE',
            amount: 10.00,
          ),
        ],
        taxes: [
          ReservationTax(
            code: 'VAT',
            rate: 0.15,
            amount: baseTotal * 0.15,
          ),
        ],
        discounts: promoCode != null
            ? [
                ReservationDiscount(
                  promoCodeId: promoCode,
                  amount: 5.00,
                ),
              ]
            : [],
        grandTotal: baseTotal +
            10.00 +
            (baseTotal * 0.15) -
            (promoCode != null ? 5.00 : 0.00),
        computedAt: DateTime.now(),
      );

      // Create driver snapshot from user data
      final driverSnapshot = ReservationDriverSnapshot(
        fullName: userData['full_name'] ?? 'Unknown',
        phone: userData['phone'] ?? '',
        email: userData['email'] ?? '',
        driverLicense: ReservationDriverLicense(
          number: userData['driver_license']?['number'] ?? 'NOT_PROVIDED',
          country: userData['driver_license']?['country'] ?? 'ZW',
          licenseClass: userData['driver_license']?['class'] ?? 'Class 4',
          expiresAt: DateTime.now().add(const Duration(days: 365 * 5)),
          verified: false,
        ),
      );

      // Create payment summary
      final paymentSummary = ReservationPaymentSummary(
        status: 'unpaid',
        paidTotal: 0.00,
        outstanding: pricing.grandTotal,
        lastPaymentAt: null,
      );

      // Create the request with agent parameters
      final request = CreateReservationRequest(
        createdChannel: createdByAgent ? 'web' : 'mobile',
        vehicleId: vehicleId,
        vehicleModelId: vehicleModelId,
        code: reservationCode,
        pickup: BranchTime(
          branchId: branchId,
          at: pickupDate,
        ),
        dropoff: BranchTime(
          branchId: branchId,
          at: dropoffDate,
        ),
        pricing: pricing,
        paymentSummary: paymentSummary,
        driverSnapshot: driverSnapshot,
        notes: notes,
        userId: userId,
        // Agent-specific fields (only included if createdByAgent is true)
        createdByAgent: createdByAgent ? true : null,
        agentId: createdByAgent ? (userData['id'] ?? userData['_id'] ?? '') : null,
        agentNotes: agentNotes,
        customerId: customerId,
        overrideAvailability: overrideAvailability ? true : null,
        priorityLevel: priorityLevel,
      );

      print('📤 Creating reservation request...');
      print('📦 Request: ${request.toJson()}');
      final response = await _repository.createReservation(request);

      if (response.success) {
        print('✅ Reservation created successfully!');
        Get.snackbar(
          'Success',
          'Reservation created successfully!\nID: ${response.data?.id ?? 'Unknown'}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );

        // Clear availability results
        availabilityResult.value = null;

        return response;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      error.value = e.toString();
      print('❌ Error creating reservation: $e');
      Get.snackbar(
        'Reservation Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== CREATE AGENT RESERVATION (FOR BACKWARDS COMPATIBILITY) ====================
  Future<CreateReservationResponse?> createAgentReservation({
    required String vehicleId,
    required String vehicleModelId,
    required DateTime pickupDate,
    required DateTime dropoffDate,
    required String branchId,
    required double dailyRate,
    int durationDays = 1,
    String? promoCode,
    String? notes,
    bool createdByAgent = false,
    String? agentNotes,
    String? customerId,
    bool overrideAvailability = false,
    String? priorityLevel,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Get agent user data
      final storage = GetStorage();
      final agentData = storage.read('user_data') ?? {};
      final agentId = agentData['id'] ?? agentData['_id'] ?? '';

      // Generate reservation code
      final reservationCode = 'AGENT-${DateTime.now().millisecondsSinceEpoch}';

      // Create pricing
      final baseTotal = dailyRate * durationDays;
      final pricing = ReservationPricing(
        currency: 'USD',
        breakdown: [
          PriceBreakdownItem(
            label: 'Base daily rate',
            quantity: durationDays,
            unitAmount: dailyRate,
            total: baseTotal,
          ),
        ],
        fees: [
          ReservationFee(code: 'SERVICE_FEE', amount: 10.00),
        ],
        taxes: [
          ReservationTax(code: 'VAT', rate: 0.15, amount: baseTotal * 0.15),
        ],
        discounts: promoCode != null
            ? [ReservationDiscount(promoCodeId: promoCode, amount: 5.00)]
            : [],
        grandTotal: baseTotal + 10.00 + (baseTotal * 0.15) - (promoCode != null ? 5.00 : 0.00),
        computedAt: DateTime.now(),
      );

      // Create driver snapshot
      final driverSnapshot = ReservationDriverSnapshot(
        fullName: agentData['full_name'] ?? 'Unknown',
        phone: agentData['phone'] ?? '',
        email: agentData['email'] ?? '',
        driverLicense: ReservationDriverLicense(
          number: agentData['driver_license']?['number'] ?? 'NOT_PROVIDED',
          country: agentData['driver_license']?['country'] ?? 'ZW',
          licenseClass: agentData['driver_license']?['class'] ?? 'Class 4',
          expiresAt: DateTime.now().add(const Duration(days: 365 * 5)),
          verified: false,
        ),
      );

      // Create payment summary
      final paymentSummary = ReservationPaymentSummary(
        status: 'unpaid',
        paidTotal: 0.00,
        outstanding: pricing.grandTotal,
        lastPaymentAt: null,
      );

      // Create agent-specific request
      final request = CreateReservationRequest(
        createdChannel: 'web',
        vehicleId: vehicleId,
        vehicleModelId: vehicleModelId,
        code: reservationCode,
        pickup: BranchTime(branchId: branchId, at: pickupDate),
        dropoff: BranchTime(branchId: branchId, at: dropoffDate),
        pricing: pricing,
        paymentSummary: paymentSummary,
        driverSnapshot: driverSnapshot,
        notes: notes,
        // Use customerId if provided, otherwise use agentId
        userId: customerId ?? agentId,
        // Agent-specific fields
        createdByAgent: createdByAgent,
        agentId: createdByAgent ? agentId : null,
        agentNotes: agentNotes,
        customerId: customerId,
        overrideAvailability: overrideAvailability,
        priorityLevel: priorityLevel,
      );

      print('📤 Creating agent reservation...');
      final response = await _repository.createReservation(request);

      if (response.success) {
        print('✅ Agent reservation created successfully!');
        Get.snackbar(
          'Success',
          'Reservation created successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return response;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      error.value = e.toString();
      print('❌ Error creating agent reservation: $e');
      Get.snackbar('Error', e.toString(), backgroundColor: Colors.red);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Set dates
  void setStartDate(DateTime date) {
    selectedStartDate.value = date;
  }

  void setEndDate(DateTime date) {
    selectedEndDate.value = date;
  }

  void setVehicleId(String vehicleId) {
    selectedVehicleId.value = vehicleId;
  }

  // Calculate duration in days
  int getDurationInDays() {
    return selectedEndDate.value.difference(selectedStartDate.value).inDays;
  }

  // Calculate estimated cost
  double? getEstimatedCost() {
    if (availabilityResult.value?.vehicle != null) {
      final days = getDurationInDays();
      final dailyRate = availabilityResult.value!.vehicle!.dailyRate;
      return days * dailyRate;
    }
    return null;
  }

  // Clear results
  void clearResults() {
    availabilityResult.value = null;
    error.value = '';
  }

  // Format date for display
  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Check if dates are valid
  bool areDatesValid() {
    return selectedEndDate.value.isAfter(selectedStartDate.value) &&
        selectedStartDate.value
            .isAfter(DateTime.now().subtract(const Duration(days: 1)));
  }

  Future<void> fetchReservations({
    String? status,
    String? vehicleId,
    DateTime? pickupFrom,
    DateTime? pickupTo,
  }) async {
    try {
      isLoadingReservations.value = true;
      reservationsError.value = '';
      reservationsList.clear();

      final reservations = await _repository.getReservations(
        status: status,
        vehicleId: vehicleId,
        pickupFrom: pickupFrom,
        pickupTo: pickupTo,
      );

      reservationsList.assignAll(reservations);

      print('✅ Fetched ${reservations.length} reservation(s)');
    } catch (e) {
      reservationsError.value = e.toString();
      print('❌ Error fetching reservations: $e');
      Get.snackbar(
        'Fetch Failed',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingReservations.value = false;
    }
  }

  // Fetch a single reservation by ID
  Future<Reservation?> fetchReservationById(String id) async {
    try {
      isLoading.value = true;
      error.value = '';

      final reservation = await _repository.getReservationById(id);
      print('✅ Fetched reservation: ${reservation.id}');

      return reservation;
    } catch (e) {
      error.value = e.toString();
      print('❌ Error fetching reservation: $e');
      Get.snackbar(
        'Reservation Not Found',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Filter reservations by status
  List<Reservation> getReservationsByStatus(String status) {
    return reservationsList
        .where((reservation) =>
            reservation.status.toLowerCase() == status.toLowerCase())
        .toList();
  }

  // Get pending reservations
  List<Reservation> get pendingReservations =>
      getReservationsByStatus('pending');

  // Get confirmed reservations
  List<Reservation> get confirmedReservations =>
      getReservationsByStatus('confirmed');

  // Get completed reservations
  List<Reservation> get completedReservations =>
      getReservationsByStatus('completed');

  // Get cancelled reservations
  List<Reservation> get cancelledReservations =>
      getReservationsByStatus('cancelled');

  // Add agent-specific reservation filters
  List<Reservation> get agentReservations {
    return reservationsList.where((reservation) => 
      reservation.createdByAgent == true
    ).toList();
  }

  List<Reservation> get customerReservations {
    return reservationsList.where((reservation) => 
      reservation.createdByAgent == false
    ).toList();
  }
}