import 'dart:math' as math;

import 'ast.dart';
import 'context.dart';
import 'errors.dart';
import 'token.dart' as t;
import 'values.dart';

/// Resultado da avaliação
class EvaluationResult {
  final Value? value;
  final ValueType? type;
  final EvaluationError? error;
  final List<Diagnostic> diagnostics;

  const EvaluationResult({
    this.value,
    this.type,
    this.error,
    this.diagnostics = const [],
  });

  bool get success => error == null && value != null;
  bool get hasWarnings =>
      diagnostics.any((d) => d.severity == DiagnosticSeverity.warning);

  @override
  String toString() {
    if (error != null) return 'Error: $error';
    if (value != null) return value.toString();
    return 'No result';
  }
}

/// Avaliador de AST
class Evaluator implements AstVisitor<Value> {
  final EvaluationContext context;
  final List<Diagnostic> _diagnostics = [];
  int _recursionDepth = 0;

  Evaluator(this.context);

  /// Avalia uma AST e retorna o resultado
  EvaluationResult evaluate(AstNode ast) {
    _diagnostics.clear();
    _recursionDepth = 0;

    try {
      // Verificar cache
      if (ast.isCachedFor(context.hashCode)) {
        return EvaluationResult(
          value: ast.cachedValue as Value,
          type: (ast.cachedValue as Value).type,
          diagnostics: List.from(_diagnostics),
        );
      }

      final value = ast.accept(this);

      // Cachear resultado
      ast.setCachedValue(value, context.hashCode);

      return EvaluationResult(
        value: value,
        type: value.type,
        diagnostics: List.from(_diagnostics),
      );
    } on EvaluationError catch (e) {
      return EvaluationResult(error: e, diagnostics: List.from(_diagnostics));
    } catch (e) {
      return EvaluationResult(
        error: EvaluationError(message: e.toString(), code: 'UNKNOWN_ERROR'),
        diagnostics: List.from(_diagnostics),
      );
    }
  }

  @override
  Value visitNumber(NumberNode node) {
    return NumberValue(node.value);
  }

  @override
  Value visitString(StringNode node) {
    return StringValue(node.value);
  }

  @override
  Value visitIdentifier(IdentifierNode node) {
    final name = node.name;

    // Verificar se é uma constante
    if (context.hasConstant(name)) {
      return NumberValue(context.getConstant(name)!);
    }

    // Verificar se é uma variável
    if (context.hasVariable(name)) {
      return context.getVariable(name)!;
    }

    // Verificar se é um registro de memória
    if (context.getMemory(name) != null) {
      return context.getMemory(name)!;
    }

    throw EvaluationError.undefinedVariable(name, node.span);
  }

  @override
  Value visitUnaryOp(UnaryOpNode node) {
    final operand = node.operand.accept(this);

    if (node.isPrefix) {
      return _evaluatePrefixUnaryOp(node.operator, operand, node.span);
    } else {
      return _evaluatePostfixUnaryOp(node.operator, operand, node.span);
    }
  }

  Value _evaluatePrefixUnaryOp(String op, Value operand, t.SourceSpan span) {
    switch (op) {
      case '+':
        return operand;

      case '-':
        if (operand is NumberValue) {
          return NumberValue(-operand.rawValue);
        }
        if (operand is IntegerValue) {
          return IntegerValue(-operand.rawValue);
        }
        if (operand is ComplexValue) {
          return ComplexValue(-operand.real, -operand.imaginary);
        }
        throw EvaluationError.typeMismatch('number', operand.type.name, span);

      case '~':
        // Bitwise NOT
        if (operand is IntegerValue) {
          return IntegerValue(~operand.rawValue);
        }
        if (operand is NumberValue) {
          return IntegerValue(~operand.rawValue.toInt());
        }
        throw EvaluationError.typeMismatch('integer', operand.type.name, span);

      case '!':
        // Logical NOT
        if (operand is BooleanValue) {
          return BooleanValue(!operand.rawValue);
        }
        throw EvaluationError.typeMismatch('boolean', operand.type.name, span);

      default:
        throw EvaluationError(
          message: 'Unknown prefix operator: $op',
          code: 'UNKNOWN_OPERATOR',
          span: span,
        );
    }
  }

