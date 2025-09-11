
import 'dart:math';
import './operation.dart';

// --- Scientific Unary Operations ---

/// Calculates the square root of a number.
class SqrtOperation implements UnaryOperation {
  @override
  double execute(double operand) {
    if (operand < 0) {
      // In basic scientific calculators, sqrt of a negative number is an error.
      return double.nan; 
    }
    return sqrt(operand);
  }
}

/// Calculates the square of a number (x²).
class PowerOfTwoOperation implements UnaryOperation {
  @override
  double execute(double operand) {
    return pow(operand, 2).toDouble();
  }
}

/// Calculates the sine of a number (assuming the input is in radians).
class SinOperation implements UnaryOperation {
  @override
  double execute(double operand) {
    // Note: Flutter's sin function takes radians. We might need a DEG/RAD toggle later.
    return sin(operand);
  }
}

/// Calculates the cosine of a number (assuming the input is in radians).
class CosOperation implements UnaryOperation {
  @override
  double execute(double operand) {
    return cos(operand);
  }
}

/// Calculates the tangent of a number (assuming the input is in radians).
class TanOperation implements UnaryOperation {
  @override
  double execute(double operand) {
    return tan(operand);
  }
}

/// Calculates the natural logarithm of a number.
class NaturalLogOperation implements UnaryOperation {
  @override
  double execute(double operand) {
    if (operand <= 0) {
      return double.nan; // Log of non-positive is undefined
    }
    return log(operand);
  }
}

/// Calculates the base-10 logarithm of a number.
class Base10LogOperation implements UnaryOperation {
  @override
  double execute(double operand) {
    if (operand <= 0) {
      return double.nan; // Log of non-positive is undefined
    }
    // Dart's log gives natural log, so we use the change of base formula.
    return log(operand) / log(10);
  }
}
