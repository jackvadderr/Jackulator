import 'package:flutter/cupertino.dart';

class AppFooter extends StatelessWidget {
  final Widget? child;

  const AppFooter({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return child ?? const SizedBox.shrink();
  }
}