  Value _evaluatePostfixUnaryOp(String op, Value operand, t.SourceSpan span) {
    switch (op) {
      case '!':
        // Factorial
        if (operand is NumberValue || operand is IntegerValue) {
          final n = operand.rawValue as num;
          if (n < 0 || n != n.toInt()) {
            throw EvaluationError.domainError(
              'Factorial requires non-negative integer',
              span,
            );
          }
          return IntegerValue(_factorial(n.toInt()));
        }
        throw EvaluationError.typeMismatch('integer', operand.type.name, span);

      case '%':
        // Percent (divide by 100)
        if (operand is NumberValue) {
          return NumberValue(operand.rawValue / 100);
        }
        if (operand is IntegerValue) {
          return NumberValue(operand.rawValue / 100);
        }
        throw EvaluationError.typeMismatch('number', operand.type.name, span);

      default:
        throw EvaluationError(
          message: 'Unknown postfix operator: $op',
          code: 'UNKNOWN_OPERATOR',
          span: span,
        );
    }
  }

  int _factorial(int n) {
    if (n > 20) {
      throw EvaluationError(
        message: 'Factorial overflow: $n is too large',
        code: 'OVERFLOW',
      );
    }
    if (n <= 1) return 1;
    return n * _factorial(n - 1);
  }

  @override
  Value visitBinaryOp(BinaryOpNode node) {
    final left = node.left.accept(this);

    // Short-circuit para operadores lógicos
    if (node.operator == '&&' || node.operator == '||') {
      return _evaluateLogicalOp(node.operator, left, node.right, node.span);
    }

    final right = node.right.accept(this);

    return _evaluateBinaryOp(node.operator, left, right, node.span);
  }

  Value _evaluateLogicalOp(
    String op,
    Value left,
    AstNode rightNode,
    t.SourceSpan span,
  ) {
    if (left is! BooleanValue) {
      throw EvaluationError.typeMismatch('boolean', left.type.name, span);
    }

    if (op == '&&') {
      if (!left.rawValue) return BooleanValue(false); // Short-circuit
      final right = rightNode.accept(this);
      if (right is! BooleanValue) {
        throw EvaluationError.typeMismatch('boolean', right.type.name, span);
      }
      return BooleanValue(right.rawValue);
    }

    if (op == '||') {
      if (left.rawValue) return BooleanValue(true); // Short-circuit
      final right = rightNode.accept(this);
      if (right is! BooleanValue) {
        throw EvaluationError.typeMismatch('boolean', right.type.name, span);
      }
      return BooleanValue(right.rawValue);
    }

    throw EvaluationError(
      message: 'Unknown logical operator: $op',
      code: 'UNKNOWN_OPERATOR',
      span: span,
    );
  }

  Value _evaluateBinaryOp(
    String op,
    Value left,
    Value right,
    t.SourceSpan span,
  ) {
    // Operadores aritméticos
    if (['+', '-', '*', '/', '^', '%'].contains(op)) {
      return _evaluateArithmeticOp(op, left, right, span);
    }

    // Operadores bitwise
    if (['&', '|', '^', '<<', '>>'].contains(op)) {
      return _evaluateBitwiseOp(op, left, right, span);
    }

    // Operadores de comparação
    if (['<', '<=', '>', '>=', '==', '!='].contains(op)) {
      return _evaluateComparisonOp(op, left, right, span);
    }

    throw EvaluationError(
      message: 'Unknown binary operator: $op',
      code: 'UNKNOWN_OPERATOR',
      span: span,
    );
  }

