import 'package:flutter/widgets.dart';

import '../components/keycap.dart';

class FunctionsKeypad extends StatelessWidget {
  final String clearButtonLabel;
  final void Function(String label) onPressed;

  const FunctionsKeypad({
    super.key,
    required this.clearButtonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final items = [clearButtonLabel, '±', '%'];
    return Row(
      children: items.map((label) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Keycap(
              label: label,
              variant: KeycapVariant.function,
              onPressed: () => onPressed(label),
            ),
          ),
        );
      }).toList(),
    );
  }
}
