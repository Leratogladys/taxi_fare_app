import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Taxi Calculator"),
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _card("Status Card"),
            const SizedBox(height: 10),
            _card("Fare Calculation"),
            const SizedBox(height: 10),
            _card("Record Payment"),
          ],
        ),
      ),
    );
  }

  Widget _card(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.text)),
    );
  }
}