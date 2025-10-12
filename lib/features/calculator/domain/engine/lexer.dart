import 'token.dart';

/// Configuração do lexer
class LexerConfig {
  final String decimalSeparator; // '.' ou ','
  final bool allowUnderscoreInNumbers; // 1_000_000
  final bool supportComments;
  final bool normalizeDecimalSeparator; // Converter ',' para '.' internamente

  const LexerConfig({
    this.decimalSeparator = '.',
    this.allowUnderscoreInNumbers = true,
    this.supportComments = false,
    this.normalizeDecimalSeparator = true,
  });

  static const ptBR = LexerConfig(
    decimalSeparator: ',',
    normalizeDecimalSeparator: true,
  );

  static const standard = LexerConfig();
}

/// Erro de lexer
class LexerError implements Exception {
  final String message;
  final int position;
  final int line;
  final int column;

  const LexerError({
    required this.message,
    required this.position,
    required this.line,
    required this.column,
  });

  @override
  String toString() => 'LexerError at $line:$column - $message';
}

/// Lexer/Tokenizer para expressões matemáticas
class Lexer {
  final String input;
  final LexerConfig config;

  int _position = 0;
  int _line = 0;
  int _column = 0;

  // Constantes reconhecidas
  static const _constants = {'pi', 'e', 'i'};

  Lexer(this.input, {this.config = const LexerConfig()});

  /// Tokeniza toda a entrada
  List<Token> tokenize() {
    final tokens = <Token>[];

    while (!_isAtEnd()) {
      _skipWhitespace();
      if (_isAtEnd()) break;

      final token = _nextToken();
      if (token != null && token.type != TokenType.comment) {
        tokens.add(token);
      }
    }

    tokens.add(
      Token(
        type: TokenType.eof,
        raw: '',
        span: _makeSpan(_position, _position),
      ),
    );

    return tokens;
  }

  Token? _nextToken() {
    final start = _position;
    final char = _peek();

    // Comentários
    if (config.supportComments && char == '/' && _peekNext() == '/') {
      return _readComment();
    }

    // Números
    if (_isDigit(char)) {
      return _readNumber();
    }

    // Identificadores e constantes
    if (_isAlpha(char)) {
      return _readIdentifier();
    }

    // Strings
    if (char == '"' || char == "'") {
      return _readString(char);
    }

    // Operadores de dois caracteres
    final twoChar = _peek(0) + _peek(1);
    switch (twoChar) {
      case '<<':
        _advance(2);
        return _makeToken(TokenType.leftShift, '<<', start);
      case '>>':
        _advance(2);
        return _makeToken(TokenType.rightShift, '>>', start);
      case '==':
        _advance(2);
        return _makeToken(TokenType.equal, '==', start);
      case '!=':
        _advance(2);
        return _makeToken(TokenType.notEqual, '!=', start);
      case '<=':
        _advance(2);
        return _makeToken(TokenType.lessEqual, '<=', start);
      case '>=':
        _advance(2);
        return _makeToken(TokenType.greaterEqual, '>=', start);
      case '&&':
        _advance(2);
        return _makeToken(TokenType.and, '&&', start);
      case '||':
        _advance(2);
        return _makeToken(TokenType.or, '||', start);
    }

    // Operadores de um caractere
    _advance();
    switch (char) {
      case '+':
        return _makeToken(TokenType.plus, '+', start);
      case '-':
        return _makeToken(TokenType.minus, '-', start);
      case '*':
        return _makeToken(TokenType.multiply, '*', start);
      case '/':
        return _makeToken(TokenType.divide, '/', start);
      case '^':
        return _makeToken(TokenType.power, '^', start);
      case '%':
        return _makeToken(TokenType.percent, '%', start);
      case '&':
        return _makeToken(TokenType.bitwiseAnd, '&', start);
      case '|':
        return _makeToken(TokenType.bitwiseOr, '|', start);
      case '~':
        return _makeToken(TokenType.bitwiseNot, '~', start);
      case '(':
        return _makeToken(TokenType.leftParen, '(', start);
      case ')':
        return _makeToken(TokenType.rightParen, ')', start);
      case ',':
        return _makeToken(TokenType.comma, ',', start);
      case ';':
        return _makeToken(TokenType.semicolon, ';', start);
      case '=':
        return _makeToken(TokenType.assign, '=', start);
      case ':':
        return _makeToken(TokenType.colon, ':', start);
      case '!':
        return _makeToken(TokenType.factorial, '!', start);
      case '<':
        return _makeToken(TokenType.less, '<', start);
      case '>':
        return _makeToken(TokenType.greater, '>', start);
      default:
        throw LexerError(
          message: 'Unexpected character: $char',
          position: start,
          line: _line,
          column: _column - 1,
        );
    }
  }

