
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/calculator/presentation/provider/calculator_provider.dart';

void main() {
  group('CalculatorProvider State Machine Tests', () {
    late CalculatorProvider calculator;

    setUp(() {
      calculator = CalculatorProvider();
    });

    test('1. Initial State', () {
      expect(calculator.formattedOutput, '0');
      expect(calculator.expressionString, '');
      expect(calculator.isMemorySet, isFalse);
    });

    test('2. Number Input', () {
      calculator.onButtonPressed('1');
      calculator.onButtonPressed('2');
      calculator.onButtonPressed('.');
      calculator.onButtonPressed('5');
      expect(calculator.formattedOutput, '12.5');
    });

    test('3. Simple Calculation: 12 + 5 =', () {
      calculator.onButtonPressed('1');
      calculator.onButtonPressed('2');
      calculator.onButtonPressed('+');
      expect(calculator.expressionString, '12 +');
      calculator.onButtonPressed('5');
      expect(calculator.formattedOutput, '5');
      calculator.onButtonPressed('=');
      expect(calculator.formattedOutput, '17');
      expect(calculator.expressionString, '');
    });

    test('4. Chained Calculation: 10 + 5 - 3 =', () {
      calculator.onButtonPressed('1');
      calculator.onButtonPressed('0'); // 10
      calculator.onButtonPressed('+');     // op: +, waiting for second operand
      calculator.onButtonPressed('5');      // 5
      calculator.onButtonPressed('-');     // Should calculate 10+5=15, then set op to -
      expect(calculator.formattedOutput, '15');
      expect(calculator.expressionString, '15 -');
      calculator.onButtonPressed('3');
      calculator.onButtonPressed('=');
      expect(calculator.formattedOutput, '12');
      expect(calculator.expressionString, '');
    });

    test('5. Clear Entry (CE) Logic', () {
      calculator.onButtonPressed('1');
      calculator.onButtonPressed('2'); // 12
      calculator.onButtonPressed('+');     // op: +
      calculator.onButtonPressed('3');
      calculator.onButtonPressed('4'); // 34
      
      expect(calculator.expressionString, '12 +');
      expect(calculator.formattedOutput, '34');
      
      calculator.onButtonPressed('CE');   // Clears 34
      expect(calculator.formattedOutput, '0');
      expect(calculator.expressionString, '12 +'); // Operation context is preserved

      calculator.onButtonPressed('5'); // New second operand
      calculator.onButtonPressed('=');
      expect(calculator.formattedOutput, '17'); // 12 + 5 = 17
    });

    test('6. Full Clear (C) Logic', () {
      calculator.onButtonPressed('1');
      calculator.onButtonPressed('2');
      calculator.onButtonPressed('+');
      calculator.onButtonPressed('5');
      calculator.onButtonPressed('C');
      expect(calculator.formattedOutput, '0');
      expect(calculator.expressionString, '');
    });

    test('7. Single Operand Functions (√, x², 1/x)', () {
      // Square Root
      calculator.onButtonPressed('9');
      calculator.onButtonPressed('√');
      expect(calculator.formattedOutput, '3');
      // Allows chaining
      calculator.onButtonPressed('+');
      calculator.onButtonPressed('1');
      calculator.onButtonPressed('=');
      expect(calculator.formattedOutput, '4');

      // Square
      calculator.onButtonPressed('C');
      calculator.onButtonPressed('5');
      calculator.onButtonPressed('x²');
      expect(calculator.formattedOutput, '25');

      // Reciprocal
      calculator.onButtonPressed('C');
      calculator.onButtonPressed('4');
      calculator.onButtonPressed('1/x');
      expect(calculator.formattedOutput, '0.25');
    });

    test('8. Error States (Division by Zero, Sqrt of Negative)', () {
      // Division by Zero
      calculator.onButtonPressed('5');
      calculator.onButtonPressed('÷');
      calculator.onButtonPressed('0');
      calculator.onButtonPressed('=');
      expect(calculator.formattedOutput, 'Error');

      // Pressing number after error should clear
      calculator.onButtonPressed('C'); // Clear error

      // Sqrt of Negative
      calculator.onButtonPressed('9');
      calculator.onButtonPressed('±');
      calculator.onButtonPressed('√');
      expect(calculator.formattedOutput, 'Error');
    });

    test('9. Memory Functions (MS, MR, MC, M+, M-)', () {
      // MS and MR
      calculator.onButtonPressed('2');
      calculator.onButtonPressed('5');
      calculator.onButtonPressed('MS'); // Memory = 25
      expect(calculator.isMemorySet, isTrue);
      calculator.onButtonPressed('C');
      calculator.onButtonPressed('MR');
      expect(calculator.formattedOutput, '25');
      
      // M+
      calculator.onButtonPressed('1');
      calculator.onButtonPressed('0'); // Input is 10
      calculator.onButtonPressed('M+'); // Memory = 25 + 10 = 35
      calculator.onButtonPressed('MR');
      expect(calculator.formattedOutput, '35');

      // M-
      calculator.onButtonPressed('5'); // Input is 5
      calculator.onButtonPressed('M-'); // Memory = 35 - 5 = 30
      calculator.onButtonPressed('MR');
      expect(calculator.formattedOutput, '30');

      // MC
      calculator.onButtonPressed('MC');
      expect(calculator.isMemorySet, isFalse);
      calculator.onButtonPressed('MR');
      expect(calculator.formattedOutput, '0'); // Memory is now 0
    });
  });
}
