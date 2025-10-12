import 'dart:math' as math;

import 'values.dart';

/// Modo de ângulo para funções trigonométricas
enum AngleMode { degrees, radians }

/// Modo da calculadora
enum EngineMode { scientific, programmer, statistics }

/// Descritor de função
class FunctionDescriptor {
  final String name;
  final int minArity;
  final int? maxArity; // null = varargs
  final Value Function(List<Value>, EvaluationContext) implementation;
  final String description;

  const FunctionDescriptor({
    required this.name,
    required this.minArity,
    this.maxArity,
    required this.implementation,
    this.description = '',
  });

  bool acceptsArity(int arity) {
    if (arity < minArity) return false;
    if (maxArity == null) return true;
    return arity <= maxArity!;
  }
}

/// Contexto de avaliação
class EvaluationContext {
  final Map<String, Value> _variables;
  final Map<String, Value> _memoryRegisters;
  final Map<String, FunctionDescriptor> _functions;
  final Map<String, num> _constants;

  final AngleMode angleMode;
  final int precision;
  final EngineMode engineMode;

  // Limites de segurança
  final int maxRecursionDepth;
  final int maxIterations;
  final Duration timeout;
  final int maxMatrixSize;

  EvaluationContext({
    Map<String, Value>? variables,
    Map<String, Value>? memoryRegisters,
    Map<String, FunctionDescriptor>? functions,
    Map<String, num>? constants,
    this.angleMode = AngleMode.radians,
    this.precision = 10,
    this.engineMode = EngineMode.scientific,
    this.maxRecursionDepth = 100,
    this.maxIterations = 10000,
    this.timeout = const Duration(seconds: 5),
    this.maxMatrixSize = 1000,
  }) : _variables = variables ?? {},
       _memoryRegisters = memoryRegisters ?? _defaultMemory(),
       _functions = functions ?? {},
       _constants = constants ?? _defaultConstants() {
    _initializeDefaultFunctions();
  }

  static Map<String, Value> _defaultMemory() {
    return {
      'ANS': NumberValue(0),
      'M0': NumberValue(0),
      'M1': NumberValue(0),
      'M2': NumberValue(0),
      'M3': NumberValue(0),
      'M4': NumberValue(0),
      'M5': NumberValue(0),
      'M6': NumberValue(0),
      'M7': NumberValue(0),
      'M8': NumberValue(0),
      'M9': NumberValue(0),
    };
  }

  static Map<String, num> _defaultConstants() {
    return {
      'pi': math.pi,
      'e': math.e,
      'phi': 1.618033988749895, // Golden ratio
    };
  }

  void _initializeDefaultFunctions() {
    // Funções trigonométricas
    _functions['sin'] = FunctionDescriptor(
      name: 'sin',
      minArity: 1,
      maxArity: 1,
      implementation: (args, ctx) {
        final x = _toNumber(args[0]);
        final rad = ctx.angleMode == AngleMode.degrees ? x * math.pi / 180 : x;
        return NumberValue(math.sin(rad));
      },
      description: 'Sine function',
    );

    _functions['cos'] = FunctionDescriptor(
      name: 'cos',
      minArity: 1,
      maxArity: 1,
      implementation: (args, ctx) {
        final x = _toNumber(args[0]);
        final rad = ctx.angleMode == AngleMode.degrees ? x * math.pi / 180 : x;
        return NumberValue(math.cos(rad));
      },
      description: 'Cosine function',
    );

    _functions['tan'] = FunctionDescriptor(
      name: 'tan',
      minArity: 1,
      maxArity: 1,
      implementation: (args, ctx) {
        final x = _toNumber(args[0]);
        final rad = ctx.angleMode == AngleMode.degrees ? x * math.pi / 180 : x;
        return NumberValue(math.tan(rad));
      },
      description: 'Tangent function',
    );

    _functions['asin'] = FunctionDescriptor(
      name: 'asin',
      minArity: 1,
      maxArity: 1,
      implementation: (args, ctx) {
        final x = _toNumber(args[0]);
        final result = math.asin(x);
        return NumberValue(
          ctx.angleMode == AngleMode.degrees ? result * 180 / math.pi : result,
        );
      },
      description: 'Arcsine function',
    );

    _functions['acos'] = FunctionDescriptor(
      name: 'acos',
      minArity: 1,
      maxArity: 1,
      implementation: (args, ctx) {
        final x = _toNumber(args[0]);
        final result = math.acos(x);
        return NumberValue(
          ctx.angleMode == AngleMode.degrees ? result * 180 / math.pi : result,
        );
      },
      description: 'Arccosine function',
    );

    _functions['atan'] = FunctionDescriptor(
      name: 'atan',
      minArity: 1,
      maxArity: 1,
      implementation: (args, ctx) {
        final x = _toNumber(args[0]);
        final result = math.atan(x);
        return NumberValue(
          ctx.angleMode == AngleMode.degrees ? result * 180 / math.pi : result,
        );
      },
      description: 'Arctangent function',
    );

    // Funções matemáticas
    _functions['sqrt'] = FunctionDescriptor(
      name: 'sqrt',
      minArity: 1,
      maxArity: 1,
      implementation: (args, ctx) {
        final x = _toNumber(args[0]);
        if (x < 0 && ctx.engineMode != EngineMode.scientific) {
          return ComplexValue(0, math.sqrt(-x));
        }
        return NumberValue(math.sqrt(x));
      },
      description: 'Square root',
    );

    _functions['ln'] = FunctionDescriptor(
      name: 'ln',
      minArity: 1,
      maxArity: 1,
      implementation: (args, ctx) {
        final x = _toNumber(args[0]);
        return NumberValue(math.log(x));
      },
      description: 'Natural logarithm',
    );

    _functions['log'] = FunctionDescriptor(
      name: 'log',
      minArity: 1,
      maxArity: 2,
      implementation: (args, ctx) {
        final x = _toNumber(args[0]);
        if (args.length == 1) {
          return NumberValue(math.log(x) / math.ln10);
        }
        final base = _toNumber(args[1]);
        return NumberValue(math.log(x) / math.log(base));
      },
      description: 'Logarithm (base 10 or custom)',
    );

    _functions['exp'] = FunctionDescriptor(
      name: 'exp',
      minArity: 1,
      maxArity: 1,
      implementation: (args, ctx) {
        final x = _toNumber(args[0]);
        return NumberValue(math.exp(x));
      },
      description: 'Exponential (e^x)',
    );

    _functions['abs'] = FunctionDescriptor(
      name: 'abs',
      minArity: 1,
      maxArity: 1,
      implementation: (args, ctx) {
        final x = _toNumber(args[0]);
        return NumberValue(x.abs());
      },
      description: 'Absolute value',
    );

    _functions['floor'] = FunctionDescriptor(
      name: 'floor',
      minArity: 1,
      maxArity: 1,
      implementation: (args, ctx) {
        final x = _toNumber(args[0]);
        return IntegerValue(x.floor());
      },
      description: 'Floor function',
    );

    _functions['ceil'] = FunctionDescriptor(
      name: 'ceil',
      minArity: 1,
      maxArity: 1,
      implementation: (args, ctx) {
        final x = _toNumber(args[0]);
        return IntegerValue(x.ceil());
      },
      description: 'Ceiling function',
    );

    _functions['round'] = FunctionDescriptor(
      name: 'round',
      minArity: 1,
      maxArity: 1,
      implementation: (args, ctx) {
        final x = _toNumber(args[0]);
        return IntegerValue(x.round());
      },
      description: 'Round to nearest integer',
    );

    _functions['min'] = FunctionDescriptor(
      name: 'min',
      minArity: 2,
      maxArity: null, // varargs
      implementation: (args, ctx) {
        final nums = args.map(_toNumber).toList();
        return NumberValue(nums.reduce(math.min));
      },
      description: 'Minimum value',
    );

    _functions['max'] = FunctionDescriptor(
      name: 'max',
      minArity: 2,
      maxArity: null, // varargs
      implementation: (args, ctx) {
        final nums = args.map(_toNumber).toList();
        return NumberValue(nums.reduce(math.max));
      },
      description: 'Maximum value',
    );
  }

