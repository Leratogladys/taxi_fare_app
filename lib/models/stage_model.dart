import 'package:hive/hive.dart';
import 'payment_model.dart';

class StageModel {
  final String from;
  final String to;
  final int farePerPerson;
  final int totalSeats;
  final List<PaymentModel> payments;

  StageModel({
    required this.from,
    required this.to,
    required this.farePerPerson,
    required this.totalSeats,
    required this.payments,
  });

  String get displayName => '$from → $to';
  int get totalFare => totalSeats * farePerPerson;
  int get passengersPaid => payments.fold(0, (sum, p) => sum + p.passengers);
  int get totalCollected => payments.fold(0, (sum, p) => sum + p.amount);
  int get totalChange => payments.fold(0, (sum, p) => sum + p.change);
  int get remainingSeats => totalSeats - passengersPaid;
  bool get isComplete => totalSeats > 0 && passengersPaid == totalSeats;

  int get totalPendingChange => payments
      .where((p) => p.change > 0 && !p.completed)
      .fold(0, (sum, p) => sum + p.change);

  List<MapEntry<int, PaymentModel>> get paymentsWithChange =>
      payments.asMap().entries.where((e) => e.value.change > 0).toList();

  StageModel copyWith({List<PaymentModel>? payments}) => StageModel(
    from: from,
    to: to,
    farePerPerson: farePerPerson,
    totalSeats: totalSeats,
    payments: payments ?? this.payments,
  );
}

class StageModelAdapter extends TypeAdapter<StageModel> {
  @override
  final int typeId = 4;

  @override
  StageModel read(BinaryReader reader) {
    final from = reader.readString();
    final to = reader.readString();
    final farePerPerson = reader.readInt();
    final totalSeats = reader.readInt();
    final count = reader.readInt();
    final payments = List.generate(
      count,
      (_) => PaymentModel(
        amount: reader.readInt(),
        passengers: reader.readInt(),
        change: reader.readInt(),
        completed: reader.readBool(),
      ),
    );
    return StageModel(
      from: from,
      to: to,
      farePerPerson: farePerPerson,
      totalSeats: totalSeats,
      payments: payments,
    );
  }

  @override
  void write(BinaryWriter writer, StageModel obj) {
    writer.writeString(obj.from);
    writer.writeString(obj.to);
    writer.writeInt(obj.farePerPerson);
    writer.writeInt(obj.totalSeats);
    writer.writeInt(obj.payments.length);
    for (final p in obj.payments) {
      writer.writeInt(p.amount);
      writer.writeInt(p.passengers);
      writer.writeInt(p.change);
      writer.writeBool(p.completed);
    }
  }
}
