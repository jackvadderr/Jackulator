import 'dart:math' as math;

import 'package:expressions/expressions.dart';

/// CalculatorEngine centraliza a lógica de avaliação de expressões
/// matemáticas, servindo como a "camada de domínio" para cálculos.
class CalculatorEngine {
  const CalculatorEngine();

  /// Contexto com funções e constantes suportadas pelo avaliador.
  /// Mantemos `dynamic` nas closures para compatibilidade com o evaluator.
  static final Map<String, dynamic> _context = {
    'sqrt': (dynamic x) => math.sqrt((x as num).toDouble()),
    'sin': (dynamic x) => math.sin((x as num).toDouble()),
    'cos': (dynamic x) => math.cos((x as num).toDouble()),
    'tan': (dynamic x) => math.tan((x as num).toDouble()),
    'ln': (dynamic x) => math.log((x as num).toDouble()),
    'log': (dynamic x) => math.log((x as num).toDouble()) / math.ln10,
    'pow': (dynamic a, [dynamic b]) =>
        math.pow((a as num).toDouble(), (b as num).toDouble()),
    'e': math.e,
    'pi': math.pi,
  };

  /// Avalia uma expressão já normalizada (por exemplo, com parênteses equilibrados).
  /// Retorna um número em caso de sucesso, ou `null` em caso de erro.
  num? evaluate(String expression) {
    try {
      final parsed = Expression.parse(expression);
      final evaluator = const ExpressionEvaluator();
      final dynamic result = evaluator.eval(parsed, _context);

      if (result is num) return result;
      return num.tryParse(result.toString());
    } catch (_) {
      return null;
    }
  }
}
