import 'package:flutter/widgets.dart';

import '../components/keycap.dart';

class NumericKeypad extends StatelessWidget {
  final void Function(String label) onPressed;

  const NumericKeypad({super.key, required this.onPressed});

  Widget _row(List<String> labels) {
    return Expanded(
      child: Row(
        children: labels.map((label) {
          int flex = label == '0' ? 2 : 1;
          return Expanded(
            flex: flex,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Keycap(
                label: label,
                variant: KeycapVariant.numeric,
                onPressed: () => onPressed(label),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _row(const ['7', '8', '9']),
        _row(const ['4', '5', '6']),
        _row(const ['1', '2', '3']),
        // last row: 0 double width + '.'
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Keycap(
                    label: '0',
                    variant: KeycapVariant.numeric,
                    onPressed: () => onPressed('0'),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Keycap(
                    label: '.',
                    variant: KeycapVariant.numeric,
                    onPressed: () => onPressed('.'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
