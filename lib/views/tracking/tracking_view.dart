import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/hive_service.dart';
import '../../models/trip_model.dart';

class TrackingView extends StatelessWidget {
  const TrackingView({super.key});

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  $h:$m';
  }

  Future<void> _confirmClear(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Clear history?',
          style: TextStyle(color: AppColors.accent),
        ),
        content: const Text(
          'All completed trips will be permanently deleted.',
          style: TextStyle(color: AppColors.secondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      HiveService.tripHistoryBox.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trip History'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppColors.secondary,
            tooltip: 'Clear history',
            onPressed: () => _confirmClear(context),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: HiveService.tripHistoryBox.listenable(),
        builder: (context, Box<TripModel> box, _) {
          if (box.isEmpty) return const _EmptyState();

          final trips = box.values.toList().reversed.toList();
          final totalRevenue = trips.fold(0, (sum, t) => sum + t.totalRevenue);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _SummaryBanner(
                  tripCount: trips.length,
                  totalRevenue: totalRevenue,
                ),
                const SizedBox(height: 16),
                ...trips.map(
                  (trip) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _TripCard(
                      trip: trip,
                      formattedDate: _formatDate(trip.completedAt),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  final int tripCount;
  final int totalRevenue;

  const _SummaryBanner({required this.tripCount, required this.totalRevenue});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat(label: 'Total trips', value: '$tripCount'),
          Container(width: 1, height: 36, color: Colors.white24),
          _Stat(label: 'Total revenue', value: 'R$totalRevenue'),
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

class _TripCard extends StatelessWidget {
  final TripModel trip;
  final String formattedDate;

  const _TripCard({required this.trip, required this.formattedDate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedDate,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                trip.isMultiStage
                    ? '${trip.stageCount} stages'
                    : '${trip.totalSeats} seats @ R${trip.farePerPerson}',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          if (trip.routeSummary != '— → —') ...[
            const SizedBox(height: 6),
            Text(
              trip.routeSummary,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              _TripStat(
                label: 'Revenue',
                value: 'R${trip.totalRevenue}',
                highlight: true,
              ),
              const SizedBox(width: 24),
              _TripStat(label: 'Passengers', value: '${trip.totalPassengers}'),
              const SizedBox(width: 24),
              _TripStat(label: 'Change given', value: 'R${trip.totalChange}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TripStat extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _TripStat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: highlight ? AppColors.accent : AppColors.secondary,
            fontSize: highlight ? 18 : 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.secondary, fontSize: 11),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 56, color: AppColors.secondary),
          SizedBox(height: 16),
          Text(
            'No trips yet',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Completed trips will appear here',
            style: TextStyle(color: AppColors.secondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
