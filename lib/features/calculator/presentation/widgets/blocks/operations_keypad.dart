import 'package:flutter/widgets.dart';

import '../components/keycap.dart';

class OperationsKeypad extends StatelessWidget {
  final void Function(String label) onPressed;

  const OperationsKeypad({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    const ops = ['÷', '×', '-', '+', '='];
    return Column(
      children: ops.map((op) {
        final flex = 1;
        return Expanded(
          flex: flex,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Keycap(
              label: op,
              variant: KeycapVariant.operation,
              onPressed: () => onPressed(op),
            ),
          ),
        );
      }).toList(),
    );
  }
}
