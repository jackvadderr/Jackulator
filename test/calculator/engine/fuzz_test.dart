import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/calculator/domain/calculator_engine.dart';

void main() {
  group('Fuzz Tests', () {
    late CalculatorEngine engine;
    final random = math.Random(42); // Seed fixo para reproduzibilidade

    setUp(() {
      engine = CalculatorEngine();
    });

    group('Random Expression Generation', () {
      test('Random simple arithmetic expressions should not crash', () {
        for (var i = 0; i < 100; i++) {
          final expr = _generateSimpleArithmetic(random);

          expect(
            () {
              final result = engine.evaluate(expr);
              // Deve retornar sucesso ou erro controlado, nunca crashar
              expect(result.value != null || result.error != null, isTrue);
            },
            returnsNormally,
            reason: 'Expression: $expr',
          );
        }
      });

      test('Random expressions with parentheses should not crash', () {
        for (var i = 0; i < 100; i++) {
          final expr = _generateWithParentheses(random);

          expect(
            () {
              engine.evaluate(expr);
            },
            returnsNormally,
            reason: 'Expression: $expr',
          );
        }
      });

      test('Random expressions with functions should not crash', () {
        for (var i = 0; i < 100; i++) {
          final expr = _generateWithFunctions(random);

          expect(
            () {
              engine.evaluate(expr);
            },
            returnsNormally,
            reason: 'Expression: $expr',
          );
        }
      });

      test('Random complex expressions should not crash', () {
        for (var i = 0; i < 50; i++) {
          final expr = _generateComplexExpression(random);

          expect(
            () {
              final result = engine.evaluate(expr);
              // Verificar que o resultado é válido
              if (result.success) {
                expect(result.value, isNotNull);
              } else {
                expect(result.error, isNotNull);
              }
            },
            returnsNormally,
            reason: 'Expression: $expr',
          );
        }
      });

      test('Random bitwise expressions should not crash', () {
        for (var i = 0; i < 50; i++) {
          final expr = _generateBitwiseExpression(random);

          expect(
            () {
              engine.evaluate(expr);
            },
            returnsNormally,
            reason: 'Expression: $expr',
          );
        }
      });
    });

    group('Edge Case Fuzzing', () {
      test('Very long expressions should not crash', () {
        final expr = _generateLongExpression(random, 50);

        expect(() {
          engine.evaluate(expr);
        }, returnsNormally);
      });

      test('Deeply nested parentheses should not crash', () {
        final expr = _generateDeeplyNested(random, 10);

        expect(() {
          engine.evaluate(expr);
        }, returnsNormally);
      });

      test('Many function calls should not crash', () {
        final expr = _generateManyFunctions(random, 20);

        expect(() {
          engine.evaluate(expr);
        }, returnsNormally);
      });

      test('Random number sizes', () {
        final numbers = [
          '0',
          '0.0',
          '1',
          '-1',
          '999999999999',
          '-999999999999',
          '0.000000001',
          '-0.000000001',
          '1e10',
          '1e-10',
          '1.23456789',
        ];

        for (final num in numbers) {
          final result = engine.evaluate(num);
          expect(result.success, isTrue, reason: 'Number: $num');
        }
      });

      test('Random operator combinations', () {
        final operators = ['+', '-', '*', '/', '^', '%'];

        for (var i = 0; i < 50; i++) {
          final op1 = operators[random.nextInt(operators.length)];
          final op2 = operators[random.nextInt(operators.length)];
          final expr =
              '${random.nextInt(100)} $op1 ${random.nextInt(100)} $op2 ${random.nextInt(100)}';

          expect(
            () {
              engine.evaluate(expr);
            },
            returnsNormally,
            reason: 'Expression: $expr',
          );
        }
      });
    });

    group('Malformed Input Fuzzing', () {
      test('Random invalid characters should return parse error', () {
        final invalidChars = ['@', '#', '\$', '\\', '[', ']', '{', '}'];

        for (final char in invalidChars) {
          final result = engine.evaluate('2 $char 3');
          expect(result.success, isFalse, reason: 'Character: $char');
          expect(result.error, isNotNull);
        }
      });

      test('Unmatched parentheses should return parse error', () {
        final cases = ['(2 + 3', '2 + 3)', '((2 + 3)', '(2 + 3))', '(2 + (3)'];

        for (final expr in cases) {
          final result = engine.evaluate(expr);
          expect(result.success, isFalse, reason: 'Expression: $expr');
        }
      });

      test('Multiple operators should return parse error', () {
        final cases = ['2 ++ 3', '2 -- 3', '2 */ 3', '2 +* 3'];

        for (final expr in cases) {
          final result = engine.evaluate(expr);
          expect(result.success, isFalse, reason: 'Expression: $expr');
        }
      });

      test('Trailing operators should return parse error', () {
        final cases = ['2 +', '2 -', '2 *', '2 /', '2 ^'];

        for (final expr in cases) {
          final result = engine.evaluate(expr);
          expect(result.success, isFalse, reason: 'Expression: $expr');
        }
      });
    });

    group('Stress Tests', () {
      test('Many sequential evaluations should not degrade performance', () {
        final stopwatch = Stopwatch()..start();

        for (var i = 0; i < 1000; i++) {
          engine.evaluate('${i % 100} + ${(i * 2) % 100}');
        }

        stopwatch.stop();

        // Deve completar em tempo razoável (menos de 5 segundos)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });

      test('Many variables should not cause issues', () {
        for (var i = 0; i < 100; i++) {
          engine.evaluate('var$i = $i');
        }

        final vars = engine.listVariables();
        expect(vars.length, greaterThanOrEqualTo(100));

        // Usar algumas variáveis
        final result = engine.evaluate('var0 + var50 + var99');
        expect(result.success, isTrue);
      });

      test('Large history should not cause performance issues', () {
        for (var i = 0; i < 500; i++) {
          engine.evaluate('$i + 1');
        }

        final stopwatch = Stopwatch()..start();
        final history = engine.listHistory(limit: 100);
        stopwatch.stop();

        expect(history.length, equals(100));
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });
  });
}

// Geradores de expressões aleatórias

String _generateSimpleArithmetic(math.Random random) {
  final operators = ['+', '-', '*', '/'];
  final a = random.nextInt(100);
  final b = random.nextInt(100) + 1; // Evitar zero
  final op = operators[random.nextInt(operators.length)];
  return '$a $op $b';
}

String _generateWithParentheses(math.Random random) {
  final operators = ['+', '-', '*', '/'];
  final a = random.nextInt(100);
  final b = random.nextInt(100) + 1;
  final c = random.nextInt(100);
  final op1 = operators[random.nextInt(operators.length)];
  final op2 = operators[random.nextInt(operators.length)];

  final patterns = [
    '($a $op1 $b) $op2 $c',
    '$a $op1 ($b $op2 $c)',
    '(($a $op1 $b) $op2 $c)',
  ];

  return patterns[random.nextInt(patterns.length)];
}

String _generateWithFunctions(math.Random random) {
  final functions = ['sqrt', 'abs', 'sin', 'cos', 'ln', 'log'];
  final func = functions[random.nextInt(functions.length)];
  final value = random.nextInt(100);

  return '$func($value)';
}

String _generateComplexExpression(math.Random random) {
  final operators = ['+', '-', '*', '/'];
  final functions = ['sqrt', 'abs'];

  final parts = <String>[];
  final numParts = random.nextInt(5) + 2;

  for (var i = 0; i < numParts; i++) {
    if (random.nextBool() && functions.isNotEmpty) {
      final func = functions[random.nextInt(functions.length)];
      final value = random.nextInt(100);
      parts.add('$func($value)');
    } else {
      parts.add('${random.nextInt(100)}');
    }
  }

  final result = StringBuffer(parts[0]);
  for (var i = 1; i < parts.length; i++) {
    final op = operators[random.nextInt(operators.length)];
    result.write(' $op ${parts[i]}');
  }

  return result.toString();
}

String _generateBitwiseExpression(math.Random random) {
  final operators = ['&', '|', '^', '<<', '>>'];
  final a = random.nextInt(256);
  final b = random.nextInt(8);
  final op = operators[random.nextInt(operators.length)];
  return '$a $op $b';
}

String _generateLongExpression(math.Random random, int length) {
  final operators = ['+', '-', '*', '/'];
  final parts = <String>[];

  for (var i = 0; i < length; i++) {
    parts.add('${random.nextInt(100)}');
  }

  final result = StringBuffer(parts[0]);
  for (var i = 1; i < parts.length; i++) {
    final op = operators[random.nextInt(operators.length)];
    result.write(' $op ${parts[i]}');
  }

  return result.toString();
}

String _generateDeeplyNested(math.Random random, int depth) {
  if (depth <= 0) {
    return '${random.nextInt(100)}';
  }

  final operators = ['+', '-', '*', '/'];
  final op = operators[random.nextInt(operators.length)];
  final left = _generateDeeplyNested(random, depth - 1);
  final right = random.nextInt(100);

  return '($left $op $right)';
}

String _generateManyFunctions(math.Random random, int count) {
  final functions = ['abs', 'floor', 'ceil', 'round'];
  var expr = '${random.nextInt(100)}';

  for (var i = 0; i < count; i++) {
    final func = functions[random.nextInt(functions.length)];
    expr = '$func($expr)';
  }

  return expr;
}
