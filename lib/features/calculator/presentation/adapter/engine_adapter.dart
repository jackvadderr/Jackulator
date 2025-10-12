import 'package:expressions/expressions.dart' as ex;
import 'package:myapp/features/calculator/domain/calculator_engine.dart';

import '../input/editor_state.dart';
import '../normalize/normalizer.dart';

class EngineAdapter {
  final CalculatorEngine engine;
  const EngineAdapter(this.engine);

  /// Try to compute a live preview value from the current editor state.
  /// Returns null if the expression is incomplete or invalid.
  String? tryPreview(
    EditorState state, {
    NormalizerOptions opts = const NormalizerOptions(),
  }) {
    final expr = Normalizer.toEngineExpression(state, opts: opts);
    if (expr.trim().isEmpty) return null;

    final parsed = engine.parse(expr);
    if (parsed.ast != null && !parsed.hasErrors) {
      final result = engine.evaluateAst(parsed.ast!);
      if (result.success && result.value != null) {
        final v = result.value!;
        if (v is NumberValue) return _format(v.rawValue);
        if (v is IntegerValue) return _format(v.rawValue);
        if (v is BooleanValue) return v.rawValue.toString();
        return v.toString();
      }
    }

    // Fallback: evaluate simple arithmetic with 'expressions'
    try {
      final exp = ex.Expression.parse(expr);
      final eval = const ex.ExpressionEvaluator().eval(exp, {});
      if (eval is num) return _format(eval);
    } catch (_) {}

    return null;
  }

  /// Evaluate final result for '=' given the editor state (normalized expression).
  String evaluateFinal(
    EditorState state, {
    NormalizerOptions opts = const NormalizerOptions(),
  }) {
    final expr = Normalizer.toEngineExpression(state, opts: opts);
    final eval = engine.evaluate(expr);
    if (eval.success && eval.value != null) {
      final v = eval.value!;
      if (v is NumberValue) return _format(v.rawValue);
      if (v is IntegerValue) return _format(v.rawValue);
      if (v is BooleanValue) return v.rawValue.toString();
      return v.toString();
    }

    // Fallback
    try {
      final exp = ex.Expression.parse(expr);
      final res = const ex.ExpressionEvaluator().eval(exp, {});
      if (res is num) return _format(res);
    } catch (_) {}

    throw StateError(eval.error?.message ?? 'Evaluation failed');
  }

  String _format(num result) {
    if (result.isNaN || result.isInfinite) return 'Error';
    if (result.abs() > 9999999999 ||
        (result.abs() < 0.0000001 && result != 0)) {
      return result.toStringAsExponential(7);
    }
    if (result is double && result.truncateToDouble() == result) {
      return result.truncate().toString();
    }
    if (result is int) return result.toString();
    String formatted = result.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '');
    return formatted.endsWith('.')
        ? formatted.substring(0, formatted.length - 1)
        : formatted;
  }
}
