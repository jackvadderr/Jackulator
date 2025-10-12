import 'package:flutter/material.dart';
import 'package:myapp/features/calculator/domain/calculator_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../adapter/engine_adapter.dart';
import '../input/commands.dart';
import '../input/editor.dart';
import '../input/editor_state.dart';
import '../normalize/normalizer.dart' as norm;
import '../presentation/ui_serializer.dart';

enum CalculatorMode { basic, scientific }

enum AngleUnit { degrees, radians }

enum NavTab { basic, advanced, scientific, settings, history }

class CalculatorProvider extends ChangeNotifier {
  final CalculatorEngine _engine;
  late final EngineAdapter _adapter;

  // Tokenized editor state for input layer
  final Editor _editor = Editor();
  EditorState _editorState = EditorState.empty();

  // Final evaluated result to display after '=' (null when typing)
  String? _result;
  final List<String> _calculationHistory = [];

  CalculatorMode _mode = CalculatorMode.basic;
  AngleUnit _angleUnit = AngleUnit.degrees;
  NavTab _navTab = NavTab.basic;

  // --- Scientific labels map ---
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
    : _engine = engine ?? CalculatorEngine() {
    _adapter = EngineAdapter(_engine);
    _engine.setAngleMode(
      _angleUnit == AngleUnit.degrees ? AngleMode.degrees : AngleMode.radians,
    );

    Future.microtask(() async {
      await _loadPrefs();
      notifyListeners();
    });
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tabIndex = prefs.getInt('nav_tab');
      if (tabIndex != null &&
          tabIndex >= 0 &&
          tabIndex < NavTab.values.length) {
        _navTab = NavTab.values[tabIndex];
        if (_navTab == NavTab.basic) {
          _mode = CalculatorMode.basic;
        } else if (_navTab == NavTab.scientific || _navTab == NavTab.advanced) {
          _mode = CalculatorMode.scientific;
        }
      }
    } catch (_) {}
  }

  // --- Live preview ---
  bool _livePreviewEnabled = false;
  void enableLivePreview(bool enabled) {
    if (_livePreviewEnabled != enabled) {
      _livePreviewEnabled = enabled;
      notifyListeners();
    }
  }

  bool get livePreviewEnabled => _livePreviewEnabled;

  String? get livePreviewValue {
    if (!_livePreviewEnabled) return null;
    try {
      return _adapter.tryPreview(_editorState, opts: norm.NormalizerOptions());
    } catch (_) {
      return null;
    }
  }

  void setDecimalSeparator(String sep) {
    if (sep != _editorState.decimalSeparator) {
      _editorState = _editorState.copyWith(decimalSeparator: sep);
      notifyListeners();
    }
  }

  // --- Getters for UI ---
  String get liveDisplayExpression => UiSerializer.serialize(_editorState);

  bool get hasResultForDisplay => _result != null;

  String get formattedOutput => _result ?? '0';

  String get angleUnitLabel => _angleUnit == AngleUnit.degrees ? 'DEG' : 'RAD';
  AngleUnit get angleUnit => _angleUnit;

  String get clearButtonLabel =>
      (_editorState.tokens.isEmpty && _result == null) ? 'AC' : 'C';

  List<String> get calculationHistory => List.unmodifiable(_calculationHistory);

  // Undo/Redo based on editor stacks
  bool get canUndo => _editorState.undoStack.isNotEmpty;
  bool get canRedo => _editorState.redoStack.isNotEmpty;

  CalculatorMode get mode => _mode;
  NavTab get navTab => _navTab;

  // Expor histórico rico da engine
  List<HistoryEntry> get engineHistory => _engine.listHistory();

  // --- Actions ---
  void setNavTab(NavTab tab) {
    if (_navTab != tab) {
      _navTab = tab;
      if (tab == NavTab.basic) {
        setMode(CalculatorMode.basic, silent: true);
      } else if (tab == NavTab.scientific) {
        setMode(CalculatorMode.scientific, silent: true);
      } else if (tab == NavTab.advanced) {
        setMode(CalculatorMode.scientific, silent: true);
      }
      SharedPreferences.getInstance().then((p) {
        p.setInt('nav_tab', _navTab.index);
      });
      notifyListeners();
    }
  }

  void clearEngineHistory({bool includePinned = false}) {
    _engine.clearHistory(includePinned: includePinned);
    notifyListeners();
  }

  void togglePinHistory(String id) {
    _engine.history.togglePin(id);
    notifyListeners();
  }

  void setMode(CalculatorMode newMode, {bool silent = false}) {
    if (_mode != newMode) {
      _resetAll();
      _mode = newMode;
      if (!silent) notifyListeners();
    }
  }

  void setAngleUnit(AngleUnit unit) {
    if (_angleUnit != unit) {
      _angleUnit = unit;
      _engine.setAngleMode(
        unit == AngleUnit.degrees ? AngleMode.degrees : AngleMode.radians,
      );
      notifyListeners();
    }
  }

  void toggleAngleUnit() {
    _angleUnit = _angleUnit == AngleUnit.degrees
        ? AngleUnit.radians
        : AngleUnit.degrees;
    _engine.setAngleMode(
      _angleUnit == AngleUnit.degrees ? AngleMode.degrees : AngleMode.radians,
    );
    notifyListeners();
  }

  void onButtonPressed(String value) {
    // If a result is showing, and the user starts typing a new entry, clear it
    bool willEdit = false;
    if (value == 'DEL' ||
        value == '.' ||
        value == '(' ||
        value == ')' ||
        value == '%')
      willEdit = true;
    if (!willEdit && '0123456789'.contains(value)) willEdit = true;
    if (!willEdit && ['+', '-', '×', '÷', '^', '\u00b1'].contains(value))
      willEdit = true;
    if (!willEdit && _scientificLabelToFunction.containsKey(value))
      willEdit = true;

    if (_result != null && willEdit && value != '\u00b1') {
      // Start a fresh expression after a completed result
      _editorState = EditorState.empty();
      _result = null;
    }

    // Map buttons to editor commands
    if (value == 'DEL') {
      _editorState = _editor.apply(_editorState, BackspaceCmd());
      notifyListeners();
      return;
    }
    if (value == 'AC' || value == 'C') {
      _handleClear();
      return;
    }
    if (value == '\u00b1') {
      _editorState = _editor.apply(_editorState, ToggleSignCmd());
      _result = null; // editing
      notifyListeners();
      return;
    }
    if (value == '%') {
      _editorState = _editor.apply(_editorState, InsertPercent());
      _result = null;
      notifyListeners();
      return;
    }
    if (value == '(') {
      _editorState = _editor.apply(_editorState, InsertParen(true));
      _result = null;
      notifyListeners();
      return;
    }
    if (value == ')') {
      _editorState = _editor.apply(_editorState, InsertParen(false));
      _result = null;
      notifyListeners();
      return;
    }
    if (value == '.') {
      _editorState = _editor.apply(_editorState, InsertDot());
      _result = null;
      notifyListeners();
      return;
    }
    if ('0123456789'.contains(value)) {
      _editorState = _editor.apply(_editorState, InsertDigit(value));
      _result = null;
      notifyListeners();
      return;
    }
    if ([
      '+',
      '-',
      '×',
      '÷',
      '^',
      '&',
      '|',
      '<<',
      '>>',
      '&&',
      '||',
    ].contains(value)) {
      _editorState = _editor.apply(_editorState, InsertOperator(value));
      _result = null;
      notifyListeners();
      return;
    }
    if (value == '~') {
      _editorState = _editor.apply(_editorState, InsertOperator('~'));
      _result = null;
      notifyListeners();
      return;
    }
    if (_scientificLabelToFunction.containsKey(value)) {
      final funcName = _scientificLabelToFunction[value]!;
      if (value == 'x²') {
        // Insert exponent operator and 2: "^2"
        _editorState = _editor.apply(_editorState, InsertOperator('^'));
        _editorState = _editor.apply(_editorState, InsertDigit('2'));
      } else {
        _editorState = _editor.apply(_editorState, InsertFunction(funcName));
      }
      _result = null;
      notifyListeners();
      return;
    }

    if (value == '=') {
      _handleEquals();
      return;
    }

    if (value.startsWith('M')) {
      _handleMemory(value);
      return;
    }
  }

  void undo() {
    if (!canUndo) return;
    _editorState = _editor.apply(_editorState, UndoCmd());
    notifyListeners();
  }

  void redo() {
    if (!canRedo) return;
    _editorState = _editor.apply(_editorState, RedoCmd());
    notifyListeners();
  }

  // --- Helpers ---
  void _handleEquals() {
    try {
      final displayExpr = UiSerializer.serialize(
        _editorState,
      ).replaceAll('*', '×').replaceAll('/', '÷');
      final result = _adapter.evaluateFinal(
        _editorState,
        opts: const norm.NormalizerOptions(),
      );
      _calculationHistory.add('$displayExpr = $result');
      _result = result;
      _editorState = EditorState.empty();
      notifyListeners();
    } catch (e) {
      _result = 'Error';
      _editorState = EditorState.empty();
      notifyListeners();
    }
  }

  void _handleClear() {
    if (clearButtonLabel == 'AC') {
      _resetAll();
    } else {
      // Clear current entry or result
      _editorState = EditorState.empty();
      _result = null;
    }
    notifyListeners();
  }

  void _resetAll() {
    _editorState = EditorState.empty();
    _result = null;
  }

  void _handleMemory(String value) {
    final currentValue = _currentNumericValue();
    switch (value) {
      case 'MC':
        _engine.clearMemory('M0');
        break;
      case 'MR':
        final mem = _engine.getMemory('M0');
        if (mem is NumberValue) {
          _result = _formatResult(mem.rawValue);
        } else if (mem is IntegerValue) {
          _result = _formatResult(mem.rawValue);
        } else {
          _result = '0';
        }
        // After MR, show result and clear editor
        _editorState = EditorState.empty();
        break;
      case 'M+':
        _engine.addToMemory('M0', NumberValue(currentValue));
        break;
      case 'M-':
        _engine.addToMemory('M0', NumberValue(-currentValue));
        break;
      case 'MS':
        _engine.setMemory('M0', NumberValue(currentValue));
        break;
    }
    notifyListeners();
  }

  double _currentNumericValue() {
    // Prefer showing result if available
    final s = _result ?? _adapter.tryPreview(_editorState) ?? '0';
    // Adapter formatting never uses thousands separators; safe to parse
    return double.tryParse(s) ?? 0.0;
  }

  String _formatResult(num result) {
    if (result.isNaN || result.isInfinite) return 'Error';
    if (result.abs() > 9999999999 ||
        (result.abs() < 0.0000001 && result != 0)) {
      return result.toStringAsExponential(7);
    }
    if (result is double && result.truncateToDouble() == result) {
      return result.truncate().toString();
    }
    if (result is int) return result.toString();
    String formatted = result.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '');
    return formatted.endsWith('.')
        ? formatted.substring(0, formatted.length - 1)
        : formatted;
  }

  // Memory state check
  bool get isMemorySet {
    final mem = _engine.getMemory('M0');
    if (mem is NumberValue) return mem.rawValue != 0;
    if (mem is IntegerValue) return mem.rawValue != 0;
    return false;
  }
}
