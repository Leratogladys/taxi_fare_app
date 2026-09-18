import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_fare_app/core/services/hive_service.dart';
import 'package:taxi_fare_app/routes/app_router.dart';
import 'package:taxi_fare_app/viewmodels/fare_viewmodels.dart';
import 'package:taxi_fare_app/viewmodels/payment_viewmodel.dart';
import 'package:taxi_fare_app/viewmodels/route_viewmodel.dart';
import 'package:taxi_fare_app/viewmodels/stage_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FareViewmodel()),
        ChangeNotifierProvider(create: (_) => PaymentViewmodel()),
        ChangeNotifierProvider(create: (_) => RouteViewmodel()),
        ChangeNotifierProvider(create: (_) => StageViewmodel()),
      ],
      child: MaterialApp(
        title: 'Taxi Maths Calculator',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: const Color(0xFF2D2B55)),
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: AppRoutes.home,
      ),
    );
  }
}