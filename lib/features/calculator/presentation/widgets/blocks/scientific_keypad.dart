import 'package:flutter/widgets.dart';

import '../components/keycap.dart';

class ScientificKeypad extends StatelessWidget {
  final void Function(String label) onPressed;

  const ScientificKeypad({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    const row1 = ['sin', 'cos', 'tan', '√', 'x²'];
    const row2 = ['ln', 'log', '(', ')'];

    return Column(
      children: [
        Row(
          children: row1.map((label) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Keycap(
                  label: label,
                  variant: KeycapVariant.scientific,
                  onPressed: () => onPressed(label),
                ),
              ),
            );
          }).toList(),
        ),
        Row(
          children: [
            ...row2.map(
              (label) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Keycap(
                    label: label,
                    variant: KeycapVariant.scientific,
                    onPressed: () => onPressed(label),
                  ),
                ),
              ),
            ),
            const Expanded(child: SizedBox.shrink()),
          ],
        ),
      ],
    );
  }
}
