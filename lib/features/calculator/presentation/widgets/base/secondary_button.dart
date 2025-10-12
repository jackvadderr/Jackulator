import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';
import 'app_button.dart';

class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final double? width;
  final IconData? icon;
  final bool enabled;

  const SecondaryButton({
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
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? AppColors.border : AppColors.disabledBorder,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        ),
        child: AppButton(
          label: label,
          icon: icon,
          onPressed: onPressed,
          backgroundColor: null,
          textColor: enabled ? AppColors.textSecondary : AppColors.textDisabled,
          enabled: enabled,
        ),
      ),
    );
  }
}
