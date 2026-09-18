import 'package:flutter/material.dart';
import '../models/fare_model.dart';
import '../models/payment_model.dart';
import '../models/stage_model.dart';
import '../models/trip_model.dart';
import '../core/services/hive_service.dart';

class PaymentViewmodel extends ChangeNotifier {
  List<PaymentModel> _payments = [];

  List<PaymentModel> get payments => _payments;

  int get totalPaid => _payments.fold(0, (sum, p) => sum + p.amount);
  int get passengersPaid => _payments.fold(0, (sum, p) => sum + p.passengers);

  List<MapEntry<int, PaymentModel>> get paymentsWithChange =>
      _payments.asMap().entries.where((e) => e.value.change > 0).toList();

  bool canCompleteTrip(FareModel fare) {
    return fare.seats > 0 &&
        _payments.isNotEmpty &&
        passengersPaid == fare.seats &&
        totalPendingChange == 0;
  }

  int get totalPendingChange => _payments
      .where((p) => p.change > 0 && !p.completed)
      .fold(0, (sum, p) => sum + p.change);

  PaymentViewmodel() {
    _loadFromHive();
  }

  void _loadFromHive() {
    _payments = HiveService.activePaymentsBox.values.toList();
  }

  Future<String?> addPayment({
    required int amount,
    required int passengers,
    required int farePerPassengers,
    required int totalSeats,
  }) async {
    if (passengers <= 0) {
      return 'Enter a valid number of passengers';
    }

    final remainingPassengers = totalSeats - passengersPaid;

    if (passengers > remainingPassengers) {
      return 'Only $remainingPassengers passenger'
          '${remainingPassengers == 1 ? '' : 's'} remaining';
    }

    final totalDue = passengers * farePerPassengers;

    if (amount < totalDue) {
      final shortfall = totalDue - amount;

      return 'Payment is R$shortfall short. '
          'Partial payments are not supported yet.';
    }

    final change = amount - totalDue;

    final payment = PaymentModel(
      amount: amount,
      passengers: passengers,
      change: change,
    );

    _payments.add(payment);

    notifyListeners();
    await HiveService.activePaymentsBox.add(payment);

    return null;
  }

  Future<void> markChangeAsGiven(int index) async {
    if (index < 0 || index >= _payments.length) return;
    _payments[index] = _payments[index].copywith(completed: true);

    notifyListeners();

    await HiveService.activePaymentsBox.putAt(index, _payments[index]);
  }

  Future<void> saveAndStartNewTrip(
    FareModel fare, {
    String from = '—',
    String to = '—',
  }) async {
    if (_payments.isNotEmpty) {
      final stage = StageModel(
        from: from,
        to: to,
        farePerPerson: fare.farePerPerson,
        totalSeats: fare.seats,
        payments: List.from(_payments),
      );
      await HiveService.tripHistoryBox.add(
        TripModel(stages: [stage], completedAt: DateTime.now()),
      );
    }
    _payments.clear();
    notifyListeners();
    await HiveService.activePaymentsBox.clear();
  }

  Future<void> clear() async {
    _payments.clear();
    notifyListeners();
    await HiveService.activePaymentsBox.clear();
  }

  Future<bool> completeTrip(
    FareModel fare, {
    String from = '—',
    String to = '—',
  }) async {
    if (!canCompleteTrip(fare)) return false;

    final stage = StageModel(
      from: from,
      to: to,
      farePerPerson: fare.farePerPerson,
      totalSeats: fare.seats,
      payments: List.from(_payments),
    );

    await HiveService.tripHistoryBox.add(
      TripModel(stages: [stage], completedAt: DateTime.now()),
    );

    _payments.clear();
    notifyListeners();

    await HiveService.activePaymentsBox.clear();

    return true;
  }
}
