import 'package:hive/hive.dart';

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
      completed: completed ?? this.completed,
    );
  }
}

class PaymentModelAdapter extends TypeAdapter<PaymentModel> {
  @override
  final int typeId = 1;

  @override
  PaymentModel read(BinaryReader reader) {
    return PaymentModel(
      amount: reader.readInt(),
      passengers: reader.readInt(),
      change: reader.readInt(),
      completed: reader.readBool(),
    );
  }

  @override
  void write(BinaryWriter writer, PaymentModel obj) {
    writer.writeInt(obj.amount);
    writer.writeInt(obj.passengers);
    writer.writeInt(obj.change);
    writer.writeBool(obj.completed);
  }
}
