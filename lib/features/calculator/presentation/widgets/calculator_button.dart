
import '''package:flutter/cupertino.dart''';
import '''package:flutter/services.dart'''; // Import the services package for HapticFeedback
import '''package:provider/provider.dart''';

import '''../provider/calculator_provider.dart''';

class CalculatorButton extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? backgroundColor;
  final int flex;
  final Alignment alignment;
  final bool isSelected;

  const CalculatorButton({
    super.key,
    required this.text,
    this.textColor,
    this.backgroundColor,
    this.flex = 1,
    this.alignment = Alignment.center,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final calculator = context.read<CalculatorProvider>();

    final effectiveBackgroundColor = isSelected
        ? CupertinoColors.white
        : backgroundColor ?? const Color(0xFF333333);
    final effectiveTextColor = isSelected
        ? CupertinoColors.systemOrange
        : textColor ?? CupertinoColors.white;

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: CupertinoButton(
          color: effectiveBackgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 20),
          onPressed: () {
            // Trigger haptic feedback on press
            HapticFeedback.lightImpact();
            // Then call the calculator logic
            calculator.onButtonPressed(text);
          },
          child: Align(
            alignment: alignment,
            child: Padding(
              padding: alignment == Alignment.centerLeft ? const EdgeInsets.only(left: 20) : EdgeInsets.zero,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 32,
                  color: effectiveTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
