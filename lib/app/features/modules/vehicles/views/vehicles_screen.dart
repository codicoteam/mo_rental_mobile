// lib/features/modules/vehicles/views/vehicles_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/vehicle_models/vehicle.dart';
import '../controllers/vehicle_controller.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen>
    with TickerProviderStateMixin {  // CHANGED: SingleTickerProviderStateMixin -> TickerProviderStateMixin
  final VehicleController controller = Get.find<VehicleController>();
  final TextEditingController searchController = TextEditingController();
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

    searchController.addListener(_onSearchChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = searchController.text;
    controller.searchVehicles(query);
  }

  void _showVehicleDetail(Vehicle vehicle) {
    // Create new animation controllers for the dialog
    final dialogFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    final dialogFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: dialogFadeController, curve: Curves.easeOut),
    );

    // Start the animation
    dialogFadeController.forward();

    Get.dialog(
      FadeTransition(
        opacity: dialogFadeAnimation,
        child: Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: Builder(
            builder: (dialogContext) {
              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.8,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF047BC1),
                              const Color(0xFF4F46E5),
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.directions_car_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                vehicle.displayName,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Vehicle Image
                      if (vehicle.photos.isNotEmpty)
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            image: DecorationImage(
                              image: NetworkImage(vehicle.photos.first),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.1),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.3),
                                ],
                              ),
                            ),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                margin: const EdgeInsets.all(16),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  vehicle.plateNumber,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Vehicle Info Grid
                            SizedBox(
                              height: 200,
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 2,
                                childAspectRatio: 3,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                children: [
                                  _buildInfoCard('VIN', vehicle.vin,
                                      Icons.confirmation_number_rounded),
                                  _buildInfoCard('Model', vehicle.vehicleModel.fullName,
                                      Icons.model_training_rounded),
                                  _buildInfoCard('Branch', vehicle.locationInfo,
                                      Icons.location_on_rounded),
                                  _buildInfoCard(
                                      'Color', vehicle.color, Icons.color_lens_rounded),
                                  _buildInfoCard('Odometer', '${vehicle.odometerKm} km',
                                      Icons.speed_rounded),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Status Indicators
                            const Text(
                              'Status',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _buildStatusCard('Available', vehicle.isAvailable,
                                    Icons.check_circle_rounded),
                                const SizedBox(width: 12),
                                _buildStatusCard('Active', vehicle.isActive,
                                    Icons.power_settings_new_rounded),
                                const SizedBox(width: 12),
                                _buildStatusCard('Service', vehicle.needsService,
                                    Icons.build_rounded),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Features
                            if (vehicle.vehicleModel.features.isNotEmpty) ...[
                              const Text(
                                'Features',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: vehicle.vehicleModel.features.map((feature) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF047BC1).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color:
                                            const Color(0xFF047BC1).withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      feature,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF047BC1),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],

                            const SizedBox(height: 32),

                            // Close Button
                            Container(
                              height: 56,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  width: 1.5,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  onTap: () {
                                    dialogFadeController.dispose();
                                    Get.back();
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: const Center(
                                    child: Text(
                                      'Close',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: const Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String label, bool isTrue, IconData icon) {
    final color = isTrue ? const Color(0xFF4CAF50) : Colors.grey.shade400;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isTrue ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isTrue ? color.withOpacity(0.3) : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isTrue ? color.withOpacity(0.2) : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: isTrue ? color : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isTrue ? color : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFiltersDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter Vehicles',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.black87,
                      size: 20,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Status Filter
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _buildFilterChip('All Status', null),
                _buildFilterChip('Active', 'active'),
                _buildFilterChip('Inactive', 'inactive'),
                _buildFilterChip('Maintenance', 'maintenance'),
              ],
            ),

            const SizedBox(height: 24),

            // Availability Filter
            const Text(
              'Availability',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: const [
                _buildFilterChip('All Availability', null),
                _buildFilterChip('Available', 'available'),
                _buildFilterChip('Reserved', 'reserved'),
                _buildFilterChip('Rented', 'rented'),
              ],
            ),

            const SizedBox(height: 24),

            // Quick Filters
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Available Only',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Obx(() => Switch(
                            value: controller.filterAvailableOnly.value,
                            onChanged: (value) {
                              controller.filterAvailableOnly.value = value;
                            },
                            activeColor: const Color(0xFF047BC1),
                          )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Active Only',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Obx(() => Switch(
                            value: controller.filterActiveOnly.value,
                            onChanged: (value) {
                              controller.filterActiveOnly.value = value;
                            },
                            activeColor: const Color(0xFF047BC1),
                          )),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
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
                        onTap: () {
                          controller.clearFilters();
                          Get.back();
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: const Center(
                          child: Text(
                            'Clear All',
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withOpacity(0.3),
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
                          controller.applyFilters();
                          Get.back();
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: const Center(
                          child: Text(
                            'Apply Filters',
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
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
          crossAxisAlignment: CrossAxisAlignment.start, // Keep as start
          children: [
            Expanded( // ADDED: Wrap the Column with Expanded
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Vehicle Fleet',
                    style: TextStyle(
                      fontSize: 24, // REDUCED: from 28 to 24
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1, // ADDED: Limit to 1 line
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2), // REDUCED: from 4 to 2
                  Obx(() => Text(
                    '${controller.vehicles.length} total vehicles',
                    style: TextStyle(
                      fontSize: 12, // REDUCED: from 14 to 12
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1, // ADDED: Limit to 1 line
                    overflow: TextOverflow.ellipsis,
                  )),
                ],
              ),
            ),
            const SizedBox(width: 16), // ADDED: Add spacing
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                    icon: const Icon(
                      Icons.filter_alt_rounded,
                      color: Color(0xFF047BC1),
                      size: 20, // REDUCED: from 24 to 20
                    ),
                    onPressed: _showFiltersDialog,
                    padding: EdgeInsets.zero, // ADDED: Remove padding
                  ),
                ),
                const SizedBox(width: 8),
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
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Color(0xFF047BC1),
                      size: 20, // REDUCED: from 24 to 20
                    ),
                    onPressed: controller.refresh,
                    padding: EdgeInsets.zero, // ADDED: Remove padding
                  ),
                ),
              ],
            ),
          ],
        ),
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
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by plate, VIN, model, branch...',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(left: 4),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF4F46E5),
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
                ),
              ),
            ),
          ),

          // Statistics
          SliverToBoxAdapter(
            child: Obx(() {
              if (!controller.isLoading.value &&
                  controller.vehicles.isNotEmpty) {
                final available = controller.getAvailableVehicles().length;
                final needService =
                    controller.getVehiclesNeedingService().length;

                return AnimatedBuilder(
                  animation: _slideController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_slideAnimation.value, 0),
                      child: child,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF047BC1),
                          Color(0xFF4F46E5),
                        ],
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatCard('Total', '${controller.vehicles.length}',
                            Colors.white),
                        _buildStatCard(
                            'Available', '$available', const Color(0xFF4CAF50)),
                        _buildStatCard(
                            'Service', '$needService', const Color(0xFFFF9800)),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox();
            }),
          ),

          // Vehicles List
          SliverFillRemaining(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
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
                        'Loading vehicle fleet...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.red.shade100,
                              Colors.red.shade50,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Error Loading Vehicles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade600,
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
                            onTap: controller.refresh,
                            borderRadius: BorderRadius.circular(14),
                            child: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh_rounded,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Try Again',
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
                );
              }

              if (controller.filteredVehicles.isEmpty) {
                return Center(
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
                        child: const Icon(
                          Icons.directions_car_rounded,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'No Vehicles Found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        controller.searchQuery.value.isNotEmpty
                            ? 'No results for "${controller.searchQuery.value}"'
                            : 'Try adjusting your filters',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 52,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4F46E5).withOpacity(0.3),
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
                            onTap: controller.clearFilters,
                            borderRadius: BorderRadius.circular(14),
                            child: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.filter_alt_off_rounded,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Clear Filters',
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
                );
              }

              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                itemCount: controller.filteredVehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = controller.filteredVehicles[index];

                  return AnimatedBuilder(
                    animation: _fadeController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                            0,
                            _slideAnimation.value *
                                (1 - (index * 0.1).clamp(0.0, 1.0))),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
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
                          onTap: () => _showVehicleDetail(vehicle),
                          borderRadius: BorderRadius.circular(20),
                          splashColor: const Color(0xFF047BC1).withOpacity(0.1),
                          highlightColor: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                // Vehicle Icon with Status
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      colors: vehicle.isAvailable
                                          ? [
                                              const Color(0xFF4CAF50)
                                                  .withOpacity(0.15),
                                              const Color(0xFF4CAF50)
                                                  .withOpacity(0.05),
                                            ]
                                          : [
                                              const Color(0xFFF44336)
                                                  .withOpacity(0.15),
                                              const Color(0xFFF44336)
                                                  .withOpacity(0.05),
                                            ],
                                    ),
                                    border: Border.all(
                                      color: vehicle.isAvailable
                                          ? const Color(0xFF4CAF50)
                                              .withOpacity(0.3)
                                          : const Color(0xFFF44336)
                                              .withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.directions_car_rounded,
                                          color: vehicle.isAvailable
                                              ? const Color(0xFF4CAF50)
                                              : const Color(0xFFF44336),
                                          size: 28,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          vehicle.availabilityState
                                              .substring(0, 3)
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: vehicle.isAvailable
                                                ? const Color(0xFF4CAF50)
                                                : const Color(0xFFF44336),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 16),

                                // Vehicle Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              vehicle.displayName,
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              color: Colors.grey.shade100,
                                            ),
                                            child: Text(
                                              vehicle.plateNumber,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black87,
                                                fontFamily: 'monospace',
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.model_training_rounded,
                                              size: 16,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              vehicle.vehicleModel.displayInfo,
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
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.location_on_rounded,
                                              size: 16,
                                              color: const Color(0xFF4F46E5),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${vehicle.branch.name} • ${vehicle.color} • ${vehicle.odometerKm} km',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
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
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      // Status Badges
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          if (vehicle.needsService)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color.fromRGBO(
                                                        255, 152, 0, 0.1),
                                                    Color.fromRGBO(
                                                        255, 152, 0, 0.05),
                                                  ],
                                                ),
                                                border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      255, 152, 0, 0.3),
                                                ),
                                              ),
                                              child: const Text(
                                                'NEEDS SERVICE',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color.fromRGBO(
                                                      255, 152, 0, 1),
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          if (!vehicle.isActive)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color.fromRGBO(
                                                        244, 67, 54, 0.1),
                                                    Color.fromRGBO(
                                                        244, 67, 54, 0.05),
                                                  ],
                                                ),
                                                border: Border.all(
                                                  color: const Color.fromRGBO(
                                                      244, 67, 54, 0.3),
                                                ),
                                              ),
                                              child: const Text(
                                                'INACTIVE',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color.fromRGBO(
                                                      244, 67, 54, 1),
                                                  letterSpacing: 0.5,
                                                ),
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
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: color.withOpacity(0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// In your vehicles_screen.dart, update the _buildFilterChip class:

class _buildFilterChip extends StatelessWidget {
  final String label;
  final String? value;

  const _buildFilterChip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VehicleController>();
    return Obx(() {
      final isSelected = controller.filterStatus.value == value;
      final grey100 = Colors.grey[100];
      final grey200 = Colors.grey[200];
      final grey700 = Colors.grey[700];

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            controller.filterStatus.value = isSelected ? null : value;
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                    )
                  : LinearGradient(
                      colors: [
                        grey100!,
                        Colors.grey.shade50,
                      ],
                    ),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF047BC1).withOpacity(0.3)
                    : grey200!,
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : grey700,
              ),
            ),
          ),
        ),
      );
    });
  }
}