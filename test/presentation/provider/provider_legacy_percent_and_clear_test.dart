import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/calculator/presentation/provider/calculator_provider.dart';

void main() {
  group('CalculatorProvider - legacy percent and clear behavior', () {
    late CalculatorProvider provider;

    setUp(() {
      provider = CalculatorProvider();
    });

    test('50 + 10% = yields 50.1 (legacy path)', () {
      provider.onButtonPressed('5');
      provider.onButtonPressed('0');
      provider.onButtonPressed('+');
      provider.onButtonPressed('1');
      provider.onButtonPressed('0');
      provider.onButtonPressed('%');
      provider.onButtonPressed('=');

      expect(provider.formattedOutput, '50.1');
      expect(provider.hasResultForDisplay, isTrue);
    });

    test('C after = clears output and expression for a new calc', () {
      // Do a simple calc first
      provider.onButtonPressed('2');
      provider.onButtonPressed('+');
      provider.onButtonPressed('2');
      provider.onButtonPressed('=');

      expect(provider.formattedOutput, '4');
      expect(provider.hasResultForDisplay, isTrue);

      // Press C and ensure reset for new input
      provider.onButtonPressed('C');
      expect(provider.formattedOutput, '0');
      expect(provider.hasResultForDisplay, isFalse);

      // Start new input
      provider.onButtonPressed('3');
      provider.onButtonPressed('+');
      provider.onButtonPressed('4');
      provider.onButtonPressed('=');

      expect(provider.formattedOutput, '7');
    });
  });
}
