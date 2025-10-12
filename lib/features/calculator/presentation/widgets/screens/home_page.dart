import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/calculator_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();

    // Layouts
    final basicLayout = [
      ['AC', '±', '%', '÷', 'MC'],
      ['7', '8', '9', '×', 'MR'],
      ['4', '5', '6', '-', 'M+'],
      ['1', '2', '3', '+', 'M-'],
      ['0', '.', '=', ' ', 'MS'],
    ];

    final scientificLayout = [
      ['sin', 'cos', 'tan', '√', 'x²'],
      ['ln', 'log', '(', ')', '%'],
      ['AC', '±', '÷', '×', 'MC'],
      ['7', '8', '9', '-', 'MR'],
      ['4', '5', '6', '+', 'M+'],
      ['1', '2', '3', ' ', 'M-'],
      ['0', '.', '=', ' ', 'MS'],
    ];

    final currentLayout = provider.mode == CalculatorMode.basic
        ? basicLayout
        : scientificLayout;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header: Mode icon toggle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.all(8),
                    onPressed: () {
                      final next = provider.mode == CalculatorMode.basic
                          ? CalculatorMode.scientific
                          : CalculatorMode.basic;
                      provider.setMode(next);
                    },
                    child: const Icon(
                      Icons.science_outlined,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              ),
            ),

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

            // Keypad
            Expanded(
              flex: provider.mode == CalculatorMode.basic ? 5 : 7,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
                child: Column(
                  children: currentLayout.map((row) {
                    return Expanded(
                      child: Row(
                        children: row.map((label) {
                          if (label == ' ') return const Spacer();
                          final isOp = [
                            '÷',
                            '×',
                            '-',
                            '+',
                            '=',
                          ].contains(label);
                          final isFunc = ['AC', '±', '%'].contains(label);
                          final isMemory = [
                            'MC',
                            'MR',
                            'M+',
                            'M-',
                            'MS',
                          ].contains(label);
                          final bg = isOp
                              ? CupertinoColors.systemOrange
                              : isFunc
                              ? const Color(0xFFa5a5a5)
                              : isMemory
                              ? const Color(0xFF505050)
                              : const Color(0xFF333333);
                          final textColor = isFunc
                              ? CupertinoColors.black
                              : CupertinoColors.white;
                          int flex = (label == '0' || label == '=') ? 2 : 1;

                          return Expanded(
                            flex: flex,
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: _CalcButton(
                                text: label == 'AC'
                                    ? provider.clearButtonLabel
                                    : label,
                                backgroundColor: bg,
                                textColor: textColor,
                                onPressed: () {
                                  final effective = label == 'AC'
                                      ? provider.clearButtonLabel
                                      : label;
                                  provider.onButtonPressed(effective);
                                },
                                enabled:
                                    !((label == 'MC' || label == 'MR') &&
                                        !provider.isMemorySet),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalcButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;
  final bool enabled;

  const _CalcButton({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: enabled ? backgroundColor : const Color(0xFF6e6e6e),
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      onPressed: enabled ? onPressed : null,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
