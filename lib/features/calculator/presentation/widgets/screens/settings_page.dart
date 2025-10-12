import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../provider/calculator_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CalculatorProvider>();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Configurações', style: AppTextStyles.title),
        const SizedBox(height: AppSpacing.lg),

        // Angle unit
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Unidade angular', style: AppTextStyles.body),
            CupertinoSlidingSegmentedControl<AngleUnit>(
              groupValue: provider.angleUnit,
              children: const {
                AngleUnit.degrees: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('DEG'),
                ),
                AngleUnit.radians: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('RAD'),
                ),
              },
              onValueChanged: (v) {
                if (v != null) provider.setAngleUnit(v);
              },
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        // Live preview toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Preview ao digitar', style: AppTextStyles.body),
            CupertinoSwitch(
              value: provider.livePreviewEnabled,
              onChanged: (enabled) => provider.enableLivePreview(enabled),
              activeTrackColor: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}
