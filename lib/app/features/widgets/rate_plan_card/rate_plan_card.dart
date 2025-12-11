// lib/features/rate_plans/widgets/rate_plan_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/rate_plan/rate_plan_model.dart';

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
            // Header with name and status
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
            
            // Branch info
            if (plan.branch != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    plan.branch!.name,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
            
            // Vehicle info
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.directions_car, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  plan.vehicleClass.toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                if (plan.vehicle != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.confirmation_number, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Plate: ${plan.vehicle!.plateNumber}',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ],
            ),
            
            // Notes
            if (plan.notes != null && plan.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                plan.notes!,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            // Rates Section
            const SizedBox(height: 16),
            const Text(
              'Rates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildRateChip('Daily', plan.formattedDailyRate),
                _buildRateChip('Weekly', plan.formattedWeeklyRate),
                _buildRateChip('Monthly', plan.formattedMonthlyRate),
                if (plan.weekendRate > 0)
                  _buildRateChip('Weekend', plan.formattedWeekendRate),
              ],
            ),
            
            // Seasonal Rates
            if (plan.seasonalOverrides.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Seasonal Rates',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              ...plan.seasonalOverrides.map((override) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${override.season.name} (${override.season.start.month}/${override.season.start.day}-${override.season.end.month}/${override.season.end.day})',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ),
                      Text(
                        '${plan.currency} ${override.dailyRate}/day',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            
            // Taxes & Fees
            const SizedBox(height: 16),
            Row(
              children: [
                if (plan.taxes.isNotEmpty) ...[
                  Icon(Icons.receipt, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    'Tax: ${(plan.totalTaxRate * 100).toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 12, color: Colors.red),
                  ),
                  const SizedBox(width: 12),
                ],
                if (plan.fees.isNotEmpty) ...[
                  Icon(Icons.money, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    'Fees: ${plan.fees.length}',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                  ),
                ],
              ],
            ),
            
            // Validity Period
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Valid: ${plan.validityPeriod}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            
            // Action buttons (only for admins)
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Edit button
                IconButton(
                  icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                  onPressed: () {
                    Get.snackbar(
                      'Info',
                      'Edit functionality requires admin privileges',
                      backgroundColor: Colors.blue,
                      colorText: Colors.white,
                    );
                  },
                ),
                // Delete button
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () {
                    Get.snackbar(
                      'Info',
                      'Delete functionality requires admin privileges',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRateChip(String period, String rate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          Text(
            period,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
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
      ),
    );
  }
}