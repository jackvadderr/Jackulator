import 'package:flutter/cupertino.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../components/title_text.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const AppHeader({super.key, this.title = 'Jackulator', this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          Expanded(child: TitleText(title)),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}
