import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/reservation_models/reservation_models.dart';
import '../controllers/reservation_controller.dart';

class ReservationListScreen extends StatefulWidget {
  const ReservationListScreen({super.key});

  @override
  State<ReservationListScreen> createState() => _ReservationListScreenState();
}

class _ReservationListScreenState extends State<ReservationListScreen>
    with TickerProviderStateMixin {
  final ReservationController controller = Get.find<ReservationController>();
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter =
      'all'; // all, pending, confirmed, completed, cancelled
  bool _isRefreshing = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

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

    _slideAnimation = Tween<double>(begin: -50.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReservations();
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isRefreshing = true;
    });
    await controller.fetchReservations();
    setState(() {
      _isRefreshing = false;
    });
  }

  List<Reservation> get _filteredReservations {
    if (_selectedFilter == 'all') {
      return controller.reservationsList;
    }
    return controller.getReservationsByStatus(_selectedFilter);
  }

  // ignore: unused_element
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy • hh:mm a').format(dateTime);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Widget _buildReservationCard(Reservation reservation, int index) {
    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
              0, _slideAnimation.value * (1 - (index * 0.1).clamp(0.0, 1.0))),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200.withOpacity(0.8),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.grey.shade100.withOpacity(0.5),
              blurRadius: 5,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => _viewReservationDetails(reservation),
            borderRadius: BorderRadius.circular(20),
            splashColor: const Color(0xFF047BC1).withOpacity(0.1),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Status Icon with Glassmorphism
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [
                          reservation.statusColor.withOpacity(0.15),
                          reservation.statusColor.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: reservation.statusColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        _getStatusIcon(reservation.status),
                        color: reservation.statusColor,
                        size: 28,
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Reservation Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                reservation.vehicleDetails?.displayName ??
                                    'Vehicle',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [
                                    reservation.statusColor.withOpacity(0.1),
                                    reservation.statusColor.withOpacity(0.05),
                                  ],
                                ),
                                border: Border.all(
                                  color:
                                      reservation.statusColor.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                reservation.statusText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: reservation.statusColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${_formatDate(reservation.startDate)} - ${_formatDate(reservation.endDate)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.attach_money_rounded,
                                size: 16,
                                color: Colors.green.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              reservation.formattedTotalAmount,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.grey.shade100,
                                    Colors.grey.shade50,
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'pending':
        return Icons.access_time_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'completed':
        return Icons.done_all_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  void _viewReservationDetails(Reservation reservation) {
    Get.toNamed(
      '/reservations/detail',
      arguments: {'reservationId': reservation.id},
    );
  }

  void _createNewReservation() {
    Get.toNamed('/reservations/create');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // AppBar with glassmorphism effect
          SliverAppBar(
            expandedHeight: 140,
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
                  padding: const EdgeInsets.only(
                      top: 70, left: 24, right: 24, bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // CHANGED: from CrossAxisAlignment.end
                    children: [
                      Expanded(
                        // ADDED: Wrap Column with Expanded
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize
                              .min, // CHANGED: from MainAxisAlignment.end
                          children: [
                            const Text(
                              'My Reservations',
                              style: TextStyle(
                                fontSize: 24, // REDUCED: from 28 to 24
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1, // ADDED
                              overflow: TextOverflow.ellipsis, // ADDED
                            ),
                            const SizedBox(height: 2), // REDUCED: from 4 to 2
                            Obx(() => Text(
                                  '${controller.reservationsList.length} total reservations',
                                  style: TextStyle(
                                    fontSize: 12, // REDUCED: from 14 to 12
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1, // ADDED
                                  overflow: TextOverflow.ellipsis, // ADDED
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16), // ADDED: Add spacing
                      Container(
                        width: 40, // ADDED: Fixed width
                        height: 40, // ADDED: Fixed height
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
                            size: 20, // REDUCED: from 24 to 20
                          ),
                          onPressed: _loadReservations,
                          tooltip: 'Refresh',
                          padding:
                              EdgeInsets.zero, // ADDED: Remove default padding
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Filter Chips
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _slideController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_slideAnimation.value, 0),
                  child: child,
                );
              },
              child: Container(
                height: 70,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('All', 'all', Icons.all_inclusive_rounded),
                    _buildFilterChip(
                        'Pending', 'pending', Icons.access_time_rounded),
                    _buildFilterChip(
                        'Confirmed', 'confirmed', Icons.check_circle_rounded),
                    _buildFilterChip(
                        'Completed', 'completed', Icons.done_all_rounded),
                    _buildFilterChip(
                        'Cancelled', 'cancelled', Icons.cancel_rounded),
                  ],
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey.shade50,
                      Colors.grey.shade100,
                    ],
                  ),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1.5,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by ID, vehicle name...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.search_rounded,
                        color: const Color(0xFF4F46E5),
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                  onChanged: (value) {
                    // Implement search functionality if needed
                  },
                ),
              ),
            ),
          ),

          // Reservations List
          SliverFillRemaining(
            child: controller.isLoadingReservations.value || _isRefreshing
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
                          'Loading reservations...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : controller.reservationsError.value.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.shade50,
                              ),
                              child: Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red,
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                controller.reservationsError.value,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF047BC1),
                                    Color(0xFF4F46E5)
                                  ],
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: _loadReservations,
                                  borderRadius: BorderRadius.circular(12),
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
                    : _filteredReservations.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.grey.shade100,
                                        Colors.grey.shade50,
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today_rounded,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _selectedFilter == 'all'
                                      ? 'No Reservations Yet'
                                      : 'No $_selectedFilter reservations',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _selectedFilter == 'all'
                                      ? 'Start by creating your first reservation'
                                      : 'Try a different filter or create a new booking',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                if (_selectedFilter == 'all')
                                  Container(
                                    height: 52,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF047BC1),
                                          Color(0xFF4F46E5)
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF4F46E5)
                                              .withOpacity(0.3),
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
                                        onTap: _createNewReservation,
                                        borderRadius: BorderRadius.circular(14),
                                        child: const Center(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.add_rounded,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'Make Your First Booking',
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
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadReservations,
                            color: const Color(0xFF047BC1),
                            backgroundColor: Colors.white,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 100),
                              itemCount: _filteredReservations.length,
                              itemBuilder: (context, index) =>
                                  _buildReservationCard(
                                      _filteredReservations[index], index),
                            ),
                          ),
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _createNewReservation,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedFilter = value;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                    )
                  : LinearGradient(
                      colors: [
                        Colors.grey.shade100,
                        Colors.grey.shade50,
                      ],
                    ),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF047BC1).withOpacity(0.3)
                    : Colors.grey.shade200,
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
