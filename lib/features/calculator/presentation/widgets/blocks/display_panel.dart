import 'package:flutter/cupertino.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../components/display_text.dart';

class DisplayPanel extends StatelessWidget {
  final String angleUnitLabel; // Part 1 (info)
  final String expression; // Part 2 (live typing)
  final String result; // Part 3 (computed result)
  final String? bottomInfo; // Part 4 (info)

  const DisplayPanel({
    super.key,
    required this.angleUnitLabel,
    required this.expression,
    required this.result,
    this.bottomInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Part 1: Angle unit (small)
          SizedBox(
            height: 20,
            child: Align(
              alignment: Alignment.centerLeft,
              child: DisplayText(
                angleUnitLabel,
                style: AppTextStyles.caption,
                textAlign: TextAlign.left,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Part 2: Expression (large)
          SizedBox(
            height: 40,
            child: SingleChildScrollView(
              reverse: true,
              scrollDirection: Axis.horizontal,
              child: Text(
                expression,
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 28,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Part 3: Result (larger)
          Container(
            alignment: Alignment.centerRight,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                result,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 80,
                  fontWeight: FontWeight.w200,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),

          // Part 4: Bottom info (small)
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: 20,
            child: Align(
              alignment: Alignment.centerLeft,
              child: DisplayText(
                bottomInfo ?? '',
                style: AppTextStyles.caption,
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
