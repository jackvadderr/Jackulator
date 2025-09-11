
/// Defines the contract for a binary operation (takes two operands).
abstract class BinaryOperation {
  double execute(double operand1, double operand2);
}

/// Defines the contract for a unary operation (takes one operand).
abstract class UnaryOperation {
  double execute(double operand);
}
