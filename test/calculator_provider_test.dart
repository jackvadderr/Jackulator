
import '''package:flutter_test/flutter_test.dart''';
// Corrected import path using the actual package name 'myapp'
import '''package:myapp/features/calculator/presentation/provider/calculator_provider.dart''';

void main() {
  // We use `group` to organize related tests together.
  group('CalculatorProvider Unit Tests', () {
    // Declare the provider instance that will be used in all tests.
    late CalculatorProvider calculatorProvider;

    // `setUp` is a special function from flutter_test that runs before each test.
    // This ensures we start with a fresh, predictable instance for every test case.
    setUp(() {
      calculatorProvider = CalculatorProvider();
    });

    test('Initial state is correct', () {
      // Assert: Check if the initial output is '0'.
      expect(calculatorProvider.output, '0');
      expect(calculatorProvider.formattedOutput, '0');
    });

    test('Number entry works correctly', () {
      // Act: Simulate pressing buttons.
      calculatorProvider.onButtonPressed('1');
      calculatorProvider.onButtonPressed('2');
      calculatorProvider.onButtonPressed('3');

      // Assert: Check if the output reflects the number entry.
      expect(calculatorProvider.output, '123');
    });

    test('Simple addition should be calculated correctly', () {
      // Act
      calculatorProvider.onButtonPressed('2');
      calculatorProvider.onButtonPressed('+');
      calculatorProvider.onButtonPressed('3');
      calculatorProvider.onButtonPressed('=');

      // Assert
      expect(calculatorProvider.output, '5');
    });

    test('Chained calculations should be handled correctly', () {
      // Act: 10 + 5 - 3 = 12
      calculatorProvider.onButtonPressed('1');
      calculatorProvider.onButtonPressed('0');
      calculatorProvider.onButtonPressed('+');
      calculatorProvider.onButtonPressed('5');
      calculatorProvider.onButtonPressed('='); // Intermediate result is 15
      calculatorProvider.onButtonPressed('-');
      calculatorProvider.onButtonPressed('3');
      calculatorProvider.onButtonPressed('=');

      // Assert
      expect(calculatorProvider.output, '12');
    });

    test('Clear button should reset the state', () {
      // Act
      calculatorProvider.onButtonPressed('5');
      calculatorProvider.onButtonPressed('×');
      calculatorProvider.onButtonPressed('8');
      calculatorProvider.onButtonPressed('C'); // Clear

      // Assert: Check that everything is back to its initial state.
      expect(calculatorProvider.output, '0');
      expect(calculatorProvider.activeOperator, '');
    });

    test('Division by zero should result in an error message', () {
      // Act
      calculatorProvider.onButtonPressed('9');
      calculatorProvider.onButtonPressed('÷');
      calculatorProvider.onButtonPressed('0');
      calculatorProvider.onButtonPressed('=');

      // Assert
      expect(calculatorProvider.output, 'Error');
    });

    test('Backspace should remove the last digit', () {
      // Act
      calculatorProvider.onButtonPressed('1');
      calculatorProvider.onButtonPressed('2');
      calculatorProvider.onButtonPressed('3');
      calculatorProvider.backspace();

      // Assert
      expect(calculatorProvider.output, '12');
    });

    test('Backspace on a single digit number should result in 0', () {
      // Act
      calculatorProvider.onButtonPressed('5');
      calculatorProvider.backspace();

      // Assert
      expect(calculatorProvider.output, '0');
    });

    test('Number formatting should work for large numbers', () {
        // Act
        calculatorProvider.onButtonPressed('1');
        calculatorProvider.onButtonPressed('0');
        calculatorProvider.onButtonPressed('0');
        calculatorProvider.onButtonPressed('0');
        calculatorProvider.onButtonPressed('0');
        calculatorProvider.onButtonPressed('0');
        calculatorProvider.onButtonPressed('0');

        // Assert
        expect(calculatorProvider.formattedOutput, '1,000,000');
    });
  });
}
