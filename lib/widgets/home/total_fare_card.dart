import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/fare_viewmodels.dart';
import '../../routes/route_library_sheet.dart';

class TotalFareCard extends StatefulWidget {
  const TotalFareCard({super.key});

  @override
  State<TotalFareCard> createState() => _TotalFareCardState();
}

class _TotalFareCardState extends State<TotalFareCard> {
  final _seatsController = TextEditingController();
  final _fareController = TextEditingController();
  late final FareViewmodel _fareVm;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _fareVm = context.read<FareViewmodel>();
      // Restore persisted values on restart
      if (_fareVm.fare.seats > 0) {
        _seatsController.text = _fareVm.fare.seats.toString();
      }
      if (_fareVm.fare.farePerPerson > 0) {
        _fareController.text = _fareVm.fare.farePerPerson.toString();
      }
      // Listen for external changes (route selection)
      _fareVm.addListener(_syncControllers);
      _initialized = true;
    }
  }

  // Fires when a route is applied from RouteLibrarySheet
  void _syncControllers() {
    final newFare = _fareVm.fare.farePerPerson;
    final newSeats = _fareVm.fare.seats;
    if (newFare == 0) {
      _fareController.clear();
    } else if (_fareController.text != newFare.toString()) {
      _fareController.text = newFare.toString();
    }
    if (newSeats == 0) {
      _seatsController.clear();
    } else if (_seatsController.text != newSeats.toString()) {
      _seatsController.text = newSeats.toString();
    }
  }

  @override
  void dispose() {
    _fareVm.removeListener(_syncControllers);
    _seatsController.dispose();
    _fareController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FareViewmodel>();
    final totalFare = vm.fare.seats * vm.fare.farePerPerson;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'FARE CALCULATION',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              GestureDetector(
                onTap: () => RouteLibrarySheet.show(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.route_outlined,
                        size: 13,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        vm.selectedRoute != null
                            ? vm.selectedRoute!.displayName
                            : 'Routes',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InputField(
                  label: 'Seats',
                  controller: _seatsController,
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null) {
                      context.read<FareViewmodel>().updateSeats(n);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InputField(
                  label: 'Fare per seat (R)',
                  controller: _fareController,
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null) {
                      context.read<FareViewmodel>().updateFare(n);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Fare',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  'R$totalFare',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final void Function(String) onChanged;

  const _InputField({
    required this.label,
    required this.controller,
    required this.onChanged,
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
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              return RegExp(r'^\d*$').hasMatch(newValue.text)
                  ? newValue
                  : oldValue;
            }),
          ],
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
            hintText: '0',
            hintStyle: const TextStyle(color: AppColors.secondary),
          ),
        ),
      ],
    );
  }
}
