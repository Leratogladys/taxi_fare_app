import 'package:flutter/material.dart';
import '../models/fare_model.dart';

class FareViewmodel extends ChangeNotifier {
  FareModel _fare = FareModel(seats: 0, farePerPerson: 0);

  FareModel get fare => _fare;

  void updateSeats(int seats) {
    _fare = _fare.copywith(seats: seats);

    notifyListeners();
  }

  void updateFare(int farePerPerson) {
    _fare = _fare.copywith(farePerPerson: farePerPerson);

    notifyListeners();
  }

  void setFare(int seats, int farePerPerson) {
    _fare = _fare.copywith(seats: seats, farePerPerson: farePerPerson);

    notifyListeners();
  }

  void reset() {
    _fare = FareModel(seats: 0, farePerPerson: 0);

    notifyListeners();
  }
}
