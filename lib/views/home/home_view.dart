import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/fare_viewmodels.dart';
import '../../viewmodels/payment_viewmodel.dart';
import '../../widgets/home/trip_status_card.dart';
import '../../widgets/home/total_fare_card.dart';
import '../../widgets/home/stage_card.dart';
import '../../widgets/home/fare_mode_toggle.dart';
import '../../widgets/home/reverse_fare_card.dart';
import '../../widgets/home/multi_stage_panel.dart';
import '../../viewmodels/stage_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  FareMode _mode = FareMode.normal;
  bool _modeInitialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_modeInitialised) return;

    final stageVm = context.read<StageViewmodel>();

    //if an active multi-stage trip was restored from Hive,
    // reopen Home in Multi-stage mode
    if (stageVm.hasStages) {
      _mode = FareMode.multiStage;
    }

    _modeInitialised = true;
  }

  Future<void> _confirmNewTrip() async {
    final fareVm = context.read<FareViewmodel>();
    final paymentVm = context.read<PaymentViewmodel>();
    final stageVm = context.read<StageViewmodel>();

    final hasNormalTrip =
        fareVm.fare.seats > 0 ||
        fareVm.fare.farePerPerson > 0 ||
        paymentVm.payments.isNotEmpty;

    final hasMultiStageTrip = stageVm.hasStages;

    //Nothing actice: just make sure we're back on Calculate.
    if (!hasNormalTrip && !hasMultiStageTrip) {
      setState(() => _mode = FareMode.normal);
      return;
    }

    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(20),
        ),

        title: const Text(
          'Start new trip',
          style: TextStyle(color: AppColors.accent),
        ),
        content: const Text(
          'The current trip will be discarded and will not be saved to history.',
          style: TextStyle(color: AppColors.secondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(10),
              ),
            ),
            child: const Text("Discard & start new"),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    await paymentVm.clear();
    await stageVm.clear();
    await fareVm.reset();

    if (!context.mounted) return;

    setState(() => _mode = FareMode.normal);
  }

  Future<void> _completeCurrentTrip() async {
    final fareVm = context.read<FareViewmodel>();
    final paymentVm = context.read<PaymentViewmodel>();
    final stageVm = context.read<StageViewmodel>();

    final hasNormalTrip =
        fareVm.fare.seats > 0 ||
        fareVm.fare.farePerPerson > 0 ||
        paymentVm.payments.isNotEmpty;

    final hasMultiStageTrip = stageVm.hasStages;

    //Defensive check for data created before we enforced
    //one-active-trip-at-a-time
    if (hasNormalTrip && hasMultiStageTrip) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Both a normal and multi-stage trip are active. '
            'Resolve the current trip state before completing.',
          ),
        ),
      );
      return;
    }

    bool completed = false;

    if (_mode == FareMode.normal) {
      completed = await paymentVm.completeTrip(fareVm.fare);

      if (completed) {
        await fareVm.reset();
      }
    } else if (_mode == FareMode.multiStage) {
      completed = await stageVm.completeTrip();

      if (completed) {
        await fareVm.reset();
      }
    }

    if (!mounted) return;

    if (!completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This trip cannot be completed yet. '
            'Make sure all passengers are accounted for '
            'and all change has be given.',
          ),
        ),
      );
      return;
    }

    setState(() => _mode = FareMode.normal);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Trip completed and saved to history.')),
    );
  }

  void _changeMode(FareMode newMode) {
    final fareVm = context.read<FareViewmodel>();
    final paymentVm = context.read<PaymentViewmodel>();
    final stageVm = context.read<StageViewmodel>();

    final hasNormalTrip =
        fareVm.fare.seats > 0 ||
        fareVm.fare.farePerPerson > 0 ||
        paymentVm.payments.isNotEmpty;

    final hasMultiStageTrip = stageVm.hasStages;

    //Reverse is only a calculator, so ut may always be opened.
    if (newMode == FareMode.reverse) {
      setState(() => _mode = newMode);
      return;
    }

    if (newMode == FareMode.multiStage && hasNormalTrip) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Finish or discard the current Calculate trip '
            'before starting a multi-stage trip.',
          ),
        ),
      );
      return;
    }

    if (newMode == FareMode.normal && hasMultiStageTrip) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Finish or discard the current multi-stage trip '
            'before starting a Calculate trip.',
          ),
        ),
      );
      return;
    }

    setState(() => _mode = newMode);
  }

  @override
  Widget build(BuildContext context) {
    final tripId = context.select<FareViewmodel, int>((vm) => vm.tripId);
    final fareVm = context.watch<FareViewmodel>();
    final paymentVm = context.watch<PaymentViewmodel>();
    final stageVm = context.watch<StageViewmodel>();

    final hasNormaalTrip =
        fareVm.fare.seats > 0 ||
        fareVm.fare.farePerPerson > 0 ||
        paymentVm.payments.isNotEmpty;

    final hasMultiStageTrip = stageVm.hasStages;

    final canCompleteNormal =
        hasNormaalTrip && paymentVm.canCompleteTrip(fareVm.fare);

    final canCompleteMultiStage = hasMultiStageTrip && stageVm.canCompleteTrip;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Taxi Calculator'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => _confirmNewTrip(),
            icon: const Icon(Icons.add_road_outlined, size: 18),
            label: const Text('New trip'),
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FareModeToggle(mode: _mode, onChanged: _changeMode),
            const SizedBox(height: 12),
            if (_mode == FareMode.normal) ...[
              const TripStatusCard(),
              const SizedBox(height: 12),
              TotalFareCard(key: ValueKey('fare_$tripId')),
              const SizedBox(height: 12),
              StageCard(key: ValueKey('stage_$tripId')),
            ] else if (_mode == FareMode.multiStage) ...[
              const MultiStagePanel(),
            ] else ...[
              ReverseFareCard(key: ValueKey('reverse_$tripId')),
            ],

            if (_mode == FareMode.normal && hasNormaalTrip) ...[
              const SizedBox(height: 16),
              _CompleteTripButton(
                enabled: canCompleteNormal,
                onPressed: () => _completeCurrentTrip(),
              ),
            ],

            if (_mode == FareMode.multiStage && hasMultiStageTrip) ...[
              const SizedBox(height: 16),
              _CompleteTripButton(
                enabled: canCompleteMultiStage,
                onPressed: () => _completeCurrentTrip(),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _CompleteTripButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const _CompleteTripButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext contex) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Complete Trip'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.secondary.withValues(alpha: 0.25),
          disabledForegroundColor: AppColors.secondary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(14),
          ),
        ),
      ),
    );
  }
}
