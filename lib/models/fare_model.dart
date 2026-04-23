class FareModel {
  final int seats;
  final int farePerPerson;

  FareModel({required this.seats, required this.farePerPerson});

  int get totalFare => seats * farePerPerson;

  FareModel copywith({int? seats, int? farePerPerson}) {
    return FareModel(
      seats: seats?? this.seats,
      farePerPerson: farePerPerson ?? this.farePerPerson,
    );
  }
}
