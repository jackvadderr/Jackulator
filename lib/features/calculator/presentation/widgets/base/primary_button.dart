import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';
import 'app_button.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? width;
  final IconData? icon;
  final bool enabled;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.width,
    this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AppButton(
        label: label,
        icon: icon,
        onPressed: onPressed,
        backgroundColor: enabled
            ? AppColors.primary
            : AppColors.disabledBackground,
        textColor: AppColors.textOnPrimary,
        enabled: enabled,
      ),
    );
  }
}
