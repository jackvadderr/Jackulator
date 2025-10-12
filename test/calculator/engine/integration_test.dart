import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/calculator/domain/calculator_engine.dart';

void main() {
  group('Integration Tests', () {
    late CalculatorEngine engine;

    setUp(() {
      engine = CalculatorEngine();
    });

    group('Parse → Evaluate → Serialize → Deserialize → Evaluate', () {
      test('Simple expression round-trip', () {
        const expression = '2 + 3 * 4';

        // Parse e evaluate
        final result1 = engine.evaluate(expression);
        expect(result1.success, isTrue);
        final value1 = (result1.value as NumberValue).rawValue;

        // Parse novamente
        final parseResult = engine.parse(expression);
        expect(parseResult.success, isTrue);

        // Evaluate AST
        final result2 = engine.evaluateAst(parseResult.ast!);
        expect(result2.success, isTrue);
        final value2 = (result2.value as NumberValue).rawValue;

        // Valores devem ser idênticos
        expect(value1, equals(value2));
      });

      test('Complex expression with functions round-trip', () {
        const expression = 'sqrt(2^2 + 3^2)';

        final result1 = engine.evaluate(expression);
        final parseResult = engine.parse(expression);
        final result2 = engine.evaluateAst(parseResult.ast!);

        expect(result1.success, isTrue);
        expect(result2.success, isTrue);
        expect(
          (result1.value as NumberValue).rawValue,
          closeTo((result2.value as NumberValue).rawValue, 0.0001),
        );
      });

      test('Expression with variables round-trip', () {
        engine.evaluate('x = 10');
        const expression = 'x * 2 + 5';

        final result1 = engine.evaluate(expression);
        final parseResult = engine.parse(expression);
        final result2 = engine.evaluateAst(parseResult.ast!);

        expect(result1.success, isTrue);
        expect(result2.success, isTrue);
        expect(
          (result1.value as NumberValue).rawValue,
          equals((result2.value as NumberValue).rawValue),
        );
      });
    });

    group('History Replay', () {
      test('History stores and replays correctly', () {
        // Avaliar várias expressões
        engine.evaluate('10 + 5');
        engine.evaluate('20 * 3');
        engine.evaluate('100 / 4');

        final history = engine.listHistory();
        expect(history.length, equals(3));

        // Verificar que os resultados foram armazenados
        expect(history[2].expressionRaw, equals('10 + 5'));
        expect(history[2].resultSerialized, equals('15'));
        expect(history[2].success, isTrue);

        expect(history[1].expressionRaw, equals('20 * 3'));
        expect(history[1].resultSerialized, equals('60'));

        expect(history[0].expressionRaw, equals('100 / 4'));
        expect(history[0].resultSerialized, equals('25'));
      });

      test('Re-evaluate history with different context', () {
        // Primeira avaliação com x = 10
        engine.evaluate('x = 10');
        final result1 = engine.evaluate('x * 2');
        expect((result1.value as NumberValue).rawValue, equals(20));

        // Mudar o valor de x
        engine.evaluate('x = 20');
        final result2 = engine.evaluate('x * 2');
        expect((result2.value as NumberValue).rawValue, equals(40));

        // Verificar histórico
        final history = engine.listHistory();
        expect(history.length, greaterThan(0));
      });

      test('History with errors', () {
        engine.evaluate('10 / 0');
        engine.evaluate('sqrt(-1)');
        engine.evaluate('undefined');

        final history = engine.listHistory();
        final failedEntries = history.where((e) => !e.success).toList();

        expect(failedEntries.length, equals(3));
      });

      test('History filtering by success', () {
        engine.evaluate('2 + 2');
        engine.evaluate('10 / 0'); // Error
        engine.evaluate('3 * 3');
        engine.evaluate('undefined'); // Error

        final successOnly = engine.listHistory(
          filter: HistoryFilter(successOnly: true),
        );

        expect(successOnly.every((e) => e.success), isTrue);
        expect(successOnly.length, equals(2));
      });

      test('History search', () {
        engine.evaluate('sin(0)');
        engine.evaluate('cos(0)');
        engine.evaluate('tan(0)');
        engine.evaluate('2 + 2');

        final history = engine.listHistory(
          filter: HistoryFilter(searchText: 'sin'),
        );

        expect(history.length, equals(1));
        expect(history[0].expressionRaw, contains('sin'));
      });

      test('History limit', () {
        for (var i = 0; i < 20; i++) {
          engine.evaluate('$i + 1');
        }

        final limited = engine.listHistory(limit: 5);
        expect(limited.length, equals(5));
      });

      test('History clear', () {
        engine.evaluate('1 + 1');
        engine.evaluate('2 + 2');
        engine.evaluate('3 + 3');

        expect(engine.listHistory().length, equals(3));

        engine.clearHistory();
        expect(engine.listHistory().length, equals(0));
      });

      test('History export and import', () {
        engine.evaluate('10 + 5');
        engine.evaluate('20 * 3');

        final exported = engine.exportHistory();
        expect(exported.length, equals(2));

        // Criar nova engine e importar
        final newEngine = CalculatorEngine();
        newEngine.importHistory(exported);

        final imported = newEngine.listHistory();
        expect(imported.length, equals(2));
        expect(imported[1].expressionRaw, equals('10 + 5'));
        expect(imported[0].expressionRaw, equals('20 * 3'));
      });
    });

    group('Variable and Memory Persistence', () {
      test('Variables export and import', () {
        engine.evaluate('x = 100');
        engine.evaluate('y = 200');
        engine.evaluate('z = 300');

        final exported = engine.exportVariables();
        expect(exported.length, equals(3));

        // Criar nova engine e importar
        final newEngine = CalculatorEngine();
        newEngine.importVariables(exported);

        final result = newEngine.evaluate('x + y + z');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(600));
      });

      test('Memory persists across evaluations', () {
        engine.setMemory('M5', NumberValue(999));

        final result1 = engine.evaluate('M5');
        expect((result1.value as NumberValue).rawValue, equals(999));

        engine.evaluate('2 + 2'); // Outra operação

        final result2 = engine.evaluate('M5');
        expect((result2.value as NumberValue).rawValue, equals(999));
      });
    });

    group('Complex Integration Scenarios', () {
      test('Multiple operations with variables and memory', () {
        engine.evaluate('x = 10');
        engine.evaluate('y = 20');
        engine.setMemory('M0', NumberValue(5));

        final result = engine.evaluate('(x + y) * M0');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(150));
      });

      test('Chained calculations using ANS', () {
        engine.evaluate('10');
        engine.evaluate('ANS + 5');
        engine.evaluate('ANS * 2');
        final result = engine.evaluate('ANS - 10');

        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(20));
      });

      test('Function composition', () {
        final result = engine.evaluate('sqrt(abs(-16))');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(4));
      });

      test('Mixed operators and functions', () {
        final result = engine.evaluate('2 * sin(0) + 3 * cos(0)');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, closeTo(3, 0.0001));
      });

      test('Implicit multiplication with functions', () {
        final result = engine.evaluate('2sqrt(4)');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(4));
      });

      test('Postfix operators in complex expressions', () {
        final result = engine.evaluate('5! / 10');
        expect(result.success, isTrue);
        expect((result.value as NumberValue).rawValue, equals(12));
      });

      test('Bitwise operations in expressions', () {
        final result = engine.evaluate('(8 << 2) & 31');
        expect(result.success, isTrue);
        expect((result.value as IntegerValue).rawValue, equals(0));
      });
    });

    group('Error Recovery', () {
      test('Error does not affect subsequent evaluations', () {
        final error = engine.evaluate('10 / 0');
        expect(error.success, isFalse);

        final success = engine.evaluate('2 + 2');
        expect(success.success, isTrue);
        expect((success.value as NumberValue).rawValue, equals(4));
      });

      test('Parse error does not affect state', () {
        engine.evaluate('x = 100');

        final error = engine.evaluate('x +');
        expect(error.success, isFalse);

        final success = engine.evaluate('x');
        expect(success.success, isTrue);
        expect((success.value as NumberValue).rawValue, equals(100));
      });

      test('Multiple errors in sequence', () {
        final error1 = engine.evaluate('10 / 0');
        final error2 = engine.evaluate('sqrt(-1)');
        final error3 = engine.evaluate('undefined');

        expect(error1.success, isFalse);
        expect(error2.success, isFalse);
        expect(error3.success, isFalse);

        final success = engine.evaluate('5 + 5');
        expect(success.success, isTrue);
      });
    });
  });
}
