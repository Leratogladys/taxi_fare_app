import 'package:hive/hive.dart';
import 'stage_model.dart';
import 'payment_model.dart';

class TripModel {
  final List<StageModel> stages;
  final DateTime completedAt;

  TripModel({required this.stages, required this.completedAt});

  int get totalCollected => stages.fold(0, (sum, s) => sum + s.totalCollected);
  int get totalPassengers => stages.fold(0, (sum, s) => sum + s.passengersPaid);
  int get totalChange => stages.fold(0, (sum, s) => sum + s.totalChange);
  int get totalRevenue => totalCollected - totalChange;
  int get expectedRevenue => stages.fold(0, (sum, s) => sum + s.totalFare);
  int get stageCount => stages.length;
  bool get isMultiStage => stages.length > 1;

  // For single-stage history card display
  int get farePerPerson => stages.isEmpty ? 0 : stages.first.farePerPerson;
  int get totalSeats => stages.isEmpty ? 0 : stages.first.totalSeats;
  String get routeSummary => isMultiStage
      ? '${stages.first.from} → ${stages.last.to}'
      : stages.isEmpty
      ? '—'
      : stages.first.displayName;
}

class TripModelAdapter extends TypeAdapter<TripModel> {
  @override
  final int typeId = 2;

  @override
  TripModel read(BinaryReader reader) {
    final completedAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final stageCount = reader.readInt();
    final stages = List.generate(stageCount, (_) {
      final from = reader.readString();
      final to = reader.readString();
      final farePerPerson = reader.readInt();
      final totalSeats = reader.readInt();
      final paymentCount = reader.readInt();
      final payments = List.generate(
        paymentCount,
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
    });
    return TripModel(stages: stages, completedAt: completedAt);
  }

  @override
  void write(BinaryWriter writer, TripModel obj) {
    writer.writeInt(obj.completedAt.millisecondsSinceEpoch);
    writer.writeInt(obj.stages.length);
    for (final s in obj.stages) {
      writer.writeString(s.from);
      writer.writeString(s.to);
      writer.writeInt(s.farePerPerson);
      writer.writeInt(s.totalSeats);
      writer.writeInt(s.payments.length);
      for (final p in s.payments) {
        writer.writeInt(p.amount);
        writer.writeInt(p.passengers);
        writer.writeInt(p.change);
        writer.writeBool(p.completed);
      }
    }
  }
}
