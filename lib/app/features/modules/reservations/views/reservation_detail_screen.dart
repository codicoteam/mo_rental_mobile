import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/reservation_controller.dart';
import '../../../data/models/reservation_models/reservation_models.dart';

class ReservationDetailScreen extends StatefulWidget {
  const ReservationDetailScreen({super.key});

  @override
  State<ReservationDetailScreen> createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> 
    with TickerProviderStateMixin {
  final ReservationController controller = Get.find<ReservationController>();
  late String reservationId;
  Reservation? reservation;
  bool isLoading = true;
  String error = '';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
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

      final loadedReservation = await controller.fetchReservationById(reservationId);
      
      setState(() {
        reservation = loadedReservation;
        isLoading = false;
      });
      
      // Start animations after loading
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

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('EEE, MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEE, MMM dd, yyyy').format(date);
  }

  Widget _buildInfoRow(String label, String value, {bool isImportant = false}) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '$label:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF047BC1),
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: isImportant ? 17 : 15,
                  fontWeight: isImportant ? FontWeight.w700 : FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
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
              letterSpacing: 0.5,
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
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
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
                color: Colors.grey.shade100.withOpacity(0.8),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.grey.shade50.withOpacity(0.5),
                blurRadius: 5,
                spreadRadius: 0,
                offset: const Offset(0, 2),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: const Color(0xFF047BC1),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation(
                        const Color(0xFF047BC1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Loading reservation details...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
          : error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red.shade50,
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade100,
                              Colors.red.shade50,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: _loadReservation,
                            borderRadius: BorderRadius.circular(14),
                            child: const Center(
                              child: Text(
                                'Try Again',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : reservation == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.grey.shade100,
                                  Colors.grey.shade50,
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Reservation not found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 160,
                          floating: false,
                          pinned: true,
                          backgroundColor: Colors.white,
                          surfaceTintColor: Colors.white,
                          elevation: 0,
                          flexibleSpace: FlexibleSpaceBar(
                            collapseMode: CollapseMode.pin,
                            background: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white,
                                    Colors.grey.shade50,
                                  ],
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(top: 70, left: 24, right: 24, bottom: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Reservation Details',
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black87,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'ID: ${reservation!.id.substring(0, 8)}...',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade600,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFF047BC1).withOpacity(0.1),
                                            const Color(0xFF4F46E5).withOpacity(0.1),
                                          ],
                                        ),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.refresh_rounded,
                                          color: const Color(0xFF047BC1),
                                          size: 24,
                                        ),
                                        onPressed: _loadReservation,
                                        tooltip: 'Refresh',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header Card with Status
                                SlideTransition(
                                  position: _slideAnimation,
                                  child: FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white,
                                            Color.fromRGBO(240, 245, 255, 1),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: Colors.grey.shade100,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'Status',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade600,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              _buildStatusBadge(reservation!.status),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  Icons.calendar_today_rounded,
                                                  size: 18,
                                                  color: const Color(0xFF4F46E5),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  'Created: ${_formatDateTime(reservation!.createdAt)}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
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
                                        reservation!.vehicleDetails?.displayName ?? 'Unknown',
                                        isImportant: true,
                                      ),
                                      if (reservation!.vehicleDetails?.licensePlate != null)
                                        _buildInfoRow('License Plate', reservation!.vehicleDetails!.licensePlate),
                                      if (reservation!.vehicleDetails?.color != null)
                                        _buildInfoRow('Color', reservation!.vehicleDetails!.color!),
                                      if (reservation!.vehicleDetails?.fuelType != null)
                                        _buildInfoRow('Fuel Type', reservation!.vehicleDetails!.fuelType!),
                                      _buildInfoRow('Seats', '${reservation!.vehicleDetails?.seatingCapacity ?? 'N/A'}'),
                                    ],
                                  ),
                                ),

                                // Rental Period
                                _buildSectionCard(
                                  title: 'Rental Period',
                                  icon: Icons.calendar_month_rounded,
                                  child: Column(
                                    children: [
                                      _buildInfoRow('Pickup Date', _formatDate(reservation!.startDate), isImportant: true),
                                      _buildInfoRow('Return Date', _formatDate(reservation!.endDate), isImportant: true),
                                      _buildInfoRow('Duration', '${reservation!.durationInDays} days'),
                                    ],
                                  ),
                                ),

                                // Pricing Details
                                _buildSectionCard(
                                  title: 'Pricing Details',
                                  icon: Icons.attach_money_rounded,
                                  child: Column(
                                    children: [
                                      _buildInfoRow('Base Rate', '\$${reservation!.totalAmount.toStringAsFixed(2)}'),
                                      _buildInfoRow('Status', reservation!.statusText),
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                fontSize: 24,
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
                                      // Add more driver info if available in your model
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Action Buttons
                                if (reservation!.status.toLowerCase() == 'pending')
                                  SlideTransition(
                                    position: _slideAnimation,
                                    child: Container(
                                      height: 56,
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(14),
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color.fromRGBO(244, 67, 54, 1),
                                            const Color.fromRGBO(229, 57, 53, 1),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color.fromRGBO(244, 67, 54, 0.4),
                                            blurRadius: 16,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(14),
                                        child: InkWell(
                                          onTap: () {
                                            Get.snackbar(
                                              'Coming Soon',
                                              'Cancel feature will be available soon',
                                              backgroundColor: Colors.orange,
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(14),
                                          child: const Center(
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.cancel_rounded,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(width: 12),
                                                Text(
                                                  'Cancel Reservation',
                                                  style: TextStyle(
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
                                  ),

                                SlideTransition(
                                  position: _slideAnimation,
                                  child: Container(
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
                                        onTap: () => Get.back(),
                                        borderRadius: BorderRadius.circular(14),
                                        child: const Center(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.arrow_back_rounded,
                                                color: Colors.black87,
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Back to List',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}