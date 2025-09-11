
import './operation.dart';

class PercentageOperation implements UnaryOperation {
  @override
  double execute(double operand) => operand / 100;
}

class SignOperation implements UnaryOperation {
  @override
  double execute(double operand) => -operand;
}
