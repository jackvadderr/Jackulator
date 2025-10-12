import 'package:flutter/widgets.dart';

import '../../theme/app_text_styles.dart';
import '../base/text_label.dart';

class TitleText extends StatelessWidget {
  final String text;
  final TextAlign textAlign;

  const TitleText(this.text, {super.key, this.textAlign = TextAlign.start});

  @override
  Widget build(BuildContext context) {
    return TextLabel(text, style: AppTextStyles.heading, textAlign: textAlign);
  }
}
