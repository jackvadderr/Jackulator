/// Tipos de tokens suportados pelo lexer
enum TokenType {
  // Números
  number,

  // Identificadores (variáveis, funções)
  identifier,

  // Operadores aritméticos
  plus,
  minus,
  multiply,
  divide,
  power,
  modulo,

  // Operadores bitwise (modo programador)
  bitwiseAnd,
  bitwiseOr,
  bitwiseXor,
  bitwiseNot,
  leftShift,
  rightShift,

  // Parênteses
  leftParen,
  rightParen,

  // Separadores
  comma,
  semicolon,

  // Operadores postfix
  factorial,
  percent,

  // Símbolos especiais
  assign,
  colon,

  // Comparação
  less,
  lessEqual,
  greater,
  greaterEqual,
  equal,
  notEqual,

  // Lógicos
  and,
  or,
  not,

  // Strings
  string,

  // Comentários
  comment,

  // Fim de expressão
  eof,
}

/// Representa a posição de um token no texto original
class SourceSpan {
  final int startIndex;
  final int endIndex;
  final int startLine;
  final int startColumn;
  final int endLine;
  final int endColumn;

  const SourceSpan({
    required this.startIndex,
    required this.endIndex,
    required this.startLine,
    required this.startColumn,
    required this.endLine,
    required this.endColumn,
  });

  int get length => endIndex - startIndex;

  @override
  String toString() =>
      'SourceSpan($startLine:$startColumn-$endLine:$endColumn)';
}

/// Token individual gerado pelo lexer
class Token {
  final TokenType type;
  final String raw;
  final SourceSpan span;
  final dynamic value; // Valor processado (para números, strings, etc.)

  const Token({
    required this.type,
    required this.raw,
    required this.span,
    this.value,
  });

  @override
  String toString() => 'Token($type, "$raw", $span)';
}
