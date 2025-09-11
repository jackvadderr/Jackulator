
import './operation.dart';

class AddOperation implements BinaryOperation {
  @override
  double execute(double operand1, double operand2) => operand1 + operand2;
}

class SubtractOperation implements BinaryOperation {
  @override
  double execute(double operand1, double operand2) => operand1 - operand2;
}

class MultiplyOperation implements BinaryOperation {
  @override
  double execute(double operand1, double operand2) => operand1 * operand2;
}

class DivideOperation implements BinaryOperation {
  @override
  double execute(double operand1, double operand2) {
    if (operand2 == 0) {
      throw ArgumentError('Cannot divide by zero');
    }
    return operand1 / operand2;
  }
}
