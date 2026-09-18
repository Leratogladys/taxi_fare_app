import 'package:flutter/material.dart';
import '../mode_switcher.dart';

enum FareMode { normal, multiStage, reverse }

class FareModeToggle extends StatelessWidget {
  final FareMode mode;
  final void Function(FareMode) onChanged;

  const FareModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ModeSwitcher(
      options: const ['Calculate', 'Multi-stage', 'Reverse'],
      selectedIndex: mode == FareMode.normal
          ? 0
          : mode == FareMode.multiStage
              ? 1
              : 2,
      onChanged: (i) {
        switch (i) {
          case 0: onChanged(FareMode.normal);
          case 1: onChanged(FareMode.multiStage);
          case 2: onChanged(FareMode.reverse);
        }
      },
    );
  }
}