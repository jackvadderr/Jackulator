import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final Widget? child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final bool enabled;

  const AppButton({
    super.key,
    this.label,
    this.icon,
    this.child,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.padding = const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    this.borderRadius,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = enabled && onPressed != null;

    final Widget content =
        child ??
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: textColor ?? AppColors.textPrimary, size: 20),
              const SizedBox(width: 8),
            ],
            if (label != null)
              Text(
                label!,
                style: AppTextStyles.body.copyWith(
                  color: textColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        );

    return CupertinoButton(
      padding: padding,
      borderRadius:
          borderRadius ?? const BorderRadius.all(Radius.circular(8.0)),
      color: isEnabled ? backgroundColor : AppColors.disabledBackground,
      onPressed: isEnabled
          ? () {
              HapticFeedback.lightImpact();
              onPressed?.call();
            }
          : null,
      child: content,
    );
  }
}
