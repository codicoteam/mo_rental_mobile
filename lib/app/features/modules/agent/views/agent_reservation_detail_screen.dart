import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/reservation_models/reservation_models.dart';
import '../../reservations/controllers/reservation_controller.dart';

class AgentReservationDetailScreen extends StatefulWidget {
  const AgentReservationDetailScreen({super.key});

  @override
  State<AgentReservationDetailScreen> createState() =>
      _AgentReservationDetailScreenState();
}

class _AgentReservationDetailScreenState
    extends State<AgentReservationDetailScreen> with TickerProviderStateMixin {
  final ReservationController controller = Get.find<ReservationController>();
  late String reservationId;
  Reservation? reservation;
  bool isLoading = true;
  String error = '';
  late AnimationController _fadeController;
  // ignore: unused_field
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  // ignore: unused_field
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    final args = Get.arguments as Map<String, dynamic>?;
    reservationId = args?['reservationId'] ?? '';
    if (reservationId.isNotEmpty) {
      _loadReservation();
    } else {
      setState(() {
        error = 'No reservation ID provided';
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadReservation() async {
    try {
      setState(() {
        isLoading = true;
        error = '';
      });

      final loadedReservation =
          await controller.fetchReservationById(reservationId);

      setState(() {
        reservation = loadedReservation;
        isLoading = false;
      });

      if (loadedReservation != null) {
        _fadeController.forward();
        _slideController.forward();
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  // ignore: unused_element
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('EEE, MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEE, MMM dd, yyyy').format(date);
  }

  Widget _buildInfoRow(String label, String value, {bool isImportant = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF047BC1),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: isImportant ? 16 : 14,
                fontWeight: isImportant ? FontWeight.w700 : FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'confirmed':
        color = const Color.fromRGBO(76, 175, 80, 1);
        icon = Icons.check_circle_rounded;
        break;
      case 'pending':
        color = const Color.fromRGBO(255, 152, 0, 1);
        icon = Icons.access_time_rounded;
        break;
      case 'cancelled':
        color = const Color.fromRGBO(244, 67, 54, 1);
        icon = Icons.cancel_rounded;
        break;
      case 'completed':
        color = const Color(0xFF047BC1);
        icon = Icons.done_all_rounded;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
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
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Reservation Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF047BC1),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReservation,
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: const Color(0xFF047BC1),
                  ),
                  const SizedBox(height: 20),
                  const Text('Loading reservation...'),
                ],
              ),
            )
          : error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 20),
                      Text(error),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadReservation,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : reservation == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 20),
                          const Text('Reservation not found'),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Reservation #${reservation!.id.substring(0, 8)}...',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    _buildStatusBadge(reservation!.status),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (reservation!.createdByAgent ?? false)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF047BC1)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.person,
                                            size: 14, color: Color(0xFF047BC1)),
                                        SizedBox(width: 4),
                                        Text(
                                          'Agent Booking',
                                          style: TextStyle(
                                            color: Color(0xFF047BC1),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Vehicle Information
                          _buildSectionCard(
                            title: 'Vehicle Information',
                            icon: Icons.directions_car_rounded,
                            child: Column(
                              children: [
                                _buildInfoRow(
                                  'Vehicle',
                                  reservation!.vehicleDetails?.displayName ??
                                      'Unknown',
                                  isImportant: true,
                                ),
                                if (reservation!.vehicleDetails?.licensePlate !=
                                    null)
                                  _buildInfoRow(
                                      'License Plate',
                                      reservation!
                                          .vehicleDetails!.licensePlate),
                                _buildInfoRow('Seats',
                                    '${reservation!.vehicleDetails?.seatingCapacity ?? 'N/A'}'),
                              ],
                            ),
                          ),

                          // Rental Period
                          _buildSectionCard(
                            title: 'Rental Period',
                            icon: Icons.calendar_month_rounded,
                            child: Column(
                              children: [
                                _buildInfoRow('Pickup Date',
                                    _formatDate(reservation!.startDate),
                                    isImportant: true),
                                _buildInfoRow('Return Date',
                                    _formatDate(reservation!.endDate),
                                    isImportant: true),
                                _buildInfoRow('Duration',
                                    '${reservation!.durationInDays} days'),
                              ],
                            ),
                          ),

                          // Pricing Details
                          _buildSectionCard(
                            title: 'Pricing Details',
                            icon: Icons.attach_money_rounded,
                            child: Column(
                              children: [
                                _buildInfoRow('Base Rate',
                                    '\$${reservation!.totalAmount.toStringAsFixed(2)}'),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF047BC1),
                                        Color(0xFF4F46E5)
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total Amount',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        '\$${reservation!.totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Driver Information
                          _buildSectionCard(
                            title: 'Driver Information',
                            icon: Icons.person_outline_rounded,
                            child: Column(
                              children: [
                                _buildInfoRow('User ID', reservation!.userId),
                                // Add more driver info if available
                              ],
                            ),
                          ),

                          // Agent Information (if applicable)
                          if (reservation!.createdByAgent ?? false)
                            _buildSectionCard(
                              title: 'Agent Information',
                              icon: Icons.security_rounded,
                              child: Column(
                                children: [
                                  _buildInfoRow('Booked by', 'Agent (You)'),
                                  if (reservation!.agentNotes != null)
                                    _buildInfoRow('Agent Notes',
                                        reservation!.agentNotes!),
                                  if (reservation!.priorityLevel != null)
                                    _buildInfoRow(
                                        'Priority',
                                        reservation!.priorityLevel!
                                            .toUpperCase()),
                                ],
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Action Buttons
                          if (reservation!.status.toLowerCase() == 'pending')
                            Container(
                              height: 50,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.shade500,
                                    Colors.red.shade700,
                                  ],
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: () {
                                    Get.dialog(
                                      AlertDialog(
                                        title: const Text('Cancel Reservation'),
                                        content: const Text(
                                            'Are you sure you want to cancel this reservation?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Get.back(),
                                            child: const Text('No'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Get.back();
                                              // Implement cancel functionality
                                              Get.snackbar(
                                                'Feature Coming Soon',
                                                'Cancel reservation will be available soon',
                                                backgroundColor: Colors.orange,
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            child: const Text('Yes, Cancel'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: const Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.cancel,
                                            color: Colors.white, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Cancel Reservation',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: () => Get.back(),
                                borderRadius: BorderRadius.circular(12),
                                child: const Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.arrow_back,
                                          color: Colors.black87),
                                      SizedBox(width: 8),
                                      Text(
                                        'Back to List',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
    );
  }
}
