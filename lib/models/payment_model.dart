class PaymentModel {
  final int amount;
  final int passengers;
  final int change;
  final bool completed;

  PaymentModel({
    required this.amount,
    required this.passengers,
    required this.change,
    this.completed = false,
  });

  PaymentModel copywith({
    int? amount,
    int? passengers,
    int? change,
    bool? completed,
  }) {
    return PaymentModel(
      amount: amount ?? this.amount,
      passengers: passengers ?? this.passengers,
      change: change ?? this.change,
    );
  }
}
