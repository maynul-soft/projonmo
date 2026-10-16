import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vip_salary_controller.dart';
import '../models/salary_model.dart';

class SalaryStatusCard extends StatelessWidget {
  final SalaryModel? salary;
  final bool isLoading;
  final VipSalaryController controller;
  final String type;

  const SalaryStatusCard({
    super.key,
    required this.salary,
    required this.isLoading,
    required this.controller,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF065F46), Color(0xFF047857)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
        ),
      );
    }

    if (salary == null) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            const Icon(Icons.info_outline_rounded, color: Colors.grey, size: 36),
            const SizedBox(height: 8),
            Text(
              'Unable to load $type salary status',
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => controller.fetchSalaryDetails(type),
              child: const Text('Tap to Retry'),
            ),
          ],
        ),
      );
    }

    final s = salary!;
    final typeLabel = s.type == 'weekly'
        ? 'Week'
        : s.type == 'monthly'
            ? 'Month'
            : 'Year';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF047857).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header: VIP Badge & Cycle Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium_rounded, size: 16, color: Color(0xFFFBBF24)),
                      const SizedBox(width: 5),
                      Text(
                        s.vipLevel.isNotEmpty ? s.vipLevel : 'Current Tier',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.event_repeat_rounded, size: 14, color: Colors.white70),
                      const SizedBox(width: 5),
                      Text(
                        s.cycle.isNotEmpty ? s.cycle : s.title,
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 2. Amount Section
            const Text(
              'Your Salary Amount',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '৳${s.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/ $typeLabel',
                  style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),

            // 3. Progress Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Team Progress: ${s.currentTeam} / ${s.minTeam} members',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${s.progressPercent.toStringAsFixed(0)}%',
                  style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (s.progressPercent / 100).clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFBBF24)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  s.isEligible ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  size: 14,
                  color: s.isEligible ? const Color(0xFF34D399) : Colors.white70,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    s.isEligible
                        ? 'Requirement met! You are eligible for this salary.'
                        : 'Need ${s.remainingTeam} more active team members to qualify.',
                    style: TextStyle(
                      color: s.isEligible ? const Color(0xFF34D399) : Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            if (s.nextDistributionDate.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 13, color: Colors.white60),
                  const SizedBox(width: 6),
                  Text(
                    'Next cycle distribution: ${s.nextDistributionDate}',
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 18),

            // 4. Claim Button
            Obx(() {
              final isClaiming = controller.isClaiming.value;

              if (s.isClaimed) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Salary Claimed For This Period',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              final canClaim = s.canClaim;

              return SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isClaiming
                      ? null
                      : () {
                          if (canClaim) {
                            controller.claimSalary(type);
                          } else {
                            Get.snackbar(
                              'Eligibility Notice',
                              'You need ${s.remainingTeam} more team members to claim this salary (Required: ${s.minTeam}, Current: ${s.currentTeam}).',
                              backgroundColor: Colors.amber.shade800,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                              icon: const Icon(Icons.lock_clock_rounded, color: Colors.white),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canClaim ? const Color(0xFFFBBF24) : Colors.white.withValues(alpha: 0.22),
                    foregroundColor: canClaim ? const Color(0xFF78350F) : Colors.white,
                    elevation: canClaim ? 3 : 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isClaiming
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              canClaim ? Icons.stars_rounded : Icons.lock_outline_rounded,
                              size: 18,
                              color: canClaim ? const Color(0xFF78350F) : Colors.white70,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              canClaim
                                  ? 'Claim Salary (৳${s.amount.toStringAsFixed(0)})'
                                  : 'Claim Salary (Need ${s.remainingTeam} More)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: canClaim ? const Color(0xFF78350F) : Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
