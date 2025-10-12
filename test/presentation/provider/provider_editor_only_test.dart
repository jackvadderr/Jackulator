import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/calculator/presentation/provider/calculator_provider.dart';

void main() {
  group('CalculatorProvider - editor-only flow', () {
    late CalculatorProvider provider;

    setUp(() {
      provider = CalculatorProvider();
    });

    test('DEL is handled once (no double-processing)', () {
      provider.onButtonPressed('1');
      provider.onButtonPressed('2');
      provider.onButtonPressed('DEL');
      expect(provider.liveDisplayExpression, '1');
    });

    test('x² inserts ^2 and evaluates', () {
      provider.onButtonPressed('2');
      provider.onButtonPressed('x²');
      provider.onButtonPressed('=');
      expect(provider.formattedOutput, '4');
      expect(provider.hasResultForDisplay, isTrue);
    });

    test('C after = clears result and current entry', () {
      provider.onButtonPressed('2');
      provider.onButtonPressed('+');
      provider.onButtonPressed('2');
      provider.onButtonPressed('=');
      expect(provider.formattedOutput, '4');
      expect(provider.hasResultForDisplay, isTrue);

      provider.onButtonPressed('C');
      expect(provider.hasResultForDisplay, isFalse);
      expect(provider.liveDisplayExpression, '');
    });

    test('Scientific notation is preserved in formatted output', () {
      // Build 10^12 to trigger exponential format
      provider.onButtonPressed('1');
      provider.onButtonPressed('0');
      provider.onButtonPressed('^');
      provider.onButtonPressed('1');
      provider.onButtonPressed('2');
      provider.onButtonPressed('=');

      final out = provider.formattedOutput;
      expect(out.contains('e') || out.contains('E'), isTrue);
    });
  });
}