  Value _evaluateArithmeticOp(
    String op,
    Value left,
    Value right,
    t.SourceSpan span,
  ) {
    final l = _toNumber(left, span);
    final r = _toNumber(right, span);

    switch (op) {
      case '+':
        return NumberValue(l + r);
      case '-':
        return NumberValue(l - r);
      case '*':
        return NumberValue(l * r);
      case '/':
        if (r == 0) throw EvaluationError.divisionByZero(span);
        return NumberValue(l / r);
      case '^':
        return NumberValue(math.pow(l, r));
      case '%':
        if (r == 0) throw EvaluationError.divisionByZero(span);
        return NumberValue(l % r);
      default:
        throw EvaluationError(
          message: 'Unknown arithmetic operator: $op',
          code: 'UNKNOWN_OPERATOR',
          span: span,
        );
    }
  }

  Value _evaluateBitwiseOp(
    String op,
    Value left,
    Value right,
    t.SourceSpan span,
  ) {
    final l = _toInt(left, span);
    final r = _toInt(right, span);

    switch (op) {
      case '&':
        return IntegerValue(l & r);
      case '|':
        return IntegerValue(l | r);
      case '^':
        return IntegerValue(l ^ r);
      case '<<':
        return IntegerValue(l << r);
      case '>>':
        return IntegerValue(l >> r);
      default:
        throw EvaluationError(
          message: 'Unknown bitwise operator: $op',
          code: 'UNKNOWN_OPERATOR',
          span: span,
        );
    }
  }

  Value _evaluateComparisonOp(
    String op,
    Value left,
    Value right,
    t.SourceSpan span,
  ) {
    final l = _toNumber(left, span);
    final r = _toNumber(right, span);

    switch (op) {
      case '<':
        return BooleanValue(l < r);
      case '<=':
        return BooleanValue(l <= r);
      case '>':
        return BooleanValue(l > r);
      case '>=':
        return BooleanValue(l >= r);
      case '==':
        return BooleanValue(l == r);
      case '!=':
        return BooleanValue(l != r);
      default:
        throw EvaluationError(
          message: 'Unknown comparison operator: $op',
          code: 'UNKNOWN_OPERATOR',
          span: span,
        );
    }
  }

  @override
  Value visitFunctionCall(FunctionCallNode node) {
    _recursionDepth++;
    if (_recursionDepth > context.maxRecursionDepth) {
      throw EvaluationError(
        message: 'Maximum recursion depth exceeded',
        code: 'RECURSION_LIMIT',
        span: node.span,
      );
    }

    try {
      final func = context.getFunction(node.name);
      if (func == null) {
        throw EvaluationError.undefinedFunction(node.name, node.span);
      }

      if (!func.acceptsArity(node.arguments.length)) {
        throw EvaluationError.arityMismatch(
          node.name,
          func.minArity,
          node.arguments.length,
          node.span,
        );
      }

      final args = node.arguments.map((arg) => arg.accept(this)).toList();
      return func.implementation(args, context);
    } finally {
      _recursionDepth--;
    }
  }

  @override
  Value visitAssignment(AssignmentNode node) {
    final value = node.expression.accept(this);
    context.setVariable(node.target, value);

    // Atualizar ANS também
    context.setMemory('ANS', value);

    return value;
  }

  num _toNumber(Value value, t.SourceSpan span) {
    if (value is NumberValue) return value.rawValue;
    if (value is IntegerValue) return value.rawValue;
    if (value is RationalValue) return value.rawValue;
    throw EvaluationError.typeMismatch('number', value.type.name, span);
  }

  int _toInt(Value value, t.SourceSpan span) {
    if (value is IntegerValue) return value.rawValue;
    if (value is NumberValue) return value.rawValue.toInt();
    throw EvaluationError.typeMismatch('integer', value.type.name, span);
  }

  void _addDiagnostic(Diagnostic diagnostic) {
    _diagnostics.add(diagnostic);
  }
}
