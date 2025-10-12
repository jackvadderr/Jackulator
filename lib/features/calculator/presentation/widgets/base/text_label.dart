import 'package:flutter/cupertino.dart';

import '../../theme/app_text_styles.dart';

class TextLabel extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;

  const TextLabel(this.text, {super.key, this.style, this.textAlign});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign ?? TextAlign.start,
      style: style ?? AppTextStyles.body,
    );
  }
}
