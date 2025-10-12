import 'ast.dart';
import 'context.dart';
import 'errors.dart';
import 'evaluator.dart';
import 'history.dart';
import 'lexer.dart';
import 'parser.dart' as p;
import 'values.dart';

/// API principal da calculadora
class CalculatorEngine {
  EvaluationContext
  context; // tornamos mutável para permitir atualizar angleMode
  final History history;
  final LexerConfig lexerConfig;
  final p.ParserConfig parserConfig;

  CalculatorEngine({
    EvaluationContext? context,
    History? history,
    this.lexerConfig = const LexerConfig(),
    this.parserConfig = const p.ParserConfig(),
  }) : context = context ?? EvaluationContext(),
       history = history ?? History();

  /// Parse uma expressão e retorna o resultado
  p.ParseResult parse(String expression) {
    try {
      final lexer = Lexer(expression, config: lexerConfig);
      final tokens = lexer.tokenize();
      final parser = p.Parser(tokens, config: parserConfig);
      return parser.parse();
    } catch (e) {
      if (e is LexerError) {
        return p.ParseResult(
          tokens: [],
          errors: [
            p.ParseError(
              message: e.message,
              posStart: e.position,
              posEnd: e.position + 1,
            ),
          ],
        );
      }
      rethrow;
    }
  }

  /// Avalia uma expressão (parse + evaluate)
  EvaluationResult evaluate(String expression) {
    try {
      // Parse
      final parseResult = parse(expression);

      if (parseResult.hasErrors) {
        return EvaluationResult(
          error: EvaluationError(
            message: parseResult.errors.first.message,
            code: 'PARSE_ERROR',
          ),
        );
      }

      if (parseResult.ast == null) {
        return EvaluationResult(
          error: EvaluationError(
            message: 'No expression to evaluate',
            code: 'EMPTY_EXPRESSION',
          ),
        );
      }

      // Evaluate
      final result = evaluateAst(parseResult.ast!);

      // Adicionar ao histórico
      _addToHistory(expression, parseResult.ast, result);

      return result;
    } catch (e) {
      return EvaluationResult(
        error: EvaluationError(message: e.toString(), code: 'UNKNOWN_ERROR'),
      );
    }
  }

  /// Avalia uma AST já parseada
  EvaluationResult evaluateAst(AstNode ast) {
    final evaluator = Evaluator(context);
    final result = evaluator.evaluate(ast);
    // Atualizar ANS em qualquer avaliação bem-sucedida
    if (result.success && result.value != null) {
      context.setMemory('ANS', result.value!);
    }
    return result;
  }

  /// Atribui um valor a uma variável
  void assign(String name, Value value) {
    context.setVariable(name, value);
  }

  /// Define uma função customizada
  void defineFunction(String name, FunctionDescriptor descriptor) {
    context.defineFunction(name, descriptor);
  }

  /// Lista todas as variáveis
  Map<String, Value> listVariables() {
    return context.variables;
  }

  /// Lista o histórico
  List<HistoryEntry> listHistory({int? limit, HistoryFilter? filter}) {
    return history.list(limit: limit, filter: filter);
  }

  /// Limpa o histórico
  void clearHistory({bool includePinned = false}) {
    history.clear(includePinned: includePinned);
  }

  /// Obtém o último resultado (ANS)
  Value? getLastAnswer() {
    return context.getMemory('ANS');
  }

  /// Operações de memória
  Value? getMemory(String name) => context.getMemory(name);
  void setMemory(String name, Value value) => context.setMemory(name, value);
  void addToMemory(String name, Value delta) =>
      context.addToMemory(name, delta);
  void clearMemory(String name) => context.clearMemory(name);
  void clearAllMemory() => context.clearAllMemory();

  /// Muda o modo de ângulo
  void setAngleMode(AngleMode mode) {
    // Atualiza o contexto para refletir o novo modo de ângulo
    context = context.copyWith(angleMode: mode);
  }

  /// Muda o modo da engine
  void setEngineMode(EngineMode mode) {
    // Atualiza o contexto para refletir o novo modo da engine
    context = context.copyWith(engineMode: mode);
  }

  void _addToHistory(String expression, AstNode? ast, EvaluationResult result) {
    final entry = HistoryEntry(
      expressionRaw: expression,
      astSerialized: ast?.toString(),
      resultSerialized: result.value?.toString(),
      resultType: result.type,
      success: result.success,
      error: result.error,
    );

    history.add(entry);
  }

  /// Exporta o histórico para JSON
  List<Map<String, dynamic>> exportHistory() {
    return history.toJson();
  }

  /// Importa o histórico de JSON
  void importHistory(List<dynamic> json) {
    history.fromJson(json);
  }

  /// Exporta variáveis para JSON
  Map<String, dynamic> exportVariables() {
    return context.variables.map(
      (key, value) => MapEntry(key, value.toString()),
    );
  }

  /// Importa variáveis de JSON (simplificado)
  void importVariables(Map<String, dynamic> json) {
    for (final entry in json.entries) {
      final value = num.tryParse(entry.value.toString());
      if (value != null) {
        context.setVariable(entry.key, NumberValue(value));
      } else {
        context.setVariable(entry.key, StringValue(entry.value.toString()));
      }
    }
  }
}
