import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../viewmodels/fare_viewmodels.dart';
import '../../viewmodels/payment_viewmodel.dart';

class StageCard extends StatefulWidget {
  const StageCard({super.key});

  @override
  State<StageCard> createState() => _StageCardState();
}

class _StageCardState extends State<StageCard> {
  final _passengersController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _passengersController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final fareVm = context.read<FareViewmodel>();
    final paymentVm = context.read<PaymentViewmodel>();

    final fare = fareVm.fare.farePerPerson;
    final seats = fareVm.fare.seats;
    final remaining = seats - paymentVm.passengersPaid;
    final passengers = int.tryParse(_passengersController.text);
    final amount = int.tryParse(_amountController.text);

    if (fare == 0 || seats == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Set seats and fare per seat above first'),
        ),
      );
      return;
    }

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
            'Only $remaining passenger${remaining == 1 ? '' : 's'} remaining',
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

    final error = await paymentVm.addPayment(
      amount: amount,
      passengers: passengers,
      farePerPassengers: fare,
      totalSeats: seats,
    );

    if (!context.mounted) return;

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
    final fareVm = context.watch<FareViewmodel>();
    final paymentVm = context.watch<PaymentViewmodel>();

    final fare = fareVm.fare.farePerPerson;
    final seats = fareVm.fare.seats;
    final remainingPassengers = seats - paymentVm.passengersPaid;
    final tripComplete = seats > 0 && paymentVm.passengersPaid == seats;

    final passengers = int.tryParse(_passengersController.text) ?? 0;
    final amount = int.tryParse(_amountController.text) ?? 0;
    final due = passengers * fare;
    final change = amount - due;
    final showPreview = fare > 0 && passengers > 0 && amount > 0;

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
          // Header row with remaining passenger badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RECORD PAYMENT',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              if (seats > 0)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tripComplete
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tripComplete
                        ? 'All seated'
                        : '$remainingPassengers remaining',
                    style: TextStyle(
                      color: tripComplete
                          ? AppColors.primary
                          : AppColors.accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          // Trip complete state — hide form, show confirmation
          if (tripComplete) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
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
            // Input form — only shown while passengers remain
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _InputField(
                    label: 'Passengers',
                    controller: _passengersController,
                    hint: seats > 0 ? 'max $remainingPassengers' : '0',
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
              const SizedBox(height: 14),
              _PreviewRow(label: 'Amount due', value: 'R$due'),
              const SizedBox(height: 4),
              _PreviewRow(
                label: change >= 0 ? 'Change to give' : 'Shortfall',
                value: 'R${change.abs()}',
                isHighlight: true,
                isError: change < 0,
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _submit(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
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

          // Summary bar — always visible once payments exist
          if (paymentVm.payments.isNotEmpty) ...[
            const SizedBox(height: 14),
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
                    '${paymentVm.passengersPaid} pax paid',
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'R${paymentVm.totalPaid} collected',
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
