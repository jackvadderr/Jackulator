
import '''package:flutter/cupertino.dart''';
import '''package:provider/provider.dart''';

import '''./features/calculator/presentation/provider/calculator_provider.dart''';
import '''./features/calculator/presentation/screens/calculator_screen.dart''';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ChangeNotifierProvider is the widget that provides an instance of a
    // ChangeNotifier to its descendants. It is the "injection" part.
    return ChangeNotifierProvider(
      create: (context) => CalculatorProvider(),
      child: const CupertinoApp(
        title: 'Jackulator',
        theme: CupertinoThemeData(
          primaryColor: CupertinoColors.systemOrange,
          scaffoldBackgroundColor: CupertinoColors.black,
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(fontFamily: 'SF-Pro-Display'),
          ),
        ),
        home: CalculatorScreen(),
      ),
    );
  }
}
