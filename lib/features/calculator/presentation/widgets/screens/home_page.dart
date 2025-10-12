import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/calculator_provider.dart';
import '../base/primary_button.dart';
import '../base/secondary_button.dart';
import '../blocks/functions_keypad.dart';
import '../blocks/memory_keypad.dart';
import '../blocks/numeric_keypad.dart';
import '../blocks/operations_keypad.dart';
import '../blocks/scientific_keypad.dart';
import '../layouts/main_layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();

    final headerActions = <Widget>[
      SecondaryButton(
        label: 'Mode',
        icon: Icons.science_outlined,
        onPressed: () {
          final next = provider.mode == CalculatorMode.basic
              ? CalculatorMode.scientific
              : CalculatorMode.basic;
          provider.setMode(next);
        },
      ),
      const SizedBox(width: 8),
      PrimaryButton(
        label: provider.clearButtonLabel,
        onPressed: () {
          final effective = provider.clearButtonLabel;
          provider.onButtonPressed(effective);
        },
      ),
    ];

    return MainLayout(
      title: 'Jackulator',
      actions: headerActions,
      footerChild: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SecondaryButton(
            label: 'MS',
            icon: Icons.save_outlined,
            onPressed: () => provider.onButtonPressed('MS'),
          ),
        ],
      ),
      child: Column(
        children: [
          // Display area
          Expanded(
            flex: provider.mode == CalculatorMode.basic ? 3 : 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 40,
                    child: SingleChildScrollView(
                      reverse: true,
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        provider.displayExpression,
                        style: const TextStyle(
                          color: CupertinoColors.systemGrey,
                          fontSize: 28,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    key: const Key('display_output'),
                    alignment: Alignment.centerRight,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        provider.formattedOutput,
                        style: const TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 80,
                          fontWeight: FontWeight.w200,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
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

                  // Functions row
                  FunctionsKeypad(
                    clearButtonLabel: provider.clearButtonLabel,
                    onPressed: provider.onButtonPressed,
                  ),

                  // Numeric area + Operations column
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: NumericKeypad(
                            onPressed: provider.onButtonPressed,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: OperationsKeypad(
                            onPressed: provider.onButtonPressed,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Memory row
                  MemoryKeypad(
                    isMemorySet: provider.isMemorySet,
                    onPressed: provider.onButtonPressed,
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
