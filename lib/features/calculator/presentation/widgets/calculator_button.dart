
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../provider/calculator_provider.dart';

class CalculatorButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final Color? textColor;
  final Color? backgroundColor;
  final int flex;
  final Alignment alignment;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback? onTap;

  const CalculatorButton({
    super.key,
    this.text,
    this.textColor,
    this.backgroundColor,
    this.flex = 1,
    this.alignment = Alignment.center,
    this.isSelected = false,
    this.isEnabled = true,
  }) : icon = null, onTap = null;

  const CalculatorButton.icon({
    super.key,
    required this.icon,
    required this.onTap,
    this.textColor,
    this.backgroundColor,
    this.flex = 1,
    this.alignment = Alignment.center,
    this.isSelected = false,
    this.isEnabled = true,
  }) : text = null;

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
          padding: EdgeInsets.zero, // Remove fixed padding to allow content to fill
          onPressed: isEnabled ? () {
            HapticFeedback.lightImpact();
            if (onTap != null) {
              onTap!();
            } else if (text != null) {
              calculator.onButtonPressed(text!);
            }
          } : null,
          child: Opacity(
            opacity: isEnabled ? 1.0 : 0.5,
            child: Align(
              alignment: alignment,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Add smaller, more flexible padding
                child: FittedBox( // This widget is the key to the solution
                  fit: BoxFit.contain, // Ensures the content scales down to fit
                  child: icon != null
                      ? Icon(icon, color: effectiveTextColor)
                      : Text(
                          text!,
                          style: TextStyle(
                            color: effectiveTextColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
