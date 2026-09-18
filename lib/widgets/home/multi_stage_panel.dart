import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/stage_model.dart';
import '../../viewmodels/stage_viewmodel.dart';

class MultiStagePanel extends StatelessWidget {
  const MultiStagePanel({super.key});

  @override
  Widget build(BuildContext context) {
    final stageVm = context.watch<StageViewmodel>();

    return Column(
      children: [
        if (stageVm.hasStages) ...[
          _TripSummaryCard(stageVm: stageVm),
          const SizedBox(height: 12),
        ],
        ...stageVm.stages.asMap().entries.map((entry) {
          final isActive = entry.key == stageVm.activeStageIndex;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: isActive
                ? _ActiveStageCard(stageIndex: entry.key, stage: entry.value)
                : _CompletedStageCard(
                    stageNumber: entry.key + 1,
                    stage: entry.value,
                  ),
          );
        }),
        if (stageVm.canAddStage)
          _AddStageButton(isFirstStage: !stageVm.hasStages),
      ],
    );
  }
}

// ── Summary ───────────────────────────────────────────────────

class _TripSummaryCard extends StatelessWidget {
  final StageViewmodel stageVm;
  const _TripSummaryCard({required this.stageVm});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(
            label:
                '${stageVm.stages.length} stage${stageVm.stages.length == 1 ? '' : 's'}',
            value: 'R${stageVm.totalCollected}',
          ),
          Container(width: 1, height: 32, color: Colors.white24),
          _Stat(label: 'passengers', value: '${stageVm.totalPassengers}'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }
}

// ── Completed stage ───────────────────────────────────────────

class _CompletedStageCard extends StatelessWidget {
  final int stageNumber;
  final StageModel stage;
  const _CompletedStageCard({required this.stageNumber, required this.stage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          _StageBadge(
            number: stageNumber,
            color: AppColors.primary,
            alpha: 0.15,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.displayName,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'R${stage.farePerPerson}/pax · '
                  '${stage.passengersPaid} pax · '
                  'R${stage.totalCollected}',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.primary,
            size: 18,
          ),
        ],
      ),
    );
  }
}

// ── Active stage ──────────────────────────────────────────────

class _ActiveStageCard extends StatefulWidget {
  final int stageIndex;
  final StageModel stage;
  const _ActiveStageCard({required this.stageIndex, required this.stage});

  @override
  State<_ActiveStageCard> createState() => _ActiveStageCardState();
}

class _ActiveStageCardState extends State<_ActiveStageCard> {
  final _passengersController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _passengersController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final stageVm = context.read<StageViewmodel>();
    final stage = stageVm.activeStage!;
    final passengers = int.tryParse(_passengersController.text);
    final amount = int.tryParse(_amountController.text);
    final remaining = stage.remainingSeats;

    if (passengers == null || passengers <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid number of passengers')),
      );
      return;
    }
    if (passengers > remaining) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Only $remaining seat${remaining == 1 ? '' : 's'} remaining',
          ),
        ),
      );
      return;
    }
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount paid')),
      );
      return;
    }

    final error = await stageVm.addPaymentToActiveStage(
      amount: amount,
      passengers: passengers,
    );

    if (!mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));

      return;
    }

    _passengersController.clear();
    _amountController.clear();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final stage = context.watch<StageViewmodel>().activeStage!;
    final stageNumber = widget.stageIndex + 1;
    final passengers = int.tryParse(_passengersController.text) ?? 0;
    final amount = int.tryParse(_amountController.text) ?? 0;
    final due = passengers * stage.farePerPerson;
    final change = amount - due;
    final showPreview = passengers > 0 && amount > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent..withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black..withValues(alpha: 0.6),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stage header
          Row(
            children: [
              _StageBadge(
                number: stageNumber,
                color: AppColors.accent,
                alpha: 0.15,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.displayName,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'R${stage.farePerPerson}/pax · '
                      '${stage.remainingSeats} of ${stage.totalSeats} remaining',
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: stage.isComplete
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  stage.isComplete
                      ? 'Complete'
                      : '${stage.remainingSeats} left',
                  style: TextStyle(
                    color: stage.isComplete
                        ? AppColors.primary
                        : AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Progress bar
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: stage.totalSeats > 0
                  ? stage.passengersPaid / stage.totalSeats
                  : 0,
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                stage.isComplete ? AppColors.primary : AppColors.accent,
              ),
              minHeight: 6,
            ),
          ),

          if (stage.isComplete) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'All passengers accounted for',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InputField(
                    label: 'Passengers',
                    controller: _passengersController,
                    hint: 'max ${stage.remainingSeats}',
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InputField(
                    label: 'Amount paid (R)',
                    controller: _amountController,
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            if (showPreview) ...[
              const SizedBox(height: 12),
              _PreviewRow(label: 'Amount due', value: 'R$due'),
              const SizedBox(height: 4),
              _PreviewRow(
                label: change >= 0 ? 'Change to give' : 'Shortfall',
                value: 'R${change.abs()}',
                isHighlight: true,
                isError: change < 0,
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _submit(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Record Payment',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
          ],

          if (stage.payments.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${stage.passengersPaid} pax paid',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'R${stage.totalCollected} collected',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Add Stage button ──────────────────────────────────────────

class _AddStageButton extends StatelessWidget {
  final bool isFirstStage;
  const _AddStageButton({required this.isFirstStage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _showAddStageDialog(context),
        icon: const Icon(Icons.add, size: 18),
        label: Text(isFirstStage ? 'Start first stage' : 'Add next stage'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.accent,
          side: BorderSide(color: AppColors.accent.withValues(alpha: 0.5)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showAddStageDialog(BuildContext context) {
    final fromController = TextEditingController();
    final toController = TextEditingController();
    final fareController = TextEditingController();
    final seatsController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Add stage',
          style: TextStyle(color: AppColors.accent),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(
                controller: fromController,
                label: 'From',
                hint: 'e.g. Alexandra',
              ),
              const SizedBox(height: 12),
              _DialogField(
                controller: toController,
                label: 'To',
                hint: 'e.g. Sandton',
              ),
              const SizedBox(height: 12),
              _DialogField(
                controller: fareController,
                label: 'Fare per person (R)',
                hint: 'e.g. 18',
                isNumber: true,
              ),
              const SizedBox(height: 12),
              _DialogField(
                controller: seatsController,
                label: 'Passengers joining',
                hint: 'e.g. 12',
                isNumber: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final from = fromController.text.trim();
              final to = toController.text.trim();
              final fare = int.tryParse(fareController.text.trim());
              final seats = int.tryParse(seatsController.text.trim());
              if (from.isEmpty ||
                  to.isEmpty ||
                  fare == null ||
                  fare <= 0 ||
                  seats == null ||
                  seats <= 0) {
                return;
              }
              context.read<StageViewmodel>().addStage(
                from: from,
                to: to,
                farePerPerson: fare,
                totalSeats: seats,
              );
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Add stage'),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────

class _StageBadge extends StatelessWidget {
  final int number;
  final Color color;
  final double alpha;
  const _StageBadge({
    required this.number,
    required this.color,
    required this.alpha,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final void Function(String) onChanged;
  final String hint;

  const _InputField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.hint = '0',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          style: const TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.secondary),
          ),
        ),
      ],
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;
  final bool isError;

  const _PreviewRow({
    required this.label,
    required this.value,
    this.isHighlight = false,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? Colors.red.shade700
        : isHighlight
        ? AppColors.accent
        : AppColors.secondary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool isNumber;

  const _DialogField({
    required this.controller,
    required this.label,
    required this.hint,
    this.isNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.secondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.background,
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.secondary),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
