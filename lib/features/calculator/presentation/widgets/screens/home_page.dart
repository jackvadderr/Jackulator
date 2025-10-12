import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/calculator_provider.dart';
import '../blocks/basic_keypad.dart';
import '../blocks/display_panel.dart';
import '../blocks/scientific_keypad.dart';
import '../layouts/main_layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();

    return MainLayout(
      title: 'Jackulator',
      child: Column(
        children: [
          // Display area (4 parts)
          Expanded(
            flex: provider.mode == CalculatorMode.basic ? 3 : 2,
            child: DisplayPanel(
              angleUnitLabel: provider.angleUnitLabel,
              expression: provider.liveDisplayExpression,
              result: provider.hasResultForDisplay
                  ? provider.formattedOutput
                  : '',
              bottomInfo: '',
            ),
          ),

          // Keypads composition (Blocks)
          Expanded(
            flex: provider.mode == CalculatorMode.basic ? 5 : 7,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
              child: Column(
                children: [
                  if (provider.mode == CalculatorMode.scientific)
                    ScientificKeypad(onPressed: provider.onButtonPressed),

                  // Basic 5x5 keypad grid
                  Expanded(
                    child: BasicKeypad(
                      clearButtonLabel: provider.clearButtonLabel,
                      isMemorySet: provider.isMemorySet,
                      onPressed: provider.onButtonPressed,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
