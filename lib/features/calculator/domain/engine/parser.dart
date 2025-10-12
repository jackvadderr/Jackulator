import 'ast.dart';
import 'token.dart';

/// Configuração do parser
class ParserConfig {
  final bool implicitMultiplication; // 2pi, 2(3)
  final bool strictFunctionCalls; // Exigir parênteses para funções

  const ParserConfig({
    this.implicitMultiplication = true,
    this.strictFunctionCalls = false,
  });
}

/// Erro de parsing
class ParseError implements Exception {
  final String message;
  final int posStart;
  final int posEnd;
  final List<String> suggestions;

  const ParseError({
    required this.message,
    required this.posStart,
    required this.posEnd,
    this.suggestions = const [],
  });

  @override
  String toString() => 'ParseError: $message at position $posStart-$posEnd';
}

/// Resultado do parsing
class ParseResult {
  final AstNode? ast;
  final List<Token> tokens;
  final List<ParseError> errors;

  const ParseResult({this.ast, required this.tokens, this.errors = const []});

  bool get hasErrors => errors.isNotEmpty;
  bool get success => ast != null && !hasErrors;
}

/// Parser recursivo-descendente para expressões matemáticas
class Parser {
  final List<Token> tokens;
  final ParserConfig config;

  int _current = 0;
  final List<ParseError> _errors = [];

  Parser(this.tokens, {this.config = const ParserConfig()});

  /// Parse completo da expressão
  ParseResult parse() {
    try {
      if (tokens.isEmpty ||
          (tokens.length == 1 && tokens[0].type == TokenType.eof)) {
        return ParseResult(tokens: tokens, errors: _errors);
      }

      final ast = _parseExpression();

      if (!_isAtEnd() && _peek().type != TokenType.eof) {
        _errors.add(
          ParseError(
            message: 'Unexpected token after expression: ${_peek().raw}',
            posStart: _peek().span.startIndex,
            posEnd: _peek().span.endIndex,
            suggestions: ['Remove extra characters', 'Add an operator'],
          ),
        );
      }

      return ParseResult(ast: ast, tokens: tokens, errors: _errors);
    } catch (e) {
      if (e is ParseError) {
        _errors.add(e);
      }
      return ParseResult(tokens: tokens, errors: _errors);
    }
  }

  /// Expressão (nível mais baixo de precedência)
  AstNode _parseExpression() {
    return _parseAssignment();
  }

  /// Atribuição: identifier = expression
  AstNode _parseAssignment() {
    final expr = _parseLogicalOr();

    if (_match([TokenType.assign])) {
      final equals = _previous();

      if (expr is! IdentifierNode) {
        throw ParseError(
          message: 'Invalid assignment target',
          posStart: expr.span.startIndex,
          posEnd: expr.span.endIndex,
          suggestions: ['Assignment target must be a variable name'],
        );
      }

      final value = _parseAssignment(); // Right associative

      return AssignmentNode(
        target: expr.name,
        expression: value,
        span: SourceSpan(
          startIndex: expr.span.startIndex,
          endIndex: value.span.endIndex,
          startLine: expr.span.startLine,
          startColumn: expr.span.startColumn,
          endLine: value.span.endLine,
          endColumn: value.span.endColumn,
        ),
      );
    }

    return expr;
  }

  AstNode _parseLogicalOr() {
    var expr = _parseLogicalAnd();
    while (_match([TokenType.or])) {
      final right = _parseLogicalAnd();
      expr = BinaryOpNode(
        operator: '||',
        left: expr,
        right: right,
        span: _combineSpans(expr.span, right.span),
      );
    }
    return expr;
  }

  AstNode _parseLogicalAnd() {
    var expr = _parseComparison();
    while (_match([TokenType.and])) {
      final right = _parseComparison();
      expr = BinaryOpNode(
        operator: '&&',
        left: expr,
        right: right,
        span: _combineSpans(expr.span, right.span),
      );
    }
    return expr;
  }

  AstNode _parseComparison() {
    var expr = _parseBitwiseOr();
    while (_match([
      TokenType.less,
      TokenType.lessEqual,
      TokenType.greater,
      TokenType.greaterEqual,
      TokenType.equal,
      TokenType.notEqual,
    ])) {
      final op = _previous();
      final right = _parseBitwiseOr();
      expr = BinaryOpNode(
        operator: op.raw,
        left: expr,
        right: right,
        span: _combineSpans(expr.span, right.span),
      );
    }
    return expr;
  }

