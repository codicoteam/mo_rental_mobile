import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/rate_plan/rate_plan_response.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/rate_plan_controller.dart';

class RatePlansScreen extends StatelessWidget {
  const RatePlansScreen({super.key});

  @override
Widget build(BuildContext context) {
  final RatePlanController controller = Get.find<RatePlanController>();
  final AuthController authController = Get.find<AuthController>();
  
  // Print user role info
  WidgetsBinding.instance.addPostFrameCallback((_) {
    authController.printUserRoleInfo();
  });
  
  return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Plans'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => Get.bottomSheet(FilterBottomSheet()),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadRatePlans,
          ),
        ],
      ),
      body: Obx(() {
        // Use Obx at the top level to observe all reactive variables
        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: TextEditingController(text: controller.searchQuery.value),
                onChanged: controller.searchPlans,
                decoration: InputDecoration(
                  hintText: 'Search rate plans...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ),
            
            // Filters Summary
            if (controller.selectedVehicleClass.value.isNotEmpty ||
                controller.selectedCurrency.value != 'USD' ||
                controller.selectedDate.value.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
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
                    TextButton(
                      onPressed: controller.clearFilters,
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ),
            
            // Loading Indicator
            if (controller.isLoading.value && controller.ratePlans.isEmpty)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            
            // Error Message
            if (controller.errorMessage.value.isNotEmpty && controller.ratePlans.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: controller.loadRatePlans,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Empty State
            if (!controller.isLoading.value &&
                controller.errorMessage.value.isEmpty &&
                controller.filteredPlans.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.money_off, size: 60, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No rate plans found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your filters',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Rate Plans List
            if (controller.filteredPlans.isNotEmpty)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => await controller.loadRatePlans(),
                  child: ListView.builder(
                    itemCount: controller.filteredPlans.length + 1,
                    itemBuilder: (context, index) {
                      if (index < controller.filteredPlans.length) {
                        final plan = controller.filteredPlans[index];
                        return RatePlanCard(plan: plan);
                      } else {
                        // Load more indicator
                        if (controller.currentPage.value < controller.totalPages.value) {
                          controller.loadMore();
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return const SizedBox();
                      }
                    },
                  ),
                ),
              ),
            
            // Stats
            if (controller.filteredPlans.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${controller.filteredPlans.length} of ${controller.totalItems.value} plans',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        );
      }),
      floatingActionButton: controller.isAuthenticated
          ? FloatingActionButton(
              onPressed: () => Get.to(() => const AddEditRatePlanScreen()),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildFilterChip(String label, {required VoidCallback onDelete}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onDelete,
        backgroundColor: Colors.blue.shade100,
      ),
    );
  }
}

class RatePlanCard extends StatelessWidget {
  final RatePlan plan;

  const RatePlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    plan.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: plan.isActive ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    plan.isActive ? 'ACTIVE' : 'INACTIVE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: plan.isActive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              plan.description,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            
            // Vehicle Info
            Row(
              children: [
                Icon(Icons.directions_car, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  plan.vehicleClass.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (plan.vehicleModelId != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.model_training, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text('Model: ${plan.vehicleModelId}'),
                ],
              ],
            ),
            const SizedBox(height: 8),
            
            // Rates
            const Text(
              'Rates:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRateChip('Daily', plan.formattedDailyRate),
                _buildRateChip('Weekly', plan.formattedWeeklyRate),
                _buildRateChip('Monthly', plan.formattedMonthlyRate),
              ],
            ),
            const SizedBox(height: 16),
            
            // Rental Period
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Text('Rental: ${plan.minRentalDays}-${plan.maxRentalDays} days'),
                const Spacer(),
                Icon(Icons.date_range, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Text(plan.validityPeriod),
              ],
            ),
            
            // Actions
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => Get.to(() => AddEditRatePlanScreen(plan: plan)),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Delete Rate Plan',
                      middleText: 'Are you sure you want to delete ${plan.name}?',
                      textConfirm: 'Delete',
                      textCancel: 'Cancel',
                      confirmTextColor: Colors.white,
                      onConfirm: () async {
                        Get.back();
                        await Get.find<RatePlanController>().deletePlan(plan.id);
                      },
                    );
                  },
                  tooltip: 'Delete',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateChip(String period, String rate) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            period,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          rate,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final RatePlanController controller = Get.find<RatePlanController>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Filters',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          // Vehicle Class
          const Text('Vehicle Class', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.vehicleClasses.map((cls) {
              return Obx(() => ChoiceChip(
                label: Text(cls.toUpperCase()),
                selected: controller.selectedVehicleClass.value == cls,
                onSelected: (selected) {
                  controller.selectedVehicleClass.value = selected ? cls : '';
                },
              ));
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Currency
          const Text('Currency', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: controller.currencies.map((curr) {
              return Obx(() => ChoiceChip(
                label: Text(curr),
                selected: controller.selectedCurrency.value == curr,
                onSelected: (selected) {
                  controller.selectedCurrency.value = selected ? curr : 'USD';
                },
              ));
            }).toList(),
          ),
          
          const SizedBox(height: 20),
          
          // Active Only
          Obx(() => SwitchListTile(
            title: const Text('Show Active Plans Only'),
            value: controller.showActiveOnly.value,
            onChanged: (value) => controller.showActiveOnly.value = value,
          )),
          
          const SizedBox(height: 30),
          
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.clearFilters,
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.applyFilters();
                    Get.back();
                  },
                  child: const Text('Apply Filters'),
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
    final descController = TextEditingController(text: plan?.description ?? '');
    final dailyRateController = TextEditingController(
      text: plan?.dailyRate.toString() ?? '0.0'
    );
    final weeklyRateController = TextEditingController(
      text: plan?.weeklyRate.toString() ?? '0.0'
    );
    final monthlyRateController = TextEditingController(
      text: plan?.monthlyRate.toString() ?? '0.0'
    );
    final minDaysController = TextEditingController(
      text: plan?.minRentalDays.toString() ?? '1'
    );
    final maxDaysController = TextEditingController(
      text: plan?.maxRentalDays.toString() ?? '30'
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Rate Plan' : 'Add Rate Plan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Plan Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text('Vehicle Class', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
           Obx(() => Wrap(
  spacing: 8,
  children: controller.vehicleClasses.map((cls) {
    return ChoiceChip(
      label: Text(cls.toUpperCase()),
      selected: controller.selectedVehicleClass.value == cls,
      onSelected: (selected) {
        controller.selectedVehicleClass.value = selected ? cls : '';
      },
    );
  }).toList(),
)),
            
            const SizedBox(height: 20),
            const Text('Rates', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: dailyRateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Daily Rate',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: weeklyRateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Weekly Rate',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: monthlyRateController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Monthly Rate',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: minDaysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min Days',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: maxDaysController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max Days',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  'name': nameController.text,
                  'description': descController.text,
                  'daily_rate': double.parse(dailyRateController.text),
                  'weekly_rate': double.parse(weeklyRateController.text),
                  'monthly_rate': double.parse(monthlyRateController.text),
                  'min_rental_days': int.parse(minDaysController.text),
                  'max_rental_days': int.parse(maxDaysController.text),
                  'currency': controller.selectedCurrency.value,
                  'vehicle_class': controller.selectedVehicleClass.value,
                  'is_active': true,
                };
                
                if (isEdit) {
                  await controller.updatePlan(plan!.id, data);
                } else {
                  await controller.createPlan(data);
                }
                
                Get.back();
              },
              child: Text(isEdit ? 'Update Plan' : 'Create Plan'),
            ),
          ],
        ),
      ),
    );
  }
}