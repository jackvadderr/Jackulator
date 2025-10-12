import 'token.dart';

/// Severidade do diagnóstico
enum DiagnosticSeverity { info, warning, error }

/// Diagnóstico (aviso ou erro)
class Diagnostic {
  final DiagnosticSeverity severity;
  final String message;
  final String? hint;
  final SourceSpan? span;

  const Diagnostic({
    required this.severity,
    required this.message,
    this.hint,
    this.span,
  });

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('${severity.name.toUpperCase()}: $message');
    if (hint != null) buffer.write('\nHint: $hint');
    if (span != null) buffer.write('\nAt: $span');
    return buffer.toString();
  }
}

/// Erro de avaliação
class EvaluationError implements Exception {
  final String message;
  final String code;
  final SourceSpan? span;
  final String? hint;

  const EvaluationError({
    required this.message,
    required this.code,
    this.span,
    this.hint,
  });

  @override
  String toString() {
    final buffer = StringBuffer('EvaluationError [$code]: $message');
    if (hint != null) buffer.write('\nHint: $hint');
    if (span != null) buffer.write('\nAt: $span');
    return buffer.toString();
  }

  // Erros comuns
  static EvaluationError divisionByZero(SourceSpan? span) {
    return EvaluationError(
      message: 'Division by zero',
      code: 'DIVISION_BY_ZERO',
      span: span,
      hint: 'Cannot divide by zero',
    );
  }

  static EvaluationError domainError(
    String message,
    SourceSpan? span, {
    String? hint,
  }) {
    return EvaluationError(
      message: message,
      code: 'DOMAIN_ERROR',
      span: span,
      hint: hint ?? 'Value is outside the valid domain for this operation',
    );
  }

  static EvaluationError undefinedVariable(String name, SourceSpan? span) {
    return EvaluationError(
      message: 'Undefined variable: $name',
      code: 'UNDEFINED_VARIABLE',
      span: span,
      hint:
          'Variable "$name" has not been defined. Use $name = value to define it.',
    );
  }

  static EvaluationError undefinedFunction(String name, SourceSpan? span) {
    return EvaluationError(
      message: 'Undefined function: $name',
      code: 'UNDEFINED_FUNCTION',
      span: span,
      hint: 'Function "$name" is not defined',
    );
  }

  static EvaluationError arityMismatch(
    String name,
    int expected,
    int actual,
    SourceSpan? span,
  ) {
    return EvaluationError(
      message: 'Function $name expects $expected arguments but got $actual',
      code: 'ARITY_MISMATCH',
      span: span,
      hint: 'Check the number of arguments passed to the function',
    );
  }

  static EvaluationError overflow(SourceSpan? span) {
    return EvaluationError(
      message: 'Numeric overflow',
      code: 'OVERFLOW',
      span: span,
      hint: 'Result is too large to represent',
    );
  }

  static EvaluationError timeout(SourceSpan? span) {
    return EvaluationError(
      message: 'Evaluation timeout',
      code: 'TIMEOUT',
      span: span,
      hint: 'Expression took too long to evaluate',
    );
  }

  static EvaluationError typeMismatch(
    String expected,
    String actual,
    SourceSpan? span,
  ) {
    return EvaluationError(
      message: 'Type mismatch: expected $expected but got $actual',
      code: 'TYPE_MISMATCH',
      span: span,
      hint: 'Check the types of values used in the expression',
    );
  }

  static EvaluationError incompatibleUnits(
    String unit1,
    String unit2,
    SourceSpan? span,
  ) {
    return EvaluationError(
      message: 'Incompatible units: $unit1 and $unit2',
      code: 'INCOMPATIBLE_UNITS',
      span: span,
      hint: 'Cannot perform this operation with different unit types',
    );
  }
}

/// Erro de memória
class MemoryError implements Exception {
  final String message;
  final String registerName;

  const MemoryError({required this.message, required this.registerName});

  @override
  String toString() => 'MemoryError [$registerName]: $message';
}

/// Erro de timeout
class TimeoutError implements Exception {
  final String message;
  final Duration elapsed;

  const TimeoutError({required this.message, required this.elapsed});

  @override
  String toString() =>
      'TimeoutError: $message (elapsed: ${elapsed.inMilliseconds}ms)';
}
