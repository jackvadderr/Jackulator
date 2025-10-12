import 'package:flutter/widgets.dart';

import '../components/keycap.dart';

class MemoryKeypad extends StatelessWidget {
  final bool isMemorySet;
  final void Function(String label) onPressed;

  const MemoryKeypad({
    super.key,
    required this.isMemorySet,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    const items = ['MC', 'MR', 'M+', 'M-', 'MS'];
    return Row(
      children: items.map((label) {
        final enabled = !((label == 'MC' || label == 'MR') && !isMemorySet);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Keycap(
              label: label,
              variant: KeycapVariant.memory,
              enabled: enabled,
              onPressed: enabled ? () => onPressed(label) : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
