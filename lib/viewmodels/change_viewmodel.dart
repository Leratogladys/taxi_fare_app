import 'package:flutter/material.dart';
import '../models/payment_model.dart';
import 'payment_viewmodel.dart';

class ChangeViewmodel extends ChangeNotifier {
  int calculateTotalChange(List<PaymentModel> payments) {
    return payments.fold(0, (sum, p) => sum + p.change);
  }

  int remainingChange(List<PaymentModel> payments) {
    return payments.where((p) => !p.completed).fold(0, (sum, p) => p.change);
  }

  List<PaymentModel> markAsGiven(List<PaymentModel> payments, int index) {
    final updated = [...payments];
    updated[index] = updated[index].copywith(completed: true);
    return updated;
  }
}
