import 'package:flutter/cupertino.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const CupertinoThemeData cupertino = CupertinoThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        fontFamily: 'SF-Pro-Display',
        color: AppColors.textPrimary,
      ),
    ),
  );
}
