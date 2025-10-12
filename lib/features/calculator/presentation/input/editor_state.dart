import 'tokens.dart';

class EditorSnapshot {
  final List<UiToken> tokens;
  final int cursor;
  final int? selStart;
  final int? selEnd;
  final String decimalSeparator;

  const EditorSnapshot({
    required this.tokens,
    required this.cursor,
    required this.selStart,
    required this.selEnd,
    required this.decimalSeparator,
  });
}

class EditorState {
  final List<UiToken> tokens;
  final int cursor; // index between tokens [0..tokens.length]
  final int? selStart; // optional selection start
  final int? selEnd; // optional selection end (exclusive)
  final String decimalSeparator; // '.' or ',' according to locale
  final List<EditorSnapshot> undoStack;
  final List<EditorSnapshot> redoStack;

  const EditorState({
    this.tokens = const [],
    this.cursor = 0,
    this.selStart,
    this.selEnd,
    this.decimalSeparator = '.',
    this.undoStack = const [],
    this.redoStack = const [],
  });

  EditorState copyWith({
    List<UiToken>? tokens,
    int? cursor,
    int? selStart,
    int? selEnd,
    String? decimalSeparator,
    List<EditorSnapshot>? undoStack,
    List<EditorSnapshot>? redoStack,
  }) => EditorState(
    tokens: tokens ?? this.tokens,
    cursor: cursor ?? this.cursor,
    selStart: selStart ?? this.selStart,
    selEnd: selEnd ?? this.selEnd,
    decimalSeparator: decimalSeparator ?? this.decimalSeparator,
    undoStack: undoStack ?? this.undoStack,
    redoStack: redoStack ?? this.redoStack,
  );

  static EditorState empty() => const EditorState(tokens: [], cursor: 0);
}
