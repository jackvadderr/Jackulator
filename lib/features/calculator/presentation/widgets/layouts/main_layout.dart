import 'package:flutter/cupertino.dart';
import '../blocks/app_footer.dart';
import '../blocks/app_header.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final Widget? footerChild;

  const MainLayout({
    super.key,
    required this.child,
    this.title = 'Jackulator',
    this.footerChild,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: null,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppHeader(title: title),
            Expanded(child: child),
            AppFooter(child: footerChild),
          ],
        ),
      ),
    );
  }
}
