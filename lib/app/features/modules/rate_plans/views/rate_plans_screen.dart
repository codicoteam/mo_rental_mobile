import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/rate_plan/rate_plan_model.dart';
import '../../../widgets/rate_plan_card/rate_plan_card.dart';
import '../controllers/rate_plan_controller.dart';

class RatePlansScreen extends StatefulWidget {
  const RatePlansScreen({super.key});

  @override
  State<RatePlansScreen> createState() => _RatePlansScreenState();
}

class _RatePlansScreenState extends State<RatePlansScreen> {
  final RatePlanController controller = Get.find<RatePlanController>();
  final GetStorage _storage = GetStorage();
  final ScrollController _scrollController = ScrollController();

  bool _isAdminOrManager() {
    final userData = _storage.read('user_data') ?? {};
    final roles = List<String>.from(userData['roles'] ?? []);
    return roles.contains('admin') || roles.contains('manager');
  }

  @override
  void initState() {
    super.initState();
    
    // Setup scroll listener for pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        if (controller.currentPage.value < controller.totalPages.value) {
          controller.loadMore();
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.ratePlans.isEmpty && !controller.isLoading.value) {
        controller.loadRatePlans();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation(const Color(0xFF047BC1)),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading rate plans...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              controller.errorMessage.value,
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
                onTap: controller.loadRatePlans,
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
    );
  }

  Widget _buildEmptyState() {
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
              Icons.money_off_rounded,
              size: 64,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Rate Plans Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Try adjusting your filters or refresh',
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
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: controller.loadRatePlans,
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
                        'Refresh',
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

  Widget _buildMainContent() {
    return Column(
      children: [
        // Header Section
        Container(
          padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rate Plans',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        '${controller.filteredPlans.length} plans found',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      )),
                ],
              ),
              Row(
                children: [
                  if (controller.isAuthenticated && _isAdminOrManager())
                    _buildActionButton(
                      icon: Icons.add_rounded,
                      onPressed: () => Get.to(() => const AddEditRatePlanScreen()),
                      tooltip: 'Add Plan',
                    ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.filter_alt_rounded,
                    onPressed: () => Get.bottomSheet(const FilterBottomSheet()),
                    tooltip: 'Filter',
                  ),
                  const SizedBox(width: 8),
                  _buildActionButton(
                    icon: Icons.refresh_rounded,
                    onPressed: controller.loadRatePlans,
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ],
          ),
        ),

        // Search Bar
        Padding(
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
              controller: TextEditingController(text: controller.searchQuery.value),
              onChanged: controller.searchPlans,
              decoration: InputDecoration(
                hintText: 'Search rate plans by name, class...',
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

        // Filters Summary
        if (controller.selectedVehicleClass.value.isNotEmpty ||
            controller.selectedCurrency.value != 'USD' ||
            controller.selectedDate.value.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromRGBO(4, 123, 193, 0.08),
                  Color.fromRGBO(79, 70, 229, 0.08),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF047BC1).withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF047BC1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.filter_list_rounded,
                    size: 18,
                    color: Color(0xFF047BC1),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (controller.selectedVehicleClass.value.isNotEmpty)
                          _buildFilterChip(
                            'Class: ${controller.selectedVehicleClass.value}',
                            onDelete: () {
                              controller.selectedVehicleClass.value = '';
                              controller.applyFilters();
                            },
                          ),
                        if (controller.selectedCurrency.value != 'USD')
                          _buildFilterChip(
                            'Currency: ${controller.selectedCurrency.value}',
                            onDelete: () {
                              controller.selectedCurrency.value = 'USD';
                              controller.applyFilters();
                            },
                          ),
                        if (controller.selectedDate.value.isNotEmpty)
                          _buildFilterChip(
                            'Date: ${controller.selectedDate.value}',
                            onDelete: () {
                              controller.selectedDate.value = '';
                              controller.applyFilters();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade100,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: controller.clearFilters,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          'Clear All',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Rate Plans List
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            itemCount: controller.filteredPlans.isEmpty
                ? 0
                : (controller.currentPage.value < controller.totalPages.value
                    ? controller.filteredPlans.length + 1
                    : controller.filteredPlans.length),
            itemBuilder: (context, index) {
              if (index < controller.filteredPlans.length) {
                final plan = controller.filteredPlans[index];
                return RatePlanCard(plan: plan);
              } else if (controller.currentPage.value < controller.totalPages.value) {
                // Show loading indicator at the bottom
                return Container(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: const AlwaysStoppedAnimation(Color(0xFF047BC1)),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox(height: 20);
            },
          ),
        ),

        // Footer Stats
       
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
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
          icon,
          color: const Color(0xFF047BC1),
          size: 24,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
      ),
    );
  }

  Widget _buildFilterChip(String label, {required VoidCallback onDelete}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDelete,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: Color(0xFF047BC1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        // Show loading indicator when loading and no data
        if (controller.isLoading.value && controller.ratePlans.isEmpty) {
          return _buildLoadingState();
        }

        // Show error message if there's an error and no data
        if (controller.errorMessage.value.isNotEmpty && controller.ratePlans.isEmpty) {
          return _buildErrorState();
        }

        // Show empty state if no data
        if (controller.filteredPlans.isEmpty) {
          return _buildEmptyState();
        }

        // Main content with rate plans
        return _buildMainContent();
      }),
      floatingActionButton: controller.isAuthenticated && _isAdminOrManager()
          ? FloatingActionButton(
              onPressed: () => Get.to(() => const AddEditRatePlanScreen()),
              backgroundColor: const Color(0xFF047BC1),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            )
          : null,
    );
  }
}

// The FilterBottomSheet and AddEditRatePlanScreen classes remain exactly the same
// ... [rest of the code remains unchanged]
  // ignore: unused_element
  Widget _buildFilterChip(String label, {required VoidCallback onDelete}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDelete,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: Color(0xFF047BC1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final RatePlanController controller = Get.find<RatePlanController>();

    return Container(
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
                'Filter Rate Plans',
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

          // Vehicle Class
          const Text(
            'Vehicle Class',
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
            children: controller.vehicleClasses.map((cls) {
              return Obx(() => Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        controller.selectedVehicleClass.value =
                            controller.selectedVehicleClass.value == cls ? '' : cls;
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: controller.selectedVehicleClass.value == cls
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
                            color: controller.selectedVehicleClass.value == cls
                                ? const Color(0xFF047BC1).withOpacity(0.3)
                                : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          cls.toUpperCase(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: controller.selectedVehicleClass.value == cls
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ));
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Currency
          const Text(
            'Currency',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: controller.currencies.map((curr) {
              return Obx(() => Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        controller.selectedCurrency.value =
                            controller.selectedCurrency.value == curr ? 'USD' : curr;
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: controller.selectedCurrency.value == curr
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
                            color: controller.selectedCurrency.value == curr
                                ? const Color(0xFF047BC1).withOpacity(0.3)
                                : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          curr,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: controller.selectedCurrency.value == curr
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ));
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Active Only
          Obx(() => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Show Active Plans Only',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 48,
                      height: 28,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: controller.showActiveOnly.value
                            ? const LinearGradient(
                                colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.grey.shade400,
                                  Colors.grey.shade500,
                                ],
                              ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () =>
                              controller.showActiveOnly.value = !controller.showActiveOnly.value,
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedAlign(
                            duration: const Duration(milliseconds: 300),
                            alignment: controller.showActiveOnly.value
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),

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
                      onTap: controller.clearFilters,
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
    );
  }
}

class AddEditRatePlanScreen extends StatelessWidget {
  final RatePlan? plan;

  const AddEditRatePlanScreen({super.key, this.plan});

  @override
  Widget build(BuildContext context) {
    final isEdit = plan != null;
    final controller = Get.find<RatePlanController>();

    final nameController = TextEditingController(text: plan?.name ?? '');
    final notesController = TextEditingController(text: plan?.notes ?? '');
    final dailyRateController =
        TextEditingController(text: plan?.dailyRate.toString() ?? '0.0');
    final weeklyRateController =
        TextEditingController(text: plan?.weeklyRate.toString() ?? '0.0');
    final monthlyRateController =
        TextEditingController(text: plan?.monthlyRate.toString() ?? '0.0');
    final weekendRateController =
        TextEditingController(text: plan?.weekendRate.toString() ?? '0.0');

    // For validity dates
    final validFromController = TextEditingController(
        text: plan?.validFrom != null
            ? '${plan!.validFrom.year}-${plan!.validFrom.month.toString().padLeft(2, '0')}-${plan!.validFrom.day.toString().padLeft(2, '0')}'
            : DateTime.now().toString().split(' ')[0]);
    final validToController = TextEditingController(
        text: plan?.validTo != null
            ? '${plan!.validTo.year}-${plan!.validTo.month.toString().padLeft(2, '0')}-${plan!.validTo.day.toString().padLeft(2, '0')}'
            : DateTime.now()
                .add(const Duration(days: 365))
                .toString()
                .split(' ')[0]);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Rate Plan' : 'Add Rate Plan',
          style: const TextStyle(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Plan Name
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Plan Name*',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notes/Description
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextFormField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Notes/Description',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Vehicle Class
            const Text(
              'Vehicle Class*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Wrap(
                  spacing: 8,
                  children: controller.vehicleClasses.map((cls) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          controller.selectedVehicleClass.value =
                              controller.selectedVehicleClass.value == cls ? '' : cls;
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: controller.selectedVehicleClass.value == cls
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
                              color: controller.selectedVehicleClass.value == cls
                                  ? const Color(0xFF047BC1).withOpacity(0.3)
                                  : Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            cls.toUpperCase(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: controller.selectedVehicleClass.value == cls
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),

            const SizedBox(height: 24),

            // Currency
            const Text(
              'Currency*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Wrap(
                  spacing: 8,
                  children: controller.currencies.map((curr) {
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          controller.selectedCurrency.value =
                              controller.selectedCurrency.value == curr ? 'USD' : curr;
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: controller.selectedCurrency.value == curr
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
                              color: controller.selectedCurrency.value == curr
                                  ? const Color(0xFF047BC1).withOpacity(0.3)
                                  : Colors.grey.shade200,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            curr,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: controller.selectedCurrency.value == curr
                                  ? Colors.white
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )),

            const SizedBox(height: 24),

            // Rates Section
            const Text(
              'Rates*',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Daily Rate
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextFormField(
                controller: dailyRateController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Daily Rate',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixText: '\$ ',
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Weekly Rate
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextFormField(
                controller: weeklyRateController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Weekly Rate',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixText: '\$ ',
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Monthly Rate
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextFormField(
                controller: monthlyRateController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Monthly Rate',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixText: '\$ ',
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Weekend Rate
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextFormField(
                controller: weekendRateController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Weekend Rate',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                  prefixText: '\$ ',
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Validity Period
            const Text(
              'Validity Period*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextFormField(
                      controller: validFromController,
                      decoration: const InputDecoration(
                        hintText: 'Valid From (YYYY-MM-DD)',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.calendar_today_rounded, color: Color(0xFF4F46E5)),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          validFromController.text =
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        }
                      },
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: TextFormField(
                      controller: validToController,
                      decoration: const InputDecoration(
                        hintText: 'Valid To (YYYY-MM-DD)',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.calendar_today_rounded, color: Color(0xFF4F46E5)),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 365)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          validToController.text =
                              '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        }
                      },
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Active Plan
            Obx(() => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 48,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: controller.showActiveOnly.value
                              ? const LinearGradient(
                                  colors: [Color(0xFF047BC1), Color(0xFF4F46E5)],
                                )
                              : LinearGradient(
                                  colors: [
                                    Colors.grey.shade400,
                                    Colors.grey.shade500,
                                  ],
                                ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () =>
                                controller.showActiveOnly.value = !controller.showActiveOnly.value,
                            borderRadius: BorderRadius.circular(14),
                            child: AnimatedAlign(
                              duration: const Duration(milliseconds: 300),
                              alignment: controller.showActiveOnly.value
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.all(2),
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 32),

            // Submit Button
            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
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
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () async {
                    if (nameController.text.isEmpty) {
                      Get.snackbar('Error', 'Plan name is required',
                          backgroundColor: Colors.red);
                      return;
                    }

                    if (controller.selectedVehicleClass.value.isEmpty) {
                      Get.snackbar('Error', 'Vehicle class is required',
                          backgroundColor: Colors.red);
                      return;
                    }

                    final data = {
                      'name': nameController.text,
                      'notes': notesController.text,
                      'vehicle_class': controller.selectedVehicleClass.value,
                      'currency': controller.selectedCurrency.value,
                      'daily_rate': double.parse(dailyRateController.text.isEmpty
                          ? '0'
                          : dailyRateController.text),
                      'weekly_rate': double.parse(weeklyRateController.text.isEmpty
                          ? '0'
                          : weeklyRateController.text),
                      'monthly_rate': double.parse(
                          monthlyRateController.text.isEmpty
                              ? '0'
                              : monthlyRateController.text),
                      'weekend_rate': double.parse(
                          weekendRateController.text.isEmpty
                              ? '0'
                              : weekendRateController.text),
                      'valid_from': validFromController.text,
                      'valid_to': validToController.text,
                      'active': controller.showActiveOnly.value,
                    };

                    if (controller.selectedBranch.value.isNotEmpty) {
                      data['branch_id'] = controller.selectedBranch.value;
                    }

                    if (isEdit) {
                      await controller.updatePlan(plan!.id, data);
                    } else {
                      await controller.createPlan(data);
                    }

                    Get.back();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Center(
                    child: Text(
                      isEdit ? 'Update Plan' : 'Create Plan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}