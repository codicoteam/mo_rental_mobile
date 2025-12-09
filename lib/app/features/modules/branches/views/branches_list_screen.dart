// features/modules/branches/views/branches_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/branch_models/branch_models.dart';
import '../controllers/branch_controller.dart';
import 'branch_detail_screen.dart';

class BranchesListScreen extends StatelessWidget {
  const BranchesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BranchController controller = Get.find<BranchController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Branch Locations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshBranches,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () => _showFilterDialog(context, controller),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search branches by name, city, or address...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: controller.filterBranches,
              ),
            ),

            // Active filters chips
            Obx(() {
              if (controller.selectedCity.value.isEmpty &&
                  controller.selectedRegion.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Wrap(
                  spacing: 8,
                  children: [
                    if (controller.selectedCity.value.isNotEmpty)
                      FilterChip(
                        label: Text('City: ${controller.selectedCity.value}'),
                        onSelected: (_) => controller.selectedCity.value = '',
                        deleteIcon: const Icon(Icons.close, size: 16),
                      ),
                    if (controller.selectedRegion.value.isNotEmpty)
                      FilterChip(
                        label: Text('Region: ${controller.selectedRegion.value}'),
                        onSelected: (_) => controller.selectedRegion.value = '',
                        deleteIcon: const Icon(Icons.close, size: 16),
                      ),
                  ],
                ),
              );
            }),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    return Text(
                      '${controller.filteredBranches.length} branches',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    );
                  }),
                  Obx(() {
                    final activeCount = controller.getActiveBranches().length;
                    return Text(
                      '$activeCount active',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Branches List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.error.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading branches',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.error.value,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: controller.fetchBranches,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.filteredBranches.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No branches found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.searchQuery.value.isNotEmpty
                              ? 'Try a different search term'
                              : 'No branches available',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (controller.searchQuery.value.isNotEmpty)
                          TextButton(
                            onPressed: () => controller.filterBranches(''),
                            child: const Text('Clear search'),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await controller.refreshBranches();
                  },
                  child: ListView.builder(
                    itemCount: controller.filteredBranches.length,
                    itemBuilder: (context, index) {
                      final branch = controller.filteredBranches[index];
                      return _buildBranchCard(branch, controller, context);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchCard(Branch branch, BranchController controller, BuildContext context) {
    final isOpen = controller.isBranchOpenNow(branch.id);
    final todayHours = controller.getTodayHours(branch);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: InkWell(
        onTap: () {
          controller.selectBranch(branch);
          Get.to(() => BranchDetailScreen(branch: branch));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Branch header with status
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: branch.active ? Colors.blue : Colors.grey,
                    child: Icon(
                      Icons.business,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          branch.code,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isOpen ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isOpen ? Colors.green : Colors.red,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOpen ? Icons.circle : Icons.circle_outlined,
                          size: 10,
                          color: isOpen ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOpen ? 'OPEN' : 'CLOSED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isOpen ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          branch.address.line1,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        if (branch.address.line2 != null && branch.address.line2!.isNotEmpty)
                          Text(branch.address.line2!),
                        Text('${branch.address.city}, ${branch.address.region}'),
                        Text(branch.address.country),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Contact info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.phone, size: 20, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    branch.phone,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.email, size: 20, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      branch.email,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Opening hours
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.access_time, size: 20, color: Colors.purple),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Today\'s Hours',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            todayHours,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Active status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        branch.active ? Icons.check_circle : Icons.remove_circle,
                        size: 16,
                        color: branch.active ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        branch.active ? 'Active' : 'Inactive',
                        style: TextStyle(
                          color: branch.active ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      controller.selectBranch(branch);
                      Get.to(() => BranchDetailScreen(branch: branch));
                    },
                    icon: const Icon(Icons.arrow_forward_ios, size: 14),
                    label: const Text('View Details'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, BranchController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Branches'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filter by City:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All Cities'),
                      selected: controller.selectedCity.value.isEmpty,
                      onSelected: (_) {
                        controller.selectedCity.value = '';
                        controller.selectedRegion.value = '';
                        controller.filteredBranches.assignAll(controller.branchesList);
                        Get.back();
                      },
                    ),
                    ...controller.uniqueCities.map((city) {
                      return FilterChip(
                        label: Text(city),
                        selected: controller.selectedCity.value == city,
                        onSelected: (selected) {
                          controller.selectedCity.value = selected ? city : '';
                          controller.selectedRegion.value = '';
                          controller.searchBranches(
                            city: selected ? city : null,
                          );
                          Get.back();
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Filter by Region:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All Regions'),
                      selected: controller.selectedRegion.value.isEmpty,
                      onSelected: (_) {
                        controller.selectedCity.value = '';
                        controller.selectedRegion.value = '';
                        controller.filteredBranches.assignAll(controller.branchesList);
                        Get.back();
                      },
                    ),
                    ...controller.uniqueRegions.map((region) {
                      return FilterChip(
                        label: Text(region),
                        selected: controller.selectedRegion.value == region,
                        onSelected: (selected) {
                          controller.selectedCity.value = '';
                          controller.selectedRegion.value = selected ? region : '';
                          controller.searchBranches(
                            region: selected ? region : null,
                          );
                          Get.back();
                        },
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Show Only:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Active Only'),
                      selected: false,
                      onSelected: (_) {
                        final activeBranches = controller.getActiveBranches();
                        controller.filteredBranches.assignAll(activeBranches);
                        Get.back();
                      },
                    ),
                    FilterChip(
                      label: const Text('All Branches'),
                      selected: false,
                      onSelected: (_) {
                        controller.filteredBranches.assignAll(controller.branchesList);
                        Get.back();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                controller.selectedCity.value = '';
                controller.selectedRegion.value = '';
                controller.filteredBranches.assignAll(controller.branchesList);
                Get.back();
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}