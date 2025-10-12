import 'package:flutter/widgets.dart';

import '../base/primary_button.dart';

class Keypad extends StatelessWidget {
  final List<List<String>> layout;
  final String clearButtonLabel;
  final bool isMemorySet;
  final void Function(String label) onPressed;

  const Keypad({
    super.key,
    required this.layout,
    required this.clearButtonLabel,
    required this.isMemorySet,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: layout.map((row) {
        return Expanded(
          child: Row(
            children: row.map((label) {
              if (label == ' ') return const Spacer();

              final displayLabel = label == 'AC' ? clearButtonLabel : label;
              final enabled =
                  !((label == 'MC' || label == 'MR') && !isMemorySet);
              final flex = (label == '0' || label == '=') ? 2 : 1;

              return Expanded(
                flex: flex,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: PrimaryButton(
                    label: displayLabel,
                    enabled: enabled,
                    onPressed: enabled ? () => onPressed(displayLabel) : null,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
