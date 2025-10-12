import 'package:flutter/widgets.dart';

import '../components/keycap.dart';

class BasicKeypad extends StatelessWidget {
  final String clearButtonLabel;
  final bool isMemorySet;
  final void Function(String label) onPressed;

  const BasicKeypad({
    super.key,
    required this.clearButtonLabel,
    required this.isMemorySet,
    required this.onPressed,
  });

  Keycap _buildKeycap(String raw) {
    String label = raw == 'AC' ? clearButtonLabel : raw;
    KeycapVariant variant;
    if (['+', '-', '×', '÷', '='].contains(raw)) {
      variant = KeycapVariant.operation;
    } else if (['AC', '±', '%', 'DEL'].contains(raw)) {
      variant = KeycapVariant.function;
    } else if (['MC', 'MR', 'M+', 'M-', 'MS'].contains(raw)) {
      variant = KeycapVariant.memory;
    } else {
      variant = KeycapVariant.numeric;
    }

    bool enabled = true;
    if (['MC', 'MR'].contains(raw)) {
      enabled = isMemorySet;
    }

    return Keycap(
      label: label,
      variant: variant,
      enabled: enabled,
      onPressed: enabled ? () => onPressed(label) : null,
    );
  }

  Widget _cell(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: _buildKeycap(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const grid = [
      ['AC', '±', '%', 'DEL', 'MC'],
      ['7', '8', '9', '÷', 'MR'],
      ['4', '5', '6', '×', 'M+'],
      ['1', '2', '3', '-', 'M-'],
      ['0', '.', '=', '+', 'MS'],
    ];

    return Column(
      children: grid.map((row) {
        return Expanded(child: Row(children: row.map(_cell).toList()));
      }).toList(),
    );
  }
}
