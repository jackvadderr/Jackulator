
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'features/calculator/presentation/provider/calculator_provider.dart';
import 'features/calculator/presentation/widgets/calculator_button.dart';

class CalculatorHome extends StatelessWidget {
  const CalculatorHome({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CalculatorProvider>(context);

    // --- Color Palette ---
    const Color numberButtonColor = Color(0xFF333333);
    const Color operatorButtonColor = CupertinoColors.systemOrange;
    const Color functionButtonColor = Color(0xFFa5a5a5);
    const Color memoryButtonColor = Color(0xFF505050);
    const Color scientificButtonColor = Color(0xFF1c1c1e);
    const Color disabledButtonColor = Color(0xFF6e6e6e);

    // --- Button Layouts ---
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

    final currentLayout = provider.mode == CalculatorMode.basic ? basicLayout : scientificLayout;

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        bottom: false, // Prevent safe area padding at the bottom
        child: Column(
          children: [
            // --- Display Area ---
            Expanded(
              flex: provider.mode == CalculatorMode.basic ? 3 : 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Expression Display
                    SizedBox(
                      height: 40,
                      child: SingleChildScrollView(
                        reverse: true,
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          provider.displayExpression,
                          style: const TextStyle(color: CupertinoColors.systemGrey, fontSize: 28),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Main Output Display
                    GestureDetector(
                      onHorizontalDragEnd: (details) => provider.backspace(),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          provider.formattedOutput,
                          style: const TextStyle(color: CupertinoColors.white, fontSize: 80, fontWeight: FontWeight.w200),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                    // Top Row Controls (Undo/Redo)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(onPressed: () => _showHistory(context, provider), child: const Icon(CupertinoIcons.time, color: CupertinoColors.white, size: 30)),
                        Row(
                          children: [
                            CupertinoButton(onPressed: provider.canUndo ? provider.undo : null, child: Icon(CupertinoIcons.arrow_uturn_left, color: provider.canUndo ? CupertinoColors.white : disabledButtonColor, size: 30)),
                            const SizedBox(width: 16),
                            CupertinoButton(onPressed: provider.canRedo ? provider.redo : null, child: Icon(CupertinoIcons.arrow_uturn_right, color: provider.canRedo ? CupertinoColors.white : disabledButtonColor, size: 30)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            // --- Mode Selector ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: CupertinoSlidingSegmentedControl<CalculatorMode>(
                backgroundColor: const Color(0xFF1c1c1e),
                thumbColor: const Color(0xFF505050),
                groupValue: provider.mode,
                onValueChanged: (CalculatorMode? newMode) {
                  if (newMode != null) provider.setMode(newMode);
                },
                children: const {
                  CalculatorMode.basic: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Básico', style: TextStyle(color: CupertinoColors.white))),
                  CalculatorMode.scientific: Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text('Científico', style: TextStyle(color: CupertinoColors.white))),
                },
              ),
            ),
            // --- Button Grid ---
            Expanded(
              flex: provider.mode == CalculatorMode.basic ? 5 : 7, // Adjust flex factors
              child: Container(
                padding: const EdgeInsets.only(bottom: 20), // Padding for home bar
                child: Column(
                  children: currentLayout.map((row) {
                    return Expanded(
                      child: Row(
                        children: row.map((label) {
                          if (label == ' ') return const Spacer();
                          int flex = (label == '0' || label == '=') ? 2 : 1;
                          Color buttonColor;
                          final isScientificFunc = provider.mode == CalculatorMode.scientific && ('sin cos tan √ x² ln log ( ) '.contains(label));
                          if (['÷', '×', '-', '+', '='].contains(label)) {
                            buttonColor = operatorButtonColor;
                          } else if (['AC', '±', '%'].contains(label)) buttonColor = functionButtonColor;
                          else if (['MC', 'MR', 'M+', 'M-', 'MS'].contains(label)) buttonColor = memoryButtonColor;
                          else if (isScientificFunc) buttonColor = scientificButtonColor;
                          else buttonColor = numberButtonColor;
                          return Expanded(
                            flex: flex,
                            child: CalculatorButton(
                              label: label == 'AC' ? provider.clearButtonLabel : label,
                              backgroundColor: buttonColor,
                              isOperator: ['÷', '×', '-', '+', '='].contains(label),
                              isActive: false, // Active state no longer needed with expression display
                              onTap: () => provider.onButtonPressed(label),
                              isDisabled: (label == 'MC' || label == 'MR') && !provider.isMemorySet,
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

  void _showHistory(BuildContext context, CalculatorProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2e2e2e),
      builder: (context) {
        return Column(
          children: [
            const Padding(padding: EdgeInsets.all(16.0), child: Text('Histórico de Cálculos', style: TextStyle(color: CupertinoColors.white, fontSize: 20, fontWeight: FontWeight.bold))),
            Expanded(
              child: provider.calculationHistory.isEmpty
                  ? const Center(child: Text('Nenhum cálculo registrado.', style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 16)))
                  : ListView.builder(
                      itemCount: provider.calculationHistory.length,
                      itemBuilder: (context, index) {
                        final entry = provider.calculationHistory.reversed.toList()[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Text(entry, style: const TextStyle(color: CupertinoColors.white, fontSize: 18), textAlign: TextAlign.right),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