  AstNode _parseBitwiseOr() {
    var expr = _parseBitwiseXor();
    while (_match([TokenType.bitwiseOr])) {
      final right = _parseBitwiseXor();
      expr = BinaryOpNode(
        operator: '|',
        left: expr,
        right: right,
        span: _combineSpans(expr.span, right.span),
      );
    }
    return expr;
  }

  AstNode _parseBitwiseXor() {
    var expr = _parseBitwiseAnd();
    // Note: XOR token may not be produced; reserved for future use
    while (_match([TokenType.bitwiseXor])) {
      final right = _parseBitwiseAnd();
      expr = BinaryOpNode(
        operator: '^',
        left: expr,
        right: right,
        span: _combineSpans(expr.span, right.span),
      );
    }
    return expr;
  }

  AstNode _parseBitwiseAnd() {
    var expr = _parseBitwiseShift();
    while (_match([TokenType.bitwiseAnd])) {
      final right = _parseBitwiseShift();
      expr = BinaryOpNode(
        operator: '&',
        left: expr,
        right: right,
        span: _combineSpans(expr.span, right.span),
      );
    }
    return expr;
  }

  AstNode _parseBitwiseShift() {
    var expr = _parseAddition();
    while (_match([TokenType.leftShift, TokenType.rightShift])) {
      final op = _previous();
      final right = _parseAddition();
      expr = BinaryOpNode(
        operator: op.raw,
        left: expr,
        right: right,
        span: _combineSpans(expr.span, right.span),
      );
    }
    return expr;
  }

  /// Adição e subtração
  AstNode _parseAddition() {
    var expr = _parseMultiplication();
    while (_match([TokenType.plus, TokenType.minus])) {
      final op = _previous();
      final right = _parseMultiplication();
      expr = BinaryOpNode(
        operator: op.raw,
        left: expr,
        right: right,
        span: _combineSpans(expr.span, right.span),
      );
    }
    return expr;
  }

  /// Multiplicação, divisão e módulo
  AstNode _parseMultiplication() {
    var expr = _parseUnaryPrefix();

    while (true) {
      // '*' and '/'
      if (_match([TokenType.multiply, TokenType.divide])) {
        final op = _previous();
        final right = _parseUnaryPrefix();
        expr = BinaryOpNode(
          operator: op.raw,
          left: expr,
          right: right,
          span: _combineSpans(expr.span, right.span),
        );
        continue;
      }

      // '%' as binary modulo only if followed by an operand
      if (_check(TokenType.percent)) {
        // Lookahead to ensure binary form (has right operand)
        final next = tokens[_current + 1];
        final hasRightOperand =
            next.type == TokenType.number ||
            next.type == TokenType.identifier ||
            next.type == TokenType.leftParen;
        if (hasRightOperand) {
          _advance(); // consume '%'
          final right = _parseUnaryPrefix();
          expr = BinaryOpNode(
            operator: '%',
            left: expr,
            right: right,
            span: _combineSpans(expr.span, right.span),
          );
          continue;
        }
      }

      break;
    }

    // Multiplicação implícita
    if (config.implicitMultiplication) {
      while (_check(TokenType.number) ||
          _check(TokenType.identifier) ||
          _check(TokenType.leftParen)) {
        final right = _parseUnaryPrefix();
        expr = BinaryOpNode(
          operator: '*',
          left: expr,
          right: right,
          span: _combineSpans(expr.span, right.span),
        );
      }
    }

    return expr;
  }

  /// Exponenciação (associativa à direita), de maior precedência que unários prefixos
  AstNode _parsePower() {
    var expr = _parsePostfix();

    if (_match([TokenType.power])) {
      final right = _parsePower(); // Right associative
      expr = BinaryOpNode(
        operator: '^',
        left: expr,
        right: right,
        span: _combineSpans(expr.span, right.span),
      );
    }

    return expr;
  }

  /// Operadores unários (prefixo): têm menor precedência que potência
  AstNode _parseUnaryPrefix() {
    if (_match([
      // Removed unary plus to avoid accepting sequences like '++'
      TokenType.minus,
      TokenType.bitwiseNot,
      TokenType.not,
    ])) {
      final op = _previous();
      final right = _parseUnaryPrefix();
      return UnaryOpNode(
        operator: op.raw,
        operand: right,
        isPrefix: true,
        span: _combineSpans(op.span, right.span),
      );
    }

    // Base case: potência/postfix
    return _parsePower();
  }

