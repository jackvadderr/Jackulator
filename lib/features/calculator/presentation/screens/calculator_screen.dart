
import '''package:flutter/cupertino.dart''';
import '''package:provider/provider.dart''';

import '''../provider/calculator_provider.dart''';
import '''../widgets/calculator_button.dart''';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calculator = context.watch<CalculatorProvider>();

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            // Display Area
            Expanded(
              flex: 2,
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  context.read<CalculatorProvider>().backspace();
                },
                child: Container(
                  color: CupertinoColors.black.withOpacity(0.0),
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  // This is where the magic happens!
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      // A combination of fade and scale looks elegant.
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    // The child of the AnimatedSwitcher.
                    child: FittedBox(
                      // IMPORTANT: The Key tells the AnimatedSwitcher that the widget
                      // has actually changed, triggering the animation.
                      key: ValueKey<String>(calculator.formattedOutput),
                      fit: BoxFit.contain,
                      child: Text(
                        calculator.formattedOutput,
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.w300,
                          color: CupertinoColors.white,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Button Grid Area
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  // ... (rest of the buttons are unchanged)
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CalculatorButton(
                          text: 'C',
                          backgroundColor: CupertinoColors.lightBackgroundGray,
                          textColor: CupertinoColors.black,
                        ),
                        CalculatorButton(
                          text: '±',
                          backgroundColor: CupertinoColors.lightBackgroundGray,
                          textColor: CupertinoColors.black,
                        ),
                        CalculatorButton(
                          text: '%',
                          backgroundColor: CupertinoColors.lightBackgroundGray,
                          textColor: CupertinoColors.black,
                        ),
                        CalculatorButton(
                          text: '÷',
                          backgroundColor: CupertinoColors.systemOrange,
                          isSelected: calculator.activeOperator == '÷',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CalculatorButton(text: '7'),
                        CalculatorButton(text: '8'),
                        CalculatorButton(text: '9'),
                        CalculatorButton(
                          text: '×',
                          backgroundColor: CupertinoColors.systemOrange,
                          isSelected: calculator.activeOperator == '×',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CalculatorButton(text: '4'),
                        CalculatorButton(text: '5'),
                        CalculatorButton(text: '6'),
                        CalculatorButton(
                          text: '-',
                          backgroundColor: CupertinoColors.systemOrange,
                          isSelected: calculator.activeOperator == '-',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CalculatorButton(text: '1'),
                        CalculatorButton(text: '2'),
                        CalculatorButton(text: '3'),
                        CalculatorButton(
                          text: '+',
                          backgroundColor: CupertinoColors.systemOrange,
                          isSelected: calculator.activeOperator == '+',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CalculatorButton(text: '0', flex: 2, alignment: Alignment.centerLeft),
                        CalculatorButton(text: '.'),
                        CalculatorButton(
                          text: '=',
                          backgroundColor: CupertinoColors.systemOrange,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
