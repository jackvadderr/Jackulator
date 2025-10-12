import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/features/calculator/domain/calculator_engine.dart';

enum CalculatorMode { basic, scientific }

class _CalculatorState {
  final String expression;
  final String output;
  _CalculatorState({required this.expression, required this.output});
}

class CalculatorProvider extends ChangeNotifier {
  final CalculatorEngine _engine;
  String _expression = '';
  String _output = '0';
  double _memoryValue = 0;
  List<String> _calculationHistory = [];
  CalculatorMode _mode = CalculatorMode.basic;
  bool _justEvaluated = false;

  List<_CalculatorState> _stateHistory = [];
  int _currentStateIndex = -1;

  // operador atualmente ativo (ex.: '+', '-', '*', '/'), usado pela UI para marcar botão selecionado
  String? _activeOperator = null;
  String? get activeOperator => _activeOperator;

  // --- Dicionário de funções e constantes (apenas rótulos) ---
  // O processamento real está no CalculatorEngine (camada de domínio)

  // --- Mapa de botões para nomes de função ---
  static const _scientificLabelToFunction = {
    '√': 'sqrt',
    'sin': 'sin',
    'cos': 'cos',
    'tan': 'tan',
    'ln': 'ln',
    'log': 'log',
    'x²': 'pow',
  };

  CalculatorProvider({CalculatorEngine? engine})
    : _engine = engine ?? const CalculatorEngine() {
    _saveState();
    // garante que a UI receba o estado inicial logo após o Provider ser criado (evita race em testes)
    Future.microtask(() => notifyListeners());
  }

  // --- Getters ---
  // retorno apenas da expressão (secundária) — a UI principal deve exibir formattedOutput
  String get displayExpression {
    return _expression.replaceAll('*', '×').replaceAll('/', '÷');
  }

  String get formattedOutput {
    // garantia: sempre retornar string amigável (nunca null)
    if (_output.contains('e'))
      return _output; // Não formatar notação científica
    if (_output == 'Error') return 'Error';
    final formatter = NumberFormat.decimalPattern('en_US');
    try {
      final number = double.parse(_output.replaceAll(',', ''));
      return formatter.format(number);
    } catch (e) {
      return _output;
    }
  }

  bool get isMemorySet => _memoryValue != 0;
  String get clearButtonLabel =>
      (_output == '0' && _expression.isEmpty && !_justEvaluated) ? 'AC' : 'C';
  List<String> get calculationHistory => List.unmodifiable(_calculationHistory);
  bool get canUndo => _currentStateIndex > 0;
  bool get canRedo => _currentStateIndex < _stateHistory.length - 1;
  CalculatorMode get mode => _mode;

  // --- Ações Principais ---
  void setMode(CalculatorMode newMode) {
    if (_mode != newMode) {
      _resetState(fullReset: true);
      _mode = newMode;
      notifyListeners();
    }
  }

  void onButtonPressed(String value) {
    if ('0123456789.'.contains(value)) {
      _handleNumber(value);
    } else if (['+', '-', '×', '÷', '*', '/'].contains(value)) {
      _handleOperator(value.replaceAll('×', '*').replaceAll('÷', '/'));
    } else if (['(', ')'].contains(value)) {
      _handleParentheses(value);
    } else if (_scientificLabelToFunction.containsKey(value)) {
      _handleScientificFunction(value);
    } else if (value == '%') {
      _handlePercentage();
    } else if (value == '±') {
      _handleSign();
    } else if (value == '=') {
      _handleEquals();
    } else if (value == 'C' || value == 'AC') {
      _handleClear();
    } else if (value.startsWith('M')) {
      _handleMemory(value);
    }

    if (!value.startsWith('M')) {
      _saveState();
    }
    notifyListeners();
  }

  void undo() {
    if (canUndo) {
      _loadState(_stateHistory[--_currentStateIndex]);
      notifyListeners();
    }
  }

  void redo() {
    if (canRedo) {
      _loadState(_stateHistory[++_currentStateIndex]);
      notifyListeners();
    }
  }

  void backspace() {
    if (_justEvaluated || _output == 'Error') return;
    if (_output.length > 1)
      _output = _output.substring(0, _output.length - 1);
    else
      _output = '0';
    _saveState();
    notifyListeners();
  }

  // --- Gerenciamento de Estado ---
  void _saveState() {
    if (_currentStateIndex < _stateHistory.length - 1) {
      _stateHistory = _stateHistory.sublist(0, _currentStateIndex + 1);
    }
    _stateHistory.add(
      _CalculatorState(expression: _expression, output: _output),
    );
    _currentStateIndex = _stateHistory.length - 1;
  }

  void _loadState(_CalculatorState state) {
    _expression = state.expression;
    _output = state.output;
    _justEvaluated = false;

    // inferir operador ativo pelo último caractere da expressão se for operador
    if (_expression.isNotEmpty) {
      final t = _expression.trim();
      final last = t.isNotEmpty ? t.substring(t.length - 1) : '';
      if (['+', '-', '*', '/'].contains(last)) {
        _activeOperator = last;
      } else {
        _activeOperator = null;
      }
    } else {
      _activeOperator = null;
    }

    notifyListeners();
  }

  // --- Handlers dos Botões (Lógica Corrigida) ---
  void _handleNumber(String value) {
    if (_justEvaluated) {
      _expression = '';
      _output = '0';
      _justEvaluated = false;
      _activeOperator = null;
    }
    if (_output == '0' && value != '.')
      _output = value;
    else if (value == '.' && _output.contains('.'))
      return;
    else
      _output += value;
  }