  /// Operadores unários (postfixo)
  AstNode _parsePostfix() {
    var expr = _parsePrimary();

    while (true) {
      // Factorial postfix
      if (_match([TokenType.factorial])) {
        final op = _previous();
        expr = UnaryOpNode(
          operator: op.raw,
          operand: expr,
          isPrefix: false,
          span: _combineSpans(expr.span, op.span),
        );
        continue;
      }

      // Percent can be postfix OR binary (modulo)
      if (_check(TokenType.percent)) {
        // Lookahead to decide postfix vs binary
        final next = tokens[_current + 1];
        final hasRightOperand =
            next.type == TokenType.number ||
            next.type == TokenType.identifier ||
            next.type == TokenType.leftParen;
        if (!hasRightOperand) {
          _advance();
          final op = _previous();
          expr = UnaryOpNode(
            operator: op.raw,
            operand: expr,
            isPrefix: false,
            span: _combineSpans(expr.span, op.span),
          );
          continue;
        }
      }

      break;
    }

    return expr;
  }

  /// Expressões primárias
  AstNode _parsePrimary() {
    // Números
    if (_match([TokenType.number])) {
      final token = _previous();
      return NumberNode(
        value: token.value as num,
        raw: token.raw,
        span: token.span,
      );
    }

    // Strings
    if (_match([TokenType.string])) {
      final token = _previous();
      return StringNode(value: token.value as String, span: token.span);
    }

    // Identificadores (variáveis ou funções)
    if (_match([TokenType.identifier])) {
      final token = _previous();

      // Verificar se é chamada de função
      if (_check(TokenType.leftParen)) {
        return _parseFunctionCall(token);
      }

      return IdentifierNode(name: token.raw, span: token.span);
    }

    // Expressões agrupadas
    if (_match([TokenType.leftParen])) {
      final leftParen = _previous();
      final expr = _parseExpression();

      if (!_match([TokenType.rightParen])) {
        throw ParseError(
          message: 'Expected closing parenthesis',
          posStart: leftParen.span.startIndex,
          posEnd: _peek().span.startIndex,
          suggestions: ['Add ) at the end', 'Check for matching parentheses'],
        );
      }

      return expr;
    }

    throw ParseError(
      message: 'Unexpected token: ${_peek().raw}',
      posStart: _peek().span.startIndex,
      posEnd: _peek().span.endIndex,
      suggestions: ['Check expression syntax'],
    );
  }

  /// Parse de chamada de função
  FunctionCallNode _parseFunctionCall(Token nameToken) {
    _consume(TokenType.leftParen, 'Expected ( after function name');

    final arguments = <AstNode>[];

    if (!_check(TokenType.rightParen)) {
      do {
        arguments.add(_parseExpression());
      } while (_match([TokenType.comma]));
    }

    final rightParen = _consume(
      TokenType.rightParen,
      'Expected ) after function arguments',
    );

    return FunctionCallNode(
      name: nameToken.raw,
      arguments: arguments,
      span: _combineSpans(nameToken.span, rightParen.span),
    );
  }

  // Helpers

  bool _match(List<TokenType> types) {
    for (final type in types) {
      if (_check(type)) {
        _advance();
        return true;
      }
    }
    return false;
  }

  bool _check(TokenType type) {
    if (_isAtEnd()) return false;
    return _peek().type == type;
  }

  Token _advance() {
    if (!_isAtEnd()) _current++;
    return _previous();
  }

  bool _isAtEnd() => _peek().type == TokenType.eof;

  Token _peek() => tokens[_current];

  Token _previous() => tokens[_current - 1];

  Token _consume(TokenType type, String message) {
    if (_check(type)) return _advance();

    throw ParseError(
      message: message,
      posStart: _peek().span.startIndex,
      posEnd: _peek().span.endIndex,
    );
  }

  SourceSpan _combineSpans(SourceSpan a, SourceSpan b) {
    return SourceSpan(
      startIndex: a.startIndex,
      endIndex: b.endIndex,
      startLine: a.startLine,
      startColumn: a.startColumn,
      endLine: b.endLine,
      endColumn: b.endColumn,
    );
  }
}
