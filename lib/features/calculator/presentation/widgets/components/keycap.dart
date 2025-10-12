import 'package:flutter/widgets.dart';

import '../../theme/app_colors.dart';
import '../base/app_button.dart';

enum KeycapVariant { numeric, operation, function, memory, scientific }

class Keycap extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onPressed;
  final KeycapVariant variant;

  const Keycap({
    super.key,
    required this.label,
    required this.variant,
    this.enabled = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForVariant(variant);
    return AppButton(
      label: label,
      enabled: enabled,
      onPressed: enabled ? onPressed : null,
      backgroundColor: colors.$1,
      textColor: colors.$2,
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderRadius: const BorderRadius.all(Radius.circular(12)),
    );
  }

  (Color, Color) _colorsForVariant(KeycapVariant v) {
    switch (v) {
      case KeycapVariant.operation:
        return (AppColors.primary, AppColors.textOnPrimary);
      case KeycapVariant.function:
        return (const Color(0xFFa5a5a5), const Color(0xFF000000));
      case KeycapVariant.memory:
        return (const Color(0xFF505050), AppColors.textPrimary);
      case KeycapVariant.numeric:
      case KeycapVariant.scientific:
        return (const Color(0xFF333333), AppColors.textPrimary);
    }
  }
}