  Token _readNumber() {
    final start = _position;

    // Parte inteira
    while (_isDigit(_peek()) ||
        (config.allowUnderscoreInNumbers && _peek() == '_')) {
      _advance();
    }

    // Parte decimal
    final decimalSep = config.decimalSeparator;
    if (_peek() == decimalSep || _peek() == '.') {
      _advance();
      while (_isDigit(_peek()) ||
          (config.allowUnderscoreInNumbers && _peek() == '_')) {
        _advance();
      }
    }

    // Notação científica
    if (_peek() == 'e' || _peek() == 'E') {
      _advance();
      if (_peek() == '+' || _peek() == '-') {
        _advance();
      }
      while (_isDigit(_peek())) {
        _advance();
      }
    }

    final raw = input.substring(start, _position);

    // Normalizar para formato padrão (remover _ e trocar , por .)
    var normalized = raw.replaceAll('_', '');
    if (config.normalizeDecimalSeparator && decimalSep == ',') {
      normalized = normalized.replaceAll(',', '.');
    }

    final value = num.tryParse(normalized);

    return Token(
      type: TokenType.number,
      raw: raw,
      span: _makeSpan(start, _position),
      value: value,
    );
  }

  Token _readIdentifier() {
    final start = _position;

    while (_isAlphaNumeric(_peek()) || _peek() == '_') {
      _advance();
    }

    final raw = input.substring(start, _position);

    // Verificar se é uma constante conhecida
    final isConstant = _constants.contains(raw.toLowerCase());

    return Token(
      type: TokenType.identifier,
      raw: raw,
      span: _makeSpan(start, _position),
      value: isConstant ? raw.toLowerCase() : raw,
    );
  }

  Token _readString(String quote) {
    final start = _position;
    _advance(); // Pular aspas iniciais

    final buffer = StringBuffer();
    while (!_isAtEnd() && _peek() != quote) {
      if (_peek() == '\\') {
        _advance();
        // Escape sequences
        switch (_peek()) {
          case 'n':
            buffer.write('\n');
            break;
          case 't':
            buffer.write('\t');
            break;
          case 'r':
            buffer.write('\r');
            break;
          case '\\':
            buffer.write('\\');
            break;
          case '"':
            buffer.write('"');
            break;
          case "'":
            buffer.write("'");
            break;
          default:
            buffer.write(_peek());
        }
        _advance();
      } else {
        buffer.write(_peek());
        _advance();
      }
    }

    if (_isAtEnd()) {
      throw LexerError(
        message: 'Unterminated string',
        position: start,
        line: _line,
        column: _column,
      );
    }

    _advance(); // Pular aspas finais

    return Token(
      type: TokenType.string,
      raw: input.substring(start, _position),
      span: _makeSpan(start, _position),
      value: buffer.toString(),
    );
  }

  Token _readComment() {
    final start = _position;

    while (!_isAtEnd() && _peek() != '\n') {
      _advance();
    }

    return Token(
      type: TokenType.comment,
      raw: input.substring(start, _position),
      span: _makeSpan(start, _position),
    );
  }

  void _skipWhitespace() {
    while (!_isAtEnd()) {
      final char = _peek();
      if (char == ' ' || char == '\t' || char == '\r') {
        _advance();
      } else if (char == '\n') {
        _advance();
        _line++;
        _column = 0;
      } else {
        break;
      }
    }
  }

  String _peek([int offset = 0]) {
    final pos = _position + offset;
    if (pos >= input.length) return '\0';
    return input[pos];
  }

  String _peekNext() => _peek(1);

  void _advance([int count = 1]) {
    for (var i = 0; i < count; i++) {
      if (_position < input.length) {
        _position++;
        _column++;
      }
    }
  }

  bool _isAtEnd() => _position >= input.length;

  bool _isDigit(String char) {
    if (char.isEmpty || char == '\0') return false;
    final code = char.codeUnitAt(0);
    return code >= 48 && code <= 57; // '0' to '9'
  }

  bool _isAlpha(String char) {
    if (char.isEmpty || char == '\0') return false;
    final code = char.codeUnitAt(0);
    return (code >= 65 && code <= 90) || // 'A' to 'Z'
        (code >= 97 && code <= 122); // 'a' to 'z'
  }

  bool _isAlphaNumeric(String char) => _isAlpha(char) || _isDigit(char);

  Token _makeToken(TokenType type, String raw, int start) {
    return Token(type: type, raw: raw, span: _makeSpan(start, _position));
  }

  SourceSpan _makeSpan(int start, int end) {
    return SourceSpan(
      startIndex: start,
      endIndex: end,
      startLine: _line,
      startColumn: start - (_position - _column),
      endLine: _line,
      endColumn: end - (_position - _column),
    );
  }
}
