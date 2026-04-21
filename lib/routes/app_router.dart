import 'package:flutter/material.dart';
import 'package:taxi_fare_app/views/main_navigation.dart';

class AppRoutes {
  static const home = '/';
  static const tracking = '/tracking';
  static const change = '/change';
}

class AppRouter {
  static Route generateRoute(RouteSettings settings) {
     switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const MainNavigation());

      case AppRoutes.tracking:
        return MaterialPageRoute(builder: (_) => const TrackingView());

      case AppRoutes.change:
        return MaterialPageRoute(builder: (_) => const ChangeView());

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Home")));
  }
}


class TrackingView extends StatelessWidget {
  const TrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Home")));
  }
}

class ChangeView extends StatelessWidget {
  const ChangeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Home")));
  }
}