  static num _toNumber(Value value) {
    if (value is NumberValue) return value.rawValue;
    if (value is IntegerValue) return value.rawValue;
    if (value is RationalValue) return value.rawValue;
    throw ArgumentError('Cannot convert $value to number');
  }

  // Variáveis
  Value? getVariable(String name) => _variables[name];
  void setVariable(String name, Value value) => _variables[name] = value;
  bool hasVariable(String name) => _variables.containsKey(name);
  Map<String, Value> get variables => Map.unmodifiable(_variables);

  // Constantes
  num? getConstant(String name) => _constants[name.toLowerCase()];
  bool hasConstant(String name) => _constants.containsKey(name.toLowerCase());

  // Memória
  Value? getMemory(String name) => _memoryRegisters[name];
  void setMemory(String name, Value value) => _memoryRegisters[name] = value;
  void addToMemory(String name, Value delta) {
    final current = _memoryRegisters[name] ?? NumberValue(0);
    if (current is NumberValue && delta is NumberValue) {
      _memoryRegisters[name] = NumberValue(current.rawValue + delta.rawValue);
    }
  }

  void clearMemory(String name) => _memoryRegisters[name] = NumberValue(0);
  void clearAllMemory() {
    for (final key in _memoryRegisters.keys) {
      _memoryRegisters[key] = NumberValue(0);
    }
  }

  Map<String, Value> get memory => Map.unmodifiable(_memoryRegisters);

  // Funções
  FunctionDescriptor? getFunction(String name) =>
      _functions[name.toLowerCase()];
  void defineFunction(String name, FunctionDescriptor descriptor) {
    _functions[name.toLowerCase()] = descriptor;
  }

  bool hasFunction(String name) => _functions.containsKey(name.toLowerCase());

  // Hash do contexto para memoização
  int get hashCode {
    var hash = 0;
    hash = hash * 31 + angleMode.hashCode;
    hash = hash * 31 + precision.hashCode;
    hash = hash * 31 + _variables.hashCode;
    hash = hash * 31 + _memoryRegisters.hashCode;
    return hash;
  }

  // Copiar contexto
  EvaluationContext copyWith({
    Map<String, Value>? variables,
    Map<String, Value>? memoryRegisters,
    AngleMode? angleMode,
    int? precision,
    EngineMode? engineMode,
  }) {
    return EvaluationContext(
      variables: variables ?? Map.from(_variables),
      memoryRegisters: memoryRegisters ?? Map.from(_memoryRegisters),
      functions: Map.from(_functions),
      constants: Map.from(_constants),
      angleMode: angleMode ?? this.angleMode,
      precision: precision ?? this.precision,
      engineMode: engineMode ?? this.engineMode,
      maxRecursionDepth: maxRecursionDepth,
      maxIterations: maxIterations,
      timeout: timeout,
      maxMatrixSize: maxMatrixSize,
    );
  }
}
