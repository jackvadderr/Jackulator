import 'package:flutter/cupertino.dart';

import '../../theme/app_colors.dart';
import '../blocks/app_header.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final Widget? footerChild;

  const MainLayout({
    super.key,
    required this.child,
    this.title = 'Jackulator',
    this.actions,
    this.footerChild,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      child: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                AppHeader(title: title, actions: actions),
                Expanded(child: child),
              ],
            ),
          ),
          if (footerChild != null) footerChild!,
        ],
      ),
    );
  }
}
