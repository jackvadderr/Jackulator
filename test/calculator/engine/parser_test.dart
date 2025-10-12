import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/calculator/domain/calculator_engine.dart';

void main() {
  group('Parser Tests', () {
    late CalculatorEngine engine;

    setUp(() {
      engine = CalculatorEngine();
    });

    group('Precedence Checks', () {
      test('2+3*4 should equal 14 (multiplication before addition)', () {
        final result = engine.evaluate('2+3*4');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(14));
      });

      test('2+3*4-5 should equal 9', () {
        final result = engine.evaluate('2+3*4-5');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(9));
      });

      test('10-2*3 should equal 4', () {
        final result = engine.evaluate('10-2*3');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(4));
      });

      test('-2^2 should equal -4 (unary minus after power)', () {
        final result = engine.evaluate('-2^2');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(-4));
      });

      test('(-2)^2 should equal 4', () {
        final result = engine.evaluate('(-2)^2');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(4));
      });

      test('2*3^2 should equal 18 (power before multiplication)', () {
        final result = engine.evaluate('2*3^2');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(18));
      });

      test('2^3*4 should equal 32', () {
        final result = engine.evaluate('2^3*4');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(32));
      });
    });

    group('Associativity', () {
      test('2^3^2 should equal 512 (right associative)', () {
        final result = engine.evaluate('2^3^2');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(512));
      });

      test('2-3-4 should equal -5 (left associative)', () {
        final result = engine.evaluate('2-3-4');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(-5));
      });

      test('100/10/2 should equal 5 (left associative)', () {
        final result = engine.evaluate('100/10/2');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(5));
      });
    });

    group('Function Parsing', () {
      test('sin(0) should return 0', () {
        final result = engine.evaluate('sin(0)');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, closeTo(0, 0.0001));
      });

      test('cos(0) should return 1', () {
        final result = engine.evaluate('cos(0)');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, closeTo(1, 0.0001));
      });

      test('sqrt(16) should return 4', () {
        final result = engine.evaluate('sqrt(16)');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(4));
      });

      test('abs(-42) should return 42', () {
        final result = engine.evaluate('abs(-42)');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(42));
      });

      test('log(100) should return 2', () {
        final result = engine.evaluate('log(100)');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, closeTo(2, 0.0001));
      });

      test('max(5, 10, 3) should return 10', () {
        final result = engine.evaluate('max(5, 10, 3)');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(10));
      });

      test('min(5, 10, 3) should return 3', () {
        final result = engine.evaluate('min(5, 10, 3)');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(3));
      });
    });

    group('Implicit Multiplication', () {
      test('2pi should equal 2*pi', () {
        final result1 = engine.evaluate('2pi');
        final result2 = engine.evaluate('2*pi');
        expect(result1.success, isTrue);
        expect(result2.success, isTrue);
        expect(
          (result1.value as NumberValue).rawValue,
          closeTo((result2.value as NumberValue).rawValue, 0.0001),
        );
      });

      test('3e should equal 3*e', () {
        final result1 = engine.evaluate('3e');
        final result2 = engine.evaluate('3*e');
        expect(result1.success, isTrue);
        expect(result2.success, isTrue);
        expect(
          (result1.value as NumberValue).rawValue,
          closeTo((result2.value as NumberValue).rawValue, 0.0001),
        );
      });

      test('2(3+4) should equal 14', () {
        final result = engine.evaluate('2(3+4)');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(14));
      });

      test('(2+3)(4+5) should equal 45', () {
        final result = engine.evaluate('(2+3)(4+5)');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(45));
      });
    });

    group('Postfix Operators', () {
      test('5! should equal 120', () {
        final result = engine.evaluate('5!');
        expect(result.success, isTrue);
        expect((result.value as IntegerValue).rawValue, equals(120));
      });

      test('0! should equal 1', () {
        final result = engine.evaluate('0!');
        expect(result.success, isTrue);
        expect((result.value as IntegerValue).rawValue, equals(1));
      });

      test('1! should equal 1', () {
        final result = engine.evaluate('1!');
        expect(result.success, isTrue);
        expect((result.value as IntegerValue).rawValue, equals(1));
      });

      test('50% should equal 0.5', () {
        final result = engine.evaluate('50%');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(0.5));
      });

      test('100% should equal 1', () {
        final result = engine.evaluate('100%');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(1));
      });

      test('25% should equal 0.25', () {
        final result = engine.evaluate('25%');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(0.25));
      });
    });

    group('Parentheses', () {
      test('(2+3)*4 should equal 20', () {
        final result = engine.evaluate('(2+3)*4');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(20));
      });

      test('2*(3+4) should equal 14', () {
        final result = engine.evaluate('2*(3+4)');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(14));
      });

      test('((2+3)*4)-5 should equal 15', () {
        final result = engine.evaluate('((2+3)*4)-5');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(15));
      });

      test('Nested parentheses (((1+2)*3)+4)*5 should equal 55', () {
        final result = engine.evaluate('(((1+2)*3)+4)*5');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(55));
      });
    });

    group('Parse Errors', () {
      test('Unclosed parenthesis should return error', () {
        final result = engine.evaluate('2*(3+4');
        expect(result.success, isFalse);
        expect(result.error, isNotNull);
      });

      test('Empty expression should return error', () {
        final result = engine.evaluate('');
        expect(result.success, isFalse);
      });

      test('Invalid operator sequence should return error', () {
        final result = engine.evaluate('2++3');
        expect(result.success, isFalse);
      });

      test('Trailing operator should return error', () {
        final result = engine.evaluate('2+');
        expect(result.success, isFalse);
      });

      test('Leading binary operator should return error', () {
        final result = engine.evaluate('*2');
        expect(result.success, isFalse);
      });
    });

    group('Complex Expressions', () {
      test('sqrt(2^2 + 3^2) should equal 5 (Pythagorean)', () {
        final result = engine.evaluate('sqrt(2^2 + 3^2)');
        expect(result.success, isTrue);
        expect(
          (result.value as NumberValue).rawValue,
          closeTo(3.605551275, 0.0001),
        );
      });

      test('2 - 3^2 should equal -7', () {
        final result = engine.evaluate('2 - 3^2');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(-7));
      });

      test('(2 + 3) * (4 - 1) should equal 15', () {
        final result = engine.evaluate('(2 + 3) * (4 - 1)');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(15));
      });
    });
  });
}
