import 'token.dart';

/// Nó base da árvore de sintaxe abstrata (AST)
abstract class AstNode {
  final SourceSpan span;

  // Cache de avaliação
  dynamic _evaluatedValue;
  int? _lastContextHash;

  // Metadados
  final List<String> warnings;
  final List<String> simplifications;

  AstNode({
    required this.span,
    this.warnings = const [],
    this.simplifications = const [],
  });

  /// Aceita um visitor para processamento
  T accept<T>(AstVisitor<T> visitor);

  /// Cria uma cópia do nó (para imutabilidade)
  AstNode copyWith();

  /// Cache da avaliação
  dynamic get cachedValue => _evaluatedValue;
  void setCachedValue(dynamic value, int contextHash) {
    _evaluatedValue = value;
    _lastContextHash = contextHash;
  }

  bool isCachedFor(int contextHash) => _lastContextHash == contextHash;
}

/// Nó de número literal
class NumberNode extends AstNode {
  final num value;
  final String raw;

  NumberNode({
    required this.value,
    required this.raw,
    required super.span,
    super.warnings,
    super.simplifications,
  });

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitNumber(this);

  @override
  NumberNode copyWith({
    num? value,
    String? raw,
    SourceSpan? span,
    List<String>? warnings,
    List<String>? simplifications,
  }) {
    return NumberNode(
      value: value ?? this.value,
      raw: raw ?? this.raw,
      span: span ?? this.span,
      warnings: warnings ?? this.warnings,
      simplifications: simplifications ?? this.simplifications,
    );
  }

  @override
  String toString() => 'NumberNode($value)';
}

/// Nó de identificador (variável ou função)
class IdentifierNode extends AstNode {
  final String name;

  IdentifierNode({
    required this.name,
    required super.span,
    super.warnings,
    super.simplifications,
  });

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitIdentifier(this);

  @override
  IdentifierNode copyWith({
    String? name,
    SourceSpan? span,
    List<String>? warnings,
    List<String>? simplifications,
  }) {
    return IdentifierNode(
      name: name ?? this.name,
      span: span ?? this.span,
      warnings: warnings ?? this.warnings,
      simplifications: simplifications ?? this.simplifications,
    );
  }

  @override
  String toString() => 'IdentifierNode($name)';
}

/// Nó de operação unária
class UnaryOpNode extends AstNode {
  final String operator;
  final AstNode operand;
  final bool isPrefix; // true = prefix (-x), false = postfix (x!)

  UnaryOpNode({
    required this.operator,
    required this.operand,
    this.isPrefix = true,
    required super.span,
    super.warnings,
    super.simplifications,
  });

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitUnaryOp(this);

  @override
  UnaryOpNode copyWith({
    String? operator,
    AstNode? operand,
    bool? isPrefix,
    SourceSpan? span,
    List<String>? warnings,
    List<String>? simplifications,
  }) {
    return UnaryOpNode(
      operator: operator ?? this.operator,
      operand: operand ?? this.operand,
      isPrefix: isPrefix ?? this.isPrefix,
      span: span ?? this.span,
      warnings: warnings ?? this.warnings,
      simplifications: simplifications ?? this.simplifications,
    );
  }

  @override
  String toString() => isPrefix
      ? 'UnaryOpNode($operator, $operand)'
      : 'UnaryOpNode($operand, $operator)';
}

/// Nó de operação binária
class BinaryOpNode extends AstNode {
  final String operator;
  final AstNode left;
  final AstNode right;

  BinaryOpNode({
    required this.operator,
    required this.left,
    required this.right,
    required super.span,
    super.warnings,
    super.simplifications,
  });

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitBinaryOp(this);

  @override
  BinaryOpNode copyWith({
    String? operator,
    AstNode? left,
    AstNode? right,
    SourceSpan? span,
    List<String>? warnings,
    List<String>? simplifications,
  }) {
    return BinaryOpNode(
      operator: operator ?? this.operator,
      left: left ?? this.left,
      right: right ?? this.right,
      span: span ?? this.span,
      warnings: warnings ?? this.warnings,
      simplifications: simplifications ?? this.simplifications,
    );
  }

  @override
  String toString() => 'BinaryOpNode($left $operator $right)';
}

/// Nó de chamada de função
class FunctionCallNode extends AstNode {
  final String name;
  final List<AstNode> arguments;

  FunctionCallNode({
    required this.name,
    required this.arguments,
    required super.span,
    super.warnings,
    super.simplifications,
  });

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitFunctionCall(this);

  @override
  FunctionCallNode copyWith({
    String? name,
    List<AstNode>? arguments,
    SourceSpan? span,
    List<String>? warnings,
    List<String>? simplifications,
  }) {
    return FunctionCallNode(
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
      span: span ?? this.span,
      warnings: warnings ?? this.warnings,
      simplifications: simplifications ?? this.simplifications,
    );
  }

  @override
  String toString() => 'FunctionCallNode($name, ${arguments.length} args)';
}

/// Nó de atribuição
class AssignmentNode extends AstNode {
  final String target;
  final AstNode expression;

  AssignmentNode({
    required this.target,
    required this.expression,
    required super.span,
    super.warnings,
    super.simplifications,
  });

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitAssignment(this);

  @override
  AssignmentNode copyWith({
    String? target,
    AstNode? expression,
    SourceSpan? span,
    List<String>? warnings,
    List<String>? simplifications,
  }) {
    return AssignmentNode(
      target: target ?? this.target,
      expression: expression ?? this.expression,
      span: span ?? this.span,
      warnings: warnings ?? this.warnings,
      simplifications: simplifications ?? this.simplifications,
    );
  }

  @override
  String toString() => 'AssignmentNode($target = $expression)';
}

/// Nó de string literal
class StringNode extends AstNode {
  final String value;

  StringNode({
    required this.value,
    required super.span,
    super.warnings,
    super.simplifications,
  });

  @override
  T accept<T>(AstVisitor<T> visitor) => visitor.visitString(this);

  @override
  StringNode copyWith({
    String? value,
    SourceSpan? span,
    List<String>? warnings,
    List<String>? simplifications,
  }) {
    return StringNode(
      value: value ?? this.value,
      span: span ?? this.span,
      warnings: warnings ?? this.warnings,
      simplifications: simplifications ?? this.simplifications,
    );
  }

  @override
  String toString() => 'StringNode("$value")';
}

/// Pattern Visitor para processar a AST
abstract class AstVisitor<T> {
  T visitNumber(NumberNode node);
  T visitIdentifier(IdentifierNode node);
  T visitUnaryOp(UnaryOpNode node);
  T visitBinaryOp(BinaryOpNode node);
  T visitFunctionCall(FunctionCallNode node);
  T visitAssignment(AssignmentNode node);
  T visitString(StringNode node);
}
