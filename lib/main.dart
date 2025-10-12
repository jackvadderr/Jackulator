import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'features/calculator/presentation/provider/calculator_provider.dart';
import 'features/calculator/presentation/theme/app_theme.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CalculatorProvider(),
      child: CupertinoApp(
        title: 'Jackulator',
        theme: AppTheme.cupertino,
        home: const CalculatorHome(),
      ),
    );
  }
}
