import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/calculator/domain/calculator_engine.dart';

void main() {
  group('Evaluator Tests', () {
    late CalculatorEngine engine;

    setUp(() {
      engine = CalculatorEngine();
    });

    group('Domain Errors', () {
      test('sqrt(-1) should return error in real mode', () {
        final result = engine.evaluate('sqrt(-1)');
        expect(result.success, isFalse);
        expect(result.error, isNotNull);
        // Em modo científico padrão, deve retornar NaN ou erro
      });

      test('log(-10) should return error or NaN', () {
        final result = engine.evaluate('log(-10)');
        expect(result.success, isTrue); // Dart retorna NaN
        expect((result.value as NumberValue).rawValue.isNaN, isTrue);
      });

      test('ln(0) should return -infinity', () {
        final result = engine.evaluate('ln(0)');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue.isInfinite, isTrue);
        expect((result.value as NumberValue).rawValue.isNegative, isTrue);
      });

      test('Factorial of negative number should return error', () {
        final result = engine.evaluate('(-5)!');
        expect(result.success, isFalse);
        expect(result.error?.code, equals('DOMAIN_ERROR'));
      });

      test('Factorial of non-integer should return error', () {
        final result = engine.evaluate('3.5!');
        expect(result.success, isFalse);
        expect(result.error?.code, equals('DOMAIN_ERROR'));
      });

      test('Factorial of large number should return overflow error', () {
        final result = engine.evaluate('25!');
        expect(result.success, isFalse);
        expect(result.error?.code, equals('OVERFLOW'));
      });
    });

    group('Variable Assignment and Recall', () {
      test('Assign and recall variable', () {
        final assignResult = engine.evaluate('x = 42');
        expect(assignResult.success, isTrue);
        expect((assignResult.value as NumberValue).rawValue, equals(42));

        final recallResult = engine.evaluate('x');
        expect(recallResult.success, isTrue);
        expect((recallResult.value as NumberValue).rawValue, equals(42));
      });

      test('Use variable in expression', () {
        engine.evaluate('a = 10');
        engine.evaluate('b = 20');

        final result = engine.evaluate('a + b');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(30));
      });

      test('Reassign variable', () {
        engine.evaluate('x = 100');
        final result1 = engine.evaluate('x');
        expect((result1.value as NumberValue).rawValue, equals(100));

        engine.evaluate('x = 200');
        final result2 = engine.evaluate('x');
        expect((result2.value as NumberValue).rawValue, equals(200));
      });

      test('Undefined variable should return error', () {
        final result = engine.evaluate('undefined_var');
        expect(result.success, isFalse);
        expect(result.error?.code, equals('UNDEFINED_VARIABLE'));
      });

      test('Variable names are case-sensitive', () {
        engine.evaluate('myVar = 100');

        final result1 = engine.evaluate('myVar');
        expect(result1.success, isTrue);
        expect((result1.value as NumberValue).rawValue, equals(100));

        final result2 = engine.evaluate('myvar');
        expect(result2.success, isFalse); // Diferente de myVar
      });

      test('Variables persist across evaluations', () {
        engine.evaluate('total = 0');
        engine.evaluate('total = total + 10');
        engine.evaluate('total = total + 20');

        final result = engine.evaluate('total');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(30));
      });
    });

    group('Memory Operations', () {
      test('ANS stores last result', () {
        engine.evaluate('2 + 3');
        final result = engine.evaluate('ANS * 2');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(10));
      });

      test('ANS updates with each evaluation', () {
        engine.evaluate('10');
        engine.evaluate('20');
        engine.evaluate('30');

        final result = engine.evaluate('ANS');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(30));
      });

      test('Set and recall memory register', () {
        engine.setMemory('M0', NumberValue(999));

        final result = engine.evaluate('M0');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(999));
      });

      test('Use memory in calculations', () {
        engine.setMemory('M1', NumberValue(50));

        final result = engine.evaluate('M1 + 50');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(100));
      });

      test('Add to memory', () {
        engine.setMemory('M2', NumberValue(100));
        engine.addToMemory('M2', NumberValue(50));

        final result = engine.evaluate('M2');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(150));
      });

      test('Clear memory register', () {
        engine.setMemory('M3', NumberValue(123));
        engine.clearMemory('M3');

        final result = engine.evaluate('M3');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(0));
      });

      test('Clear all memory', () {
        engine.setMemory('M0', NumberValue(10));
        engine.setMemory('M1', NumberValue(20));
        engine.setMemory('M2', NumberValue(30));

        engine.clearAllMemory();

        final result0 = engine.evaluate('M0');
        final result1 = engine.evaluate('M1');
        final result2 = engine.evaluate('M2');

        expect((result0.value as NumberValue).rawValue, equals(0));
        expect((result1.value as NumberValue).rawValue, equals(0));
        expect((result2.value as NumberValue).rawValue, equals(0));
      });
    });

    group('Edge Cases', () {
      test('Division by zero should return error', () {
        final result = engine.evaluate('10 / 0');
        expect(result.success, isFalse);
        expect(result.error?.code, equals('DIVISION_BY_ZERO'));
      });

      test('Modulo by zero should return error', () {
        final result = engine.evaluate('10 % 0');
        expect(result.success, isFalse);
        expect(result.error?.code, equals('DIVISION_BY_ZERO'));
      });

      test('Very large exponents', () {
        final result = engine.evaluate('2^1000');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue.isInfinite, isTrue);
      });

      test('Very small numbers', () {
        final result = engine.evaluate('1 / 10000000000');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, closeTo(1e-10, 1e-15));
      });

      test('Floating point precision', () {
        final result = engine.evaluate('0.1 + 0.2');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, closeTo(0.3, 0.0000001));
      });

      test('Zero to zero power', () {
        final result = engine.evaluate('0^0');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(1));
      });

      test('Negative base with fractional exponent', () {
        final result = engine.evaluate('(-4)^0.5');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue.isNaN, isTrue);
      });

      test('Expression with only whitespace', () {
        final result = engine.evaluate('   ');
        expect(result.success, isFalse);
      });

      test('Double negative', () {
        final result = engine.evaluate('--5');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(5));
      });

      test('Triple negative', () {
        final result = engine.evaluate('---5');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(-5));
      });
    });

    group('Constants', () {
      test('pi constant', () {
        final result = engine.evaluate('pi');
        expect(result.success, isTrue);
        expect(
          (result.value as NumberValue).rawValue,
          closeTo(3.14159265359, 0.00001),
        );
      });

      test('e constant', () {
        final result = engine.evaluate('e');
        expect(result.success, isTrue);
        expect(
          (result.value as NumberValue).rawValue,
          closeTo(2.71828182846, 0.00001),
        );
      });

      test('Constants in expressions', () {
        final result = engine.evaluate('2 * pi');
        expect(result.success, isTrue);
        expect(
          (result.value as NumberValue).rawValue,
          closeTo(6.28318530718, 0.00001),
        );
      });

      test('Constants are case-sensitive', () {
        final result1 = engine.evaluate('pi');
        expect(result1.success, isTrue);

        final result2 = engine.evaluate('PI');
        expect(result2.success, isFalse); // PI não está definido
      });
    });

    group('Bitwise Operations', () {
      test('Bitwise AND', () {
        final result = engine.evaluate('5 & 3');
        expect(result.success, isTrue);
        expect((result.value as IntegerValue).rawValue, equals(1));
      });

      test('Bitwise OR', () {
        final result = engine.evaluate('5 | 3');
        expect(result.success, isTrue);
        expect((result.value as IntegerValue).rawValue, equals(7));
      });

      test('Left shift', () {
        final result = engine.evaluate('8 << 2');
        expect(result.success, isTrue);
        expect((result.value as IntegerValue).rawValue, equals(32));
      });

      test('Right shift', () {
        final result = engine.evaluate('32 >> 2');
        expect(result.success, isTrue);
        expect((result.value as IntegerValue).rawValue, equals(8));
      });

      test('Bitwise NOT', () {
        final result = engine.evaluate('~5');
        expect(result.success, isTrue);
        expect((result.value as IntegerValue).rawValue, equals(-6));
      });
    });

    group('Comparison Operations', () {
      test('Less than', () {
        final result = engine.evaluate('3 < 5');
        expect(result.success, isTrue);
        expect((result.value as BooleanValue).rawValue, isTrue);
      });

      test('Greater than', () {
        final result = engine.evaluate('5 > 3');
        expect(result.success, isTrue);
        expect((result.value as BooleanValue).rawValue, isTrue);
      });

      test('Equal', () {
        final result = engine.evaluate('5 == 5');
        expect(result.success, isTrue);
        expect((result.value as BooleanValue).rawValue, isTrue);
      });

      test('Not equal', () {
        final result = engine.evaluate('5 != 3');
        expect(result.success, isTrue);
        expect((result.value as BooleanValue).rawValue, isTrue);
      });

      test('Less than or equal', () {
        final result = engine.evaluate('5 <= 5');
        expect(result.success, isTrue);
        expect((result.value as BooleanValue).rawValue, isTrue);
      });

      test('Greater than or equal', () {
        final result = engine.evaluate('5 >= 3');
        expect(result.success, isTrue);
        expect((result.value as BooleanValue).rawValue, isTrue);
      });
    });
  });
}
