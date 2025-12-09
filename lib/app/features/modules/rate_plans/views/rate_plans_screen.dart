import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/rate_plan/rate_plan_model.dart';
import '../../../widgets/rate_plan_card/rate_plan_card.dart';
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
            
            // Rate Plans List - USE IMPORTED WIDGET HERE
            if (controller.filteredPlans.isNotEmpty)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async => await controller.loadRatePlans(),
                  child: ListView.builder(
                    itemCount: controller.filteredPlans.length + 1,
                    itemBuilder: (context, index) {
                      if (index < controller.filteredPlans.length) {
                        final plan = controller.filteredPlans[index];
                        return RatePlanCard(plan: plan); // Using imported widget
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

// REMOVE the old RatePlanCard class from this file since we imported it

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
    final notesController = TextEditingController(text: plan?.notes ?? '');
    final dailyRateController = TextEditingController(
      text: plan?.dailyRate.toString() ?? '0.0'
    );
    final weeklyRateController = TextEditingController(
      text: plan?.weeklyRate.toString() ?? '0.0'
    );
    final monthlyRateController = TextEditingController(
      text: plan?.monthlyRate.toString() ?? '0.0'
    );
    final weekendRateController = TextEditingController(
      text: plan?.weekendRate.toString() ?? '0.0'
    );
    
    // For validity dates
    final validFromController = TextEditingController(
      text: plan?.validFrom != null 
          ? '${plan!.validFrom.year}-${plan!.validFrom.month.toString().padLeft(2, '0')}-${plan!.validFrom.day.toString().padLeft(2, '0')}'
          : DateTime.now().toString().split(' ')[0]
    );
    final validToController = TextEditingController(
      text: plan?.validTo != null 
          ? '${plan!.validTo.year}-${plan!.validTo.month.toString().padLeft(2, '0')}-${plan!.validTo.day.toString().padLeft(2, '0')}'
          : DateTime.now().add(const Duration(days: 365)).toString().split(' ')[0]
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
                labelText: 'Plan Name*',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes/Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            
            const Text('Vehicle Class*', style: TextStyle(fontWeight: FontWeight.bold)),
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
            
            const Text('Currency*', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Obx(() => Wrap(
              spacing: 8,
              children: controller.currencies.map((curr) {
                return ChoiceChip(
                  label: Text(curr),
                  selected: controller.selectedCurrency.value == curr,
                  onSelected: (selected) {
                    controller.selectedCurrency.value = selected ? curr : 'USD';
                  },
                );
              }).toList(),
            )),
            
            const SizedBox(height: 20),
            const Text('Rates*', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Daily Rate
            TextFormField(
              controller: dailyRateController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Daily Rate',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 12),
            
            // Weekly Rate
            TextFormField(
              controller: weeklyRateController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weekly Rate',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 12),
            
            // Monthly Rate
            TextFormField(
              controller: monthlyRateController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Monthly Rate',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
            ),
            const SizedBox(height: 12),
            
            // Weekend Rate
            TextFormField(
              controller: weekendRateController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weekend Rate',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
            ),
            
            const SizedBox(height: 20),
            const Text('Validity Period*', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: validFromController,
                    decoration: const InputDecoration(
                      labelText: 'Valid From (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
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
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: validToController,
                    decoration: const InputDecoration(
                      labelText: 'Valid To (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
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
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            Obx(() => SwitchListTile(
              title: const Text('Active Plan'),
              value: controller.showActiveOnly.value,
              onChanged: (value) => controller.showActiveOnly.value = value,
            )),
            
            const SizedBox(height: 30),
            
            ElevatedButton(
              onPressed: () async {
                // Validate required fields
                if (nameController.text.isEmpty) {
                  Get.snackbar('Error', 'Plan name is required', backgroundColor: Colors.red);
                  return;
                }
                
                if (controller.selectedVehicleClass.value.isEmpty) {
                  Get.snackbar('Error', 'Vehicle class is required', backgroundColor: Colors.red);
                  return;
                }
                
                // Create data object matching your API
                final data = {
                  'name': nameController.text,
                  'notes': notesController.text,
                  'vehicle_class': controller.selectedVehicleClass.value,
                  'currency': controller.selectedCurrency.value,
                  'daily_rate': double.parse(dailyRateController.text.isEmpty ? '0' : dailyRateController.text),
                  'weekly_rate': double.parse(weeklyRateController.text.isEmpty ? '0' : weeklyRateController.text),
                  'monthly_rate': double.parse(monthlyRateController.text.isEmpty ? '0' : monthlyRateController.text),
                  'weekend_rate': double.parse(weekendRateController.text.isEmpty ? '0' : weekendRateController.text),
                  'valid_from': validFromController.text,
                  'valid_to': validToController.text,
                  'active': controller.showActiveOnly.value,
                };
                
                // Optional: Add branch_id if you have branch selection
                if (controller.selectedBranch.value.isNotEmpty) {
                  data['branch_id'] = controller.selectedBranch.value;
                }
                
                print('📦 Rate Plan Data: $data');
                
                if (isEdit) {
                  await controller.updatePlan(plan!.id, data);
                } else {
                  await controller.createPlan(data);
                }
                
                Get.back();
              },
              child: Text(isEdit ? 'Update Plan' : 'Create Plan'),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
