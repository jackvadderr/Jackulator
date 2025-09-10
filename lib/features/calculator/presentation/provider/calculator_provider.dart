
import '''package:flutter/cupertino.dart''';
import '''package:intl/intl.dart''';

class CalculatorProvider extends ChangeNotifier {
  String _output = '0';
  String _currentInput = '';
  String _operator = '';
  double _firstOperand = 0;

  String get output => _output;
  String get activeOperator => _operator;

  String get formattedOutput {
    final formatter = NumberFormat.decimalPattern('en_US');
    try {
      final number = double.parse(_output.replaceAll(',', ''));
      return formatter.format(number);
    } catch (e) {
      return _output;
    }
  }

  // New method to handle the backspace gesture
  void backspace() {
    if (_output == 'Error' || _operator.isNotEmpty && _currentInput.isEmpty) return;

    if (_output.length > 1) {
      _output = _output.substring(0, _output.length - 1);
    } else {
      _output = '0';
    }
    _currentInput = _output;
    notifyListeners();
  }

  void onButtonPressed(String value) {
    if ('0123456789.'.contains(value)) {
      _handleNumber(value);
    } else if ('+' == value || '-' == value || '×' == value || '÷' == value) {
      _handleOperator(value);
    } else if ('=' == value) {
      _handleEquals();
    } else if ('C' == value) {
      _handleClear();
    } else if ('%' == value) {
      _handlePercentage();
    } else if ('±' == value) {
      _handleSign();
    }
    notifyListeners();
  }

  void _handleNumber(String value) {
    if (_operator.isNotEmpty && _currentInput.isEmpty) {
       _output = value;
       _currentInput = value;
       return;
    }

    if (_output == '0' && value != '.' ) {
      _output = value;
    } else {
      if (value == '.' && _output.contains('.')) return;
      _output += value;
    }
    _currentInput = _output;
  }

  void _handleOperator(String op) {
    if (_currentInput.isNotEmpty) {
      _firstOperand = double.tryParse(_currentInput.replaceAll(',', '')) ?? 0;
    }
    _operator = op;
    _currentInput = '';
  }

  void _handleEquals() {
    if (_operator.isNotEmpty && _currentInput.isNotEmpty) {
      final double secondOperand = double.tryParse(_currentInput.replaceAll(',', '')) ?? 0;
      double result = 0;
      switch (_operator) {
        case '+':
          result = _firstOperand + secondOperand;
          break;
        case '-':
          result = _firstOperand - secondOperand;
          break;
        case '×':
          result = _firstOperand * secondOperand;
          break;
        case '÷':
          if (secondOperand != 0) {
            result = _firstOperand / secondOperand;
          } else {
            _output = 'Error';
            _operator = '';
            notifyListeners();
            return;
          }
          break;
      }
      _output = result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 4);
      _operator = '';
      _currentInput = _output;
    }
  }

  void _handleClear() {
    _output = '0';
    _currentInput = '';
    _operator = '';
    _firstOperand = 0;
  }

  void _handlePercentage() {
    if (_currentInput.isNotEmpty) {
      final double value = double.tryParse(_currentInput.replaceAll(',', '')) ?? 0;
      _output = (value / 100).toString();
      _currentInput = _output;
    }
  }

  void _handleSign() {
    if (_output != '0' && _currentInput.isNotEmpty) {
      if (_output.startsWith('-')) {
        _output = _output.substring(1);
      } else {
        _output = '-' + _output;
      }
      _currentInput = _output;
    }
  }
}
