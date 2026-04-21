import 'package:flutter/material.dart';
import 'package:taxi_fare_app/routes/app_router.dart';
import 'home/home_view.dart';
import 'tracking/tracking_view.dart';
import 'change/change_view.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int index = 0;

  final pages = const [HomeView(), TrackingView(), ChangeView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
        backgroundColor: const Color(0xFF2D2B55),
        selectedItemColor: const Color(0xFFA1C2BD),
        unselectedItemColor: const Color(0xFF708993),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.money), label: "Change"),
        ],
      ),
    );  
  }

  
}