  void _handleOperator(String op) {
    if (_output == 'Error') return;

    if (_justEvaluated) {
      _expression = _output;
      _justEvaluated = false;
    } else {
      if (_output.isNotEmpty && _output != '0' && _output != 'Error') {
        _expression += _output;
      }
    }

    if (_expression.isNotEmpty) {
      final lastChar = _expression.substring(_expression.length - 1);
      if (['+', '-', '*', '/'].contains(lastChar)) {
        _expression = _expression.substring(0, _expression.length - 1) + op;
      } else {
        _expression += op;
      }
    } else {
      if (op == '-') {
        _output = '-';
        _activeOperator = '-';
        notifyListeners();
        return;
      } else {
        _expression = '0' + op;
      }
    }

    _activeOperator = op;
    _output = '0';
  }

  void _handleParentheses(String p) {
    if (_justEvaluated) {
      _expression = '';
      _output = '0';
      _justEvaluated = false;
      _activeOperator = null;
    }

    if (p == '(') {
      if (_output != '0' && _output != 'Error') {
        _expression += _output + '*';
        _output = '0';
      }
      _expression += '(';
    } else {
      if (_output != '0' && _output != 'Error') {
        _expression += _output;
      }
      _expression += ')';
      _output = '0';
    }
  }

  void _handleScientificFunction(String label) {
    if (_justEvaluated) {
      _expression = '';
      _output = '0';
      _justEvaluated = false;
      _activeOperator = null;
    }
    final funcName = _scientificLabelToFunction[label]!;

    if (label == 'x²') {
      if (_output != '0' && _output != 'Error') {
        _expression += '$funcName($_output,2)';
        _output = '0';
      } else {
        _expression += '$funcName(';
      }
      return;
    }

    if (_output != '0' && _output != 'Error') {
      _expression += _output + '*';
      _output = '0';
    }
    _expression += '$funcName(';
  }

  void _handleEquals() {
    if (_output == 'Error') return;

    if (_output != '0' && _output != 'Error') {
      if (!(_expression.isNotEmpty &&
          _expression.substring(_expression.length - 1) == ')')) {
        _expression += _output;
      }
    }

    if (_expression.isEmpty) return;

    try {
      String finalExpression = _expression;
      final openParen = '('.allMatches(finalExpression).length;
      final closeParen = ')'.allMatches(finalExpression).length;
      if (openParen > closeParen) {
        finalExpression += List.filled(openParen - closeParen, ')').join();
      }

      final num? resultNum = _engine.evaluate(finalExpression);
      if (resultNum == null || resultNum.isNaN || resultNum.isInfinite) {
        throw StateError('Invalid evaluation');
      }

      final displayExpr = finalExpression
          .replaceAll('*', '×')
          .replaceAll('/', '÷');

      final formattedResult = _formatResult(resultNum);

      _calculationHistory.add('$displayExpr = $formattedResult');
      _output = formattedResult;
      _expression = '';
      _justEvaluated = true;
      _activeOperator = null;
      notifyListeners();
    } catch (e) {
      _output = 'Error';
      _expression = '';
      _justEvaluated = false;
      _activeOperator = null;
      notifyListeners();
    }
  }

  void _handlePercentage() {
    if (_output == 'Error') return;
    final val = (double.tryParse(_output.replaceAll(',', '')) ?? 0) / 100;
    _output = _formatResult(val);
    _justEvaluated = true;
    notifyListeners();
  }

  void _handleSign() {
    if (_output == '0' || _output == 'Error') return;
    if (_output.startsWith('-'))
      _output = _output.substring(1);
    else
      _output = '-' + _output;
    notifyListeners();
  }

  void _handleClear() {
    if (clearButtonLabel == 'AC') {
      _resetState(fullReset: true);
    } else {
      _output = '0';
      if (_justEvaluated) {
        _resetState(fullReset: true);
      }
    }
    notifyListeners();
  }

  void _resetState({bool fullReset = false}) {
    _expression = '';
    _output = '0';
    _justEvaluated = false;
    _activeOperator = null;
    if (fullReset) {
      _stateHistory = [];
      _currentStateIndex = -1;
      _saveState();
    }
  }

  void _handleMemory(String value) {
    final currentOutput = double.tryParse(_output.replaceAll(',', '')) ?? 0;
    switch (value) {
      case 'MC':
        _memoryValue = 0;
        break;
      case 'MR':
        _output = _formatResult(_memoryValue);
        _justEvaluated = true;
        break;
      case 'M+':
        _memoryValue += currentOutput;
        break;
      case 'M-':
        _memoryValue -= currentOutput;
        break;
      case 'MS':
        _memoryValue = currentOutput;
        break;
    }
    notifyListeners();
  }

  String _formatResult(num result) {
    if (result.isNaN || result.isInfinite) return 'Error';
    if (result.abs() > 9999999999 ||
        (result.abs() < 0.0000001 && result != 0)) {
      return result.toStringAsExponential(7);
    }
    if (result is double && result.truncateToDouble() == result)
      return result.truncate().toString();
    if (result is int) return result.toString();
    String formatted = result.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '');
    return formatted.endsWith('.')
        ? formatted.substring(0, formatted.length - 1)
        : formatted;
  }
}
