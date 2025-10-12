import 'package:flutter/widgets.dart';

import '../../theme/app_text_styles.dart';
import '../base/text_label.dart';

class DisplayText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;

  const DisplayText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextLabel(
      text,
      style: style ?? AppTextStyles.body,
      textAlign: textAlign,
    );
  }
}
