import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../provider/calculator_provider.dart';
import '../blocks/basic_keypad.dart';
import '../blocks/display_panel.dart';
import '../blocks/expandable_nav_footer.dart';
import '../blocks/scientific_keypad.dart';
import '../layouts/main_layout.dart';
import './advanced_page.dart';
import './history_page.dart';
import './settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();

    final actions = <Widget>[
      if (provider.navTab == NavTab.history)
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => provider.clearEngineHistory(),
          child: const Text('Clear'),
        ),
    ];

    Widget body;
    switch (provider.navTab) {
      case NavTab.history:
        body = const HistoryPage();
        break;
      case NavTab.settings:
        body = const SettingsPage();
        break;
      case NavTab.advanced:
        body = const AdvancedPage();
        break;
      default:
        body = _CalculatorView(provider: provider);
    }

    return MainLayout(
      title: 'Jackulator',
      actions: actions,
      footerChild: ExpandableNavFooter(
        selectedIndex: provider.navTab.index,
        onTabSelected: (i) => provider.setNavTab(NavTab.values[i]),
      ),
      child: body,
    );
  }
}

class _CalculatorView extends StatelessWidget {
  final CalculatorProvider provider;
  const _CalculatorView({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display area (4 parts)
        Expanded(
          flex: provider.mode == CalculatorMode.basic ? 3 : 2,
          child: DisplayPanel(
            angleUnitLabel: provider.angleUnitLabel,
            expression: provider.liveDisplayExpression,
            result: provider.hasResultForDisplay
                ? provider.formattedOutput
                : '',
            bottomInfo: '',
            onToggleAngleUnit: provider.toggleAngleUnit,
          ),
        ),

        // Keypads composition (Blocks)
        Expanded(
          flex: provider.mode == CalculatorMode.basic ? 5 : 7,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 48, left: 8, right: 8),
            child: Column(
              children: [
                if (provider.mode == CalculatorMode.scientific)
                  ScientificKeypad(onPressed: provider.onButtonPressed),

                // Basic 5x5 keypad grid
                Expanded(
                  child: BasicKeypad(
                    clearButtonLabel: provider.clearButtonLabel,
                    isMemorySet: provider.isMemorySet,
                    onPressed: provider.onButtonPressed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
