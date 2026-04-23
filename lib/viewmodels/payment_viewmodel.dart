import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import 'fare_viewmodels.dart';

class PaymentViewmodel extends ChangeNotifier {
  final List<PaymentModel> _payments = [];

  List<PaymentModel> get payments => _payments;

  int get totalPaid => _payments.fold(0, (sum, p) => sum + p.amount);

  int get passengersPaid => _payments.fold(0, (sum, p) => sum + p.passengers);

  void addPayment({
    required int amount,
    required int passengers,
    required int farePerPassengers,
  }) {
    final totalDue = passengers * farePerPassengers;
    final change = amount - totalDue;

    _payments.add(
      PaymentModel(
        amount: amount,
        passengers: passengers,
        change: change > 0 ? change : 0,
      ),
    );

    notifyListeners();
  }

  void clear() {
    _payments.clear();
    notifyListeners();
  }
}
