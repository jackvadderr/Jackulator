import 'package:flutter/cupertino.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

class AppFooter extends StatelessWidget {
  final Widget? child;

  const AppFooter({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.surface,
      child: child ?? const SizedBox.shrink(),
    );
  }
}
