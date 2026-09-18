import 'package:flutter/material.dart';
import '../models/stage_model.dart';
import '../models/payment_model.dart';
import '../models/trip_model.dart';
import '../core/services/hive_service.dart';

class StageViewmodel extends ChangeNotifier {
  List<StageModel> _stages = [];

  List<StageModel> get stages => _stages;
  bool get hasStages => _stages.isNotEmpty;
  StageModel? get activeStage => _stages.isEmpty ? null : _stages.last;
  int get activeStageIndex => _stages.isEmpty ? -1 : _stages.length - 1;
  bool get activeStageComplete => activeStage?.isComplete ?? false;
  bool get canAddStage => _stages.isEmpty || activeStageComplete;

  int get totalCollected => _stages.fold(0, (sum, s) => sum + s.totalCollected);
  int get totalPassengers =>
      _stages.fold(0, (sum, s) => sum + s.passengersPaid);
  int get totalPendingChange =>
      _stages.fold(0, (sum, s) => sum + s.totalPendingChange);
  bool get canCompleteTrip =>
      _stages.isNotEmpty &&
      _stages.every((stage) => stage.isComplete) &&
      totalPendingChange == 0;

  StageViewmodel() {
    _loadFromHive();
  }

  void _loadFromHive() {
    _stages = HiveService.activeStagesBox.values.toList();
  }

  Future<void> _persistStages() async {
    await HiveService.activeStagesBox.clear();
    for (final stage in _stages) {
      await HiveService.activeStagesBox.add(stage);
    }
  }

  Future<void> addStage({
    required String from,
    required String to,
    required int farePerPerson,
    required int totalSeats,
  }) async {
    _stages.add(
      StageModel(
        from: from,
        to: to,
        farePerPerson: farePerPerson,
        totalSeats: totalSeats,
        payments: [],
      ),
    );
    notifyListeners();
    await _persistStages();
  }

  Future<String?> addPaymentToActiveStage({
    required int amount,
    required int passengers,
  }) async {
    if (activeStage == null) {
      return 'No valid stage';
    }

    if (passengers <= 0) {
      return 'Enter a valid number of passengers';
    }

    if (amount <= 0) {
      return 'Enter a valid payment amount';
    }

    final remainingPassengers = activeStage!.remainingSeats;

    if (passengers > remainingPassengers) {
      return 'Only $remainingPassengers passenger'
          '${remainingPassengers == 1 ? '' : 's'} remaining';
    }

    final due = passengers * activeStage!.farePerPerson;

    if (amount < due) {
      final shortfall = due - amount;

      return 'Payment is R$shortfall short.'
          'Partial payments are not supported yet.';
    }

    final change = amount - due;

    final payment = PaymentModel(
      amount: amount,
      passengers: passengers,
      change: change,
    );

    _stages[activeStageIndex] = activeStage!.copyWith(
      payments: [...activeStage!.payments, payment],
    );

    notifyListeners();

    await _persistStages();

    return null;
  }

  Future<void> markChangeAsGiven(int stageIndex, int paymentIndex) async {
    if (stageIndex < 0 || stageIndex >= _stages.length) return;
    final stage = _stages[stageIndex];
    if (paymentIndex < 0 || paymentIndex >= stage.payments.length) return;
    final updated = List<PaymentModel>.from(stage.payments);
    updated[paymentIndex] = updated[paymentIndex].copywith(completed: true);
    _stages[stageIndex] = stage.copyWith(payments: updated);
    notifyListeners();
    await _persistStages();
  }

  Future<void> saveAndStartNewTrip() async {
    if (_stages.isNotEmpty) {
      await HiveService.tripHistoryBox.add(
        TripModel(stages: List.from(_stages), completedAt: DateTime.now()),
      );
    }
    _stages.clear();
    notifyListeners();
    await HiveService.activeStagesBox.clear();
  }

  Future<void> clear() async {
    _stages.clear();
    notifyListeners();
    await HiveService.activeStagesBox.clear();
  }

  Future<bool> completeTrip() async {
    if (!canCompleteTrip) return false;

    await HiveService.tripHistoryBox.add(
      TripModel(stages: List.from(_stages), completedAt: DateTime.now()),
    );

    _stages.clear();
    notifyListeners();

    await HiveService.activeStagesBox.clear();

    return true;
  }
}
