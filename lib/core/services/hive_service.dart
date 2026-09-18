import 'package:hive_flutter/hive_flutter.dart';
import '../../models/fare_model.dart';
import '../../models/payment_model.dart';
import '../../models/stage_model.dart';
import '../../models/trip_model.dart';
import '../../models/route_model.dart';

class HiveService {
  static const _activeFareBoxName     = 'active_fare';
  static const _activePaymentsBoxName = 'active_payments';
  static const _activeStagesBoxName   = 'active_stages';
  static const _tripHistoryBoxName    = 'trip_history';
  static const _routesBoxName         = 'routes';

  static Box<FareModel>    get activeFareBox     => Hive.box<FareModel>(_activeFareBoxName);
  static Box<PaymentModel> get activePaymentsBox => Hive.box<PaymentModel>(_activePaymentsBoxName);
  static Box<StageModel>   get activeStagesBox   => Hive.box<StageModel>(_activeStagesBoxName);
  static Box<TripModel>    get tripHistoryBox    => Hive.box<TripModel>(_tripHistoryBoxName);
  static Box<RouteModel>   get routesBox         => Hive.box<RouteModel>(_routesBoxName);

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(FareModelAdapter());
    Hive.registerAdapter(PaymentModelAdapter());
    Hive.registerAdapter(StageModelAdapter());
    Hive.registerAdapter(TripModelAdapter());
    Hive.registerAdapter(RouteModelAdapter());
    await Hive.openBox<FareModel>(_activeFareBoxName);
    await Hive.openBox<PaymentModel>(_activePaymentsBoxName);
    await Hive.openBox<StageModel>(_activeStagesBoxName);
    await Hive.openBox<TripModel>(_tripHistoryBoxName);
    await Hive.openBox<RouteModel>(_routesBoxName);
  }
}