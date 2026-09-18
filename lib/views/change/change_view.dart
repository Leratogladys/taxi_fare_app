import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/payment_model.dart';
import '../../viewmodels/payment_viewmodel.dart';
import '../../viewmodels/stage_viewmodel.dart';

class _TrackedChange {
  final PaymentModel payment;
  final VoidCallback onMarkGiven;
  final String source;

  const _TrackedChange({
    required this.payment,
    required this.onMarkGiven,
    required this.source,
  });
}

class ChangeView extends StatelessWidget {
  const ChangeView({super.key});

  @override
  Widget build(BuildContext context) {
    final paymentVm = context.watch<PaymentViewmodel>();
    final stageVm = context.watch<StageViewmodel>();

    final entries = <_TrackedChange>[
      // Normal trip payments
      for (final entry in paymentVm.payments.asMap().entries)
        if (entry.value.change > 0)
          _TrackedChange(
            payment: entry.value,
            source: 'Normal trip',
            onMarkGiven: () => paymentVm.markChangeAsGiven(entry.key),
          ),

      // Multi-stage payments
      for (final stageEntry in stageVm.stages.asMap().entries)
        for (final paymentEntry in stageEntry.value.payments.asMap().entries)
          if (paymentEntry.value.change > 0)
            _TrackedChange(
              payment: paymentEntry.value,
              source: '${stageEntry.value.from} → ${stageEntry.value.to}',
              onMarkGiven: () =>
                  stageVm.markChangeAsGiven(stageEntry.key, paymentEntry.key),
            ),
    ];

    final pendingEntries = entries.where((e) => !e.payment.completed).toList();

    final totalPending = pendingEntries.fold(
      0,
      (sum, entry) => sum + entry.payment.change,
    );

    final allGiven = entries.isNotEmpty && pendingEntries.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Change Tracker'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: entries.isEmpty
          ? const _EmptyState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SummaryCard(
                    totalPending: totalPending,
                    pendingCount: pendingEntries.length,
                    totalCount: entries.length,
                    allGiven: allGiven,
                  ),
                  const SizedBox(height: 16),
                  ...entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ChangeItem(
                        payment: entry.payment,
                        source: entry.source,
                        onMarkGiven: entry.onMarkGiven,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

// Summary Card

class _SummaryCard extends StatelessWidget {
  final int totalPending;
  final int pendingCount;
  final int totalCount;
  final bool allGiven;

  const _SummaryCard({
    required this.totalPending,
    required this.pendingCount,
    required this.totalCount,
    required this.allGiven,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: allGiven
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.accent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: allGiven
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: AppColors.primary,
                  size: 20,
                ),
                SizedBox(width: 10),
                Text(
                  'All change has been given',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CHANGE OUTSTANDING',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'R$totalPending',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$pendingCount of $totalCount group${totalCount == 1 ? '' : 's'} still waiting',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
    );
  }
}

// Individual change Item
class _ChangeItem extends StatelessWidget {
  final PaymentModel payment;
  final String source;
  final VoidCallback onMarkGiven;

  const _ChangeItem({
    required this.payment,
    required this.source,
    required this.onMarkGiven,
  });

  @override
  Widget build(BuildContext context) {
    final isGiven = payment.completed;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGiven ? AppColors.card.withValues(alpha: 0.5) : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGiven
              ? AppColors.primary.withValues(alpha: 0.25)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // Payment details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${payment.passengers} '
                  '${payment.passengers == 1 ? 'passenger' : 'passengers'}',
                  style: TextStyle(
                    color: isGiven ? AppColors.secondary : AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Paid R${payment.amount}',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  source,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          //Change Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R${payment.change}',
                style: TextStyle(
                  color: isGiven ? AppColors.primary : AppColors.accent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'change',
                style: TextStyle(
                  color: isGiven ? AppColors.primary : AppColors.secondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),

          //Action Button
          isGiven
              ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.primary,
                    size: 18,
                  ),
                )
              : ElevatedButton(
                  onPressed: onMarkGiven,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Given'),
                ),
        ],
      ),
    );
  }
}

// Empty State

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 56,
            color: AppColors.secondary,
          ),
          SizedBox(height: 16),
          Text(
            'No change to track',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 6),
          Text(
            'Payments with change will appear here',
            style: TextStyle(color: AppColors.secondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
