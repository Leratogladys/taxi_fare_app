import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:taxi_fare_app/main.dart';
import 'package:taxi_fare_app/models/fare_model.dart';
import 'package:taxi_fare_app/models/payment_model.dart';
import 'package:taxi_fare_app/models/route_model.dart';
import 'package:taxi_fare_app/models/stage_model.dart';
import 'package:taxi_fare_app/models/trip_model.dart';

late Directory hiveTestDirectory;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    hiveTestDirectory =
        await Directory.systemTemp.createTemp('taximaths_test_');
    Hive.init(hiveTestDirectory.path);

    Hive.registerAdapter(FareModelAdapter());
    Hive.registerAdapter(PaymentModelAdapter());
    Hive.registerAdapter(StageModelAdapter());
    Hive.registerAdapter(TripModelAdapter());
    Hive.registerAdapter(RouteModelAdapter());

    await Hive.openBox<FareModel>('active_fare');
    await Hive.openBox<PaymentModel>('active_payments');
    await Hive.openBox<StageModel>('active_stages');
    await Hive.openBox<TripModel>('trip_history');
    await Hive.openBox<RouteModel>('routes');
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveTestDirectory.delete(recursive: true);
  });

  testWidgets('TaxiMaths home screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Taxi Calculator'), findsOneWidget);
    expect(find.text('FARE CALCULATION'), findsOneWidget);
  });
}