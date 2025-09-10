
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../provider/calculator_provider.dart';
import '../widgets/calculator_button.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calculator = context.watch<CalculatorProvider>();
    
    // --- Color Palette for our Unique Identity ---
    const Color functionButtonColor = Color(0xFFa5a5a5); // Light gray for top functions
    const Color numberButtonColor = Color(0xFF333333);   // Dark gray for numbers
    const Color operatorButtonColor = CupertinoColors.systemOrange; // Orange for operators
    const Color memoryButtonColor = Color(0xFF505050);    // A distinct medium gray for the sidecar

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            // Display Area
            Expanded(
              flex: 3,
              child: GestureDetector(
                  onHorizontalDragEnd: (details) => context.read<CalculatorProvider>().backspace(),
                  child: Container(
                    alignment: Alignment.bottomRight,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (calculator.isMemorySet)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 8.0),
                            child: Text('M', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: CupertinoColors.white)),
                          ),
                        FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            calculator.formattedOutput,
                            style: const TextStyle(fontSize: 96, fontWeight: FontWeight.w200, color: CupertinoColors.white),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
              ),
            ),

            // Button Grid Area: The "Sidecar" Layout (5x5)
            Expanded(
              flex: 6,
              child: Column(
                children: [
                  // Row 1
                  _buildButtonRow([
                    CalculatorButton(text: calculator.clearButtonLabel, backgroundColor: functionButtonColor, textColor: CupertinoColors.black),
                    CalculatorButton(text: '±', backgroundColor: functionButtonColor, textColor: CupertinoColors.black),
                    CalculatorButton(text: '%', backgroundColor: functionButtonColor, textColor: CupertinoColors.black),
                    CalculatorButton(text: '÷', backgroundColor: operatorButtonColor, isSelected: calculator.activeOperator == '÷'),
                    CalculatorButton(text: 'MC', backgroundColor: memoryButtonColor, isEnabled: calculator.isMemorySet),
                  ]),
                  // Row 2
                  _buildButtonRow([
                    CalculatorButton(text: '7', backgroundColor: numberButtonColor),
                    CalculatorButton(text: '8', backgroundColor: numberButtonColor),
                    CalculatorButton(text: '9', backgroundColor: numberButtonColor),
                    CalculatorButton(text: '×', backgroundColor: operatorButtonColor, isSelected: calculator.activeOperator == '×'),
                    CalculatorButton(text: 'MR', backgroundColor: memoryButtonColor, isEnabled: calculator.isMemorySet),
                  ]),
                  // Row 3
                  _buildButtonRow([
                    CalculatorButton(text: '4', backgroundColor: numberButtonColor),
                    CalculatorButton(text: '5', backgroundColor: numberButtonColor),
                    CalculatorButton(text: '6', backgroundColor: numberButtonColor),
                    CalculatorButton(text: '-', backgroundColor: operatorButtonColor, isSelected: calculator.activeOperator == '-'),
                    CalculatorButton(text: 'M+', backgroundColor: memoryButtonColor),
                  ]),
                  // Row 4
                  _buildButtonRow([
                    CalculatorButton(text: '1', backgroundColor: numberButtonColor),
                    CalculatorButton(text: '2', backgroundColor: numberButtonColor),
                    CalculatorButton(text: '3', backgroundColor: numberButtonColor),
                    CalculatorButton(text: '+', backgroundColor: operatorButtonColor, isSelected: calculator.activeOperator == '+'),
                    CalculatorButton(text: 'M-', backgroundColor: memoryButtonColor),
                  ]),
                  // Row 5
                  _buildButtonRow([
                    CalculatorButton(text: '0', backgroundColor: numberButtonColor, flex: 2, alignment: Alignment.centerLeft),
                    CalculatorButton(text: '.', backgroundColor: numberButtonColor),
                    CalculatorButton(text: '=', backgroundColor: operatorButtonColor),
                    CalculatorButton(text: 'MS', backgroundColor: memoryButtonColor),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<Widget> buttons) {
    return Expanded(
      flex: 1,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons,
      ),
    );
  }
}
