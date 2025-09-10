
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalculatorProvider extends ChangeNotifier {
  String _output = '0';
  double? _firstOperand;
  String? _operator;
  bool _isWaitingForSecondOperand = false;
  double _memoryValue = 0; // Restored memory value
  
  // State for the AC/C button
  bool _isFreshState = true;

  // --- Getters ---
  String get activeOperator => _operator ?? '';
  bool get isMemorySet => _memoryValue != 0; // Restored memory check

  // Determines the label for the clear button
  String get clearButtonLabel => _isFreshState || _output == 'Error' ? 'AC' : 'C';

  String get formattedOutput {
    if (_output == 'Error') return 'Error';
    final formatter = NumberFormat.decimalPattern('en_US');
    try {
      final number = double.parse(_output.replaceAll(',', ''));
      return formatter.format(number);
    } catch (e) {
      return _output;
    }
  }

  String get expressionString {
    if (_operator != null && _firstOperand != null) {
      final formatter = NumberFormat.decimalPattern('en_US');
      final firstOpFormatted = formatter.format(_firstOperand);

      if (_isWaitingForSecondOperand) {
        return '$firstOpFormatted $_operator';
      }
      // When typing the second operand, show the full expression
      return '$firstOpFormatted $_operator $formattedOutput';
    }
    return '';
  }

  void onButtonPressed(String value) {
    if ('0123456789.'.contains(value)) {
      _handleNumber(value);
    } else if ('+' == value || '-' == value || '×' == value || '÷' == value) {
      _handleOperator(value);
    } else if ('=' == value) {
      _handleEquals();
    } else if (value.contains('C')) { // Unified clear button and Memory Clear
      if(value == 'AC' || value == 'C'){
        _handleClear();
      } else if (value == 'MC'){
        _handleMemoryClear();
      }
    } else if ('%' == value) {
      _handlePercentage();
    } else if ('±' == value) {
      _handleSign();
    } else if (value.startsWith('M')) { // Memory functions
      if (value == 'MR') _handleMemoryRecall();
      if (value == 'M+') _handleMemoryAdd();
      if (value == 'M-') _handleMemorySubtract();
      if (value == 'MS') _handleMemoryStore();
    }
    notifyListeners();
  }

  void _handleNumber(String value) {
    if (_output == 'Error') {
        _resetState();
    }
    if (_isWaitingForSecondOperand) {
      _output = value;
      _isWaitingForSecondOperand = false;
    } else {
      if (_output == '0' && value != '.') {
        _output = value;
      } else {
        if (value == '.' && _output.contains('.')) return;
        _output += value;
      }
    }
    _isFreshState = false; // User has started typing
  }

  void _handleOperator(String op) {
    if (_output == 'Error') return;
    final inputValue = double.tryParse(_output.replaceAll(',', '')) ?? 0;

    if (_operator != null && !_isWaitingForSecondOperand) {
      _calculate(inputValue);
    } else {
      _firstOperand = inputValue;
    }

    _operator = op;
    _isWaitingForSecondOperand = true;
  }

  void _calculate(double secondOperand) {
    if (_firstOperand == null || _operator == null) return;

    if (_operator == '÷' && secondOperand == 0) {
      _handleError();
      return;
    }

    double result = 0;
    switch (_operator) {
      case '+': result = _firstOperand! + secondOperand; break;
      case '-': result = _firstOperand! - secondOperand; break;
      case '×': result = _firstOperand! * secondOperand; break;
      case '÷': result = _firstOperand! / secondOperand; break;
    }

    _output = _formatResult(result);
    _firstOperand = result; // For chaining calculations
  }

  void _handleEquals() {
    if(_operator == null || _isWaitingForSecondOperand) return;
    final inputValue = double.tryParse(_output.replaceAll(',', '')) ?? 0;
    _calculate(inputValue);
    _operator = null; 
    _isFreshState = true; // After equals, we are in a fresh state
  }

  void _handleClear() {
    if (clearButtonLabel == 'AC') {
      _resetState();
    } else {
      _output = '0';
      _isFreshState = true; // After clearing an entry, it's a fresh state
    }
  }
  
  void _resetState(){
      _output = '0';
      _firstOperand = null;
      _operator = null;
      _isWaitingForSecondOperand = false;
      _isFreshState = true;
  }

  // --- Single Operand Functions ---
  void _applySingleOperandFunction(double Function(double) func) {
    if (_output == 'Error') return;
    var value = double.tryParse(_output.replaceAll(',', '')) ?? 0;
    final result = func(value);
    _output = _formatResult(result);
    notifyListeners(); // Update UI immediately after single op
  }

  void _handlePercentage() => _applySingleOperandFunction((v) => v / 100);

  void _handleSign() {
    if (_output != '0' && _output != 'Error') {
      _output.startsWith('-') ? _output = _output.substring(1) : _output = '-$_output';
    }
  }
  
  // --- Memory Handlers (Restored) ---
  void _handleMemoryClear() => _memoryValue = 0;
  void _handleMemoryRecall() {
    _output = _formatResult(_memoryValue);
    _isWaitingForSecondOperand = true;
  }
  void _handleMemoryAdd() => _memoryValue += double.tryParse(_output.replaceAll(',', '')) ?? 0;
  void _handleMemorySubtract() => _memoryValue -= double.tryParse(_output.replaceAll(',', '')) ?? 0;
  void _handleMemoryStore() => _memoryValue = double.tryParse(_output.replaceAll(',', '')) ?? 0;

  // --- Utility ---
  void _handleError() {
    _output = 'Error';
    _isFreshState = true;
  }
  
  String _formatResult(double result) {
    if (result.isNaN || result.isInfinite) return 'Error';
    if (result.truncateToDouble() == result) {
      return result.truncate().toString();
    } else {
      String formatted = result.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '');
      return formatted.endsWith('.') ? formatted.substring(0, formatted.length - 1) : formatted;
    }
  }

  void backspace() {
    if (_isWaitingForSecondOperand) return;
    if (_output.length > 1) {
      _output = _output.substring(0, _output.length - 1);
    } else {
      _output = '0';
    }
    if(_output == '0') _isFreshState = true;
    notifyListeners();
  }
}
