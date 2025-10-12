import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../provider/calculator_provider.dart';
import '../../theme/app_spacing.dart';
import '../blocks/display_panel.dart';
import '../components/keycap.dart';

class AdvancedPage extends StatelessWidget {
  const AdvancedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();

    final advOps = <String>['&', '|', '<<', '>>', '~', '(', ')', '&&', '||'];

    return Column(
      children: [
        // Shared display
        Expanded(
          flex: 2,
          child: DisplayPanel(
            angleUnitLabel: provider.angleUnitLabel,
            expression: provider.liveDisplayExpression,
            result: provider.hasResultForDisplay
                ? provider.formattedOutput
                : '',
            bottomInfo: 'Modo Avançado (bitwise/lógico)',
            onToggleAngleUnit: provider.toggleAngleUnit,
          ),
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: GridView.count(
              crossAxisCount: 4,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              children: advOps.map((op) {
                return Keycap(
                  label: op,
                  variant: KeycapVariant.function,
                  onPressed: () => provider.onButtonPressed(op),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
