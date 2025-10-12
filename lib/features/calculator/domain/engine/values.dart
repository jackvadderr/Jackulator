/// Tipos de valores suportados
enum ValueType {
  number,
  integer,
  rational,
  complex,
  boolean,
  string,
  matrix,
  vector,
  unitValue,
}

/// Valor base
abstract class Value {
  ValueType get type;
  dynamic get rawValue;

  @override
  String toString();
}

/// Valor numérico (float/double)
class NumberValue implements Value {
  @override
  final ValueType type = ValueType.number;

  @override
  final num rawValue;

  const NumberValue(this.rawValue);

  @override
  String toString() => rawValue.toString();
}

/// Valor inteiro
class IntegerValue implements Value {
  @override
  final ValueType type = ValueType.integer;

  @override
  final int rawValue;

  const IntegerValue(this.rawValue);

  @override
  String toString() => rawValue.toString();
}

/// Valor racional (fração p/q)
class RationalValue implements Value {
  @override
  final ValueType type = ValueType.rational;

  final int numerator;
  final int denominator;

  RationalValue(this.numerator, this.denominator) {
    if (denominator == 0) {
      throw ArgumentError('Denominator cannot be zero');
    }
  }

  @override
  dynamic get rawValue => numerator / denominator;

  /// Simplifica a fração
  RationalValue simplify() {
    final g = _gcd(numerator.abs(), denominator.abs());
    return RationalValue(numerator ~/ g, denominator ~/ g);
  }

  int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  @override
  String toString() => '$numerator/$denominator';
}

/// Valor complexo (a + bi)
class ComplexValue implements Value {
  @override
  final ValueType type = ValueType.complex;

  final num real;
  final num imaginary;

  const ComplexValue(this.real, this.imaginary);

  @override
  dynamic get rawValue => this;

  num get magnitude => (real * real + imaginary * imaginary);

  @override
  String toString() {
    if (imaginary == 0) return real.toString();
    if (real == 0) return '${imaginary}i';
    final sign = imaginary >= 0 ? '+' : '-';
    return '$real $sign ${imaginary.abs()}i';
  }
}

/// Valor booleano
class BooleanValue implements Value {
  @override
  final ValueType type = ValueType.boolean;

  @override
  final bool rawValue;

  const BooleanValue(this.rawValue);

  @override
  String toString() => rawValue.toString();
}

/// Valor de string
class StringValue implements Value {
  @override
  final ValueType type = ValueType.string;

  @override
  final String rawValue;

  const StringValue(this.rawValue);

  @override
  String toString() => rawValue;
}

/// Valor com unidade (para conversões)
class UnitValue implements Value {
  @override
  final ValueType type = ValueType.unitValue;

  final num value;
  final String unit;

  const UnitValue(this.value, this.unit);

  @override
  dynamic get rawValue => value;

  @override
  String toString() => '$value $unit';
}

/// Vetor
class VectorValue implements Value {
  @override
  final ValueType type = ValueType.vector;

  final List<num> elements;

  const VectorValue(this.elements);

  @override
  List<num> get rawValue => elements;

  int get length => elements.length;

  @override
  String toString() => '[${elements.join(", ")}]';
}

/// Matriz
class MatrixValue implements Value {
  @override
  final ValueType type = ValueType.matrix;

  final List<List<num>> elements;

  const MatrixValue(this.elements);

  @override
  List<List<num>> get rawValue => elements;

  int get rows => elements.length;
  int get cols => elements.isEmpty ? 0 : elements[0].length;

  @override
  String toString() {
    final buffer = StringBuffer('[');
    for (var i = 0; i < elements.length; i++) {
      if (i > 0) buffer.write(', ');
      buffer.write('[${elements[i].join(", ")}]');
    }
    buffer.write(']');
    return buffer.toString();
  }
}
