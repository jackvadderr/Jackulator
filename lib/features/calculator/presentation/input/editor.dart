import 'commands.dart';
import 'editor_state.dart';
import 'tokens.dart';

class Editor {
  EditorState apply(EditorState state, EditCommand cmd) {
    // Non-mutating navigation/selection commands first
    if (cmd is SetCursor) {
      final pos = cmd.position.clamp(0, state.tokens.length);
      return state.copyWith(cursor: pos, selStart: null, selEnd: null);
    }
    if (cmd is MoveCursor) {
      final pos = (state.cursor + cmd.delta).clamp(0, state.tokens.length);
      return state.copyWith(cursor: pos, selStart: null, selEnd: null);
    }
    if (cmd is SetSelection) {
      if (cmd.start == null || cmd.end == null) {
        return state.copyWith(selStart: null, selEnd: null);
      }
      final a = cmd.start!.clamp(0, state.tokens.length);
      final b = cmd.end!.clamp(0, state.tokens.length);
      final start = a <= b ? a : b;
      final end = a <= b ? b : a;
      return state.copyWith(selStart: start, selEnd: end, cursor: end);
    }

    // Undo/redo management
    if (cmd is UndoCmd) return _undo(state);
    if (cmd is RedoCmd) return _redo(state);

    // Mutating commands below: capture snapshot for undo
    final s = _pushUndo(state);

    if (cmd is ClearAllCmd) return EditorState.empty();
    if (cmd is BackspaceCmd) return _backspace(s);
    if (cmd is InsertDigit) return _insertDigit(s, cmd.digit);
    if (cmd is InsertDot) return _insertDot(s);
    if (cmd is InsertOperator) return _insertOperator(s, cmd.op);
    if (cmd is InsertParen) return _insertParen(s, cmd.left);
    if (cmd is InsertFunction) return _insertFunction(s, cmd.name);
    if (cmd is InsertPercent) return _insertPercent(s);
    if (cmd is ToggleSignCmd) return _toggleSign(s);
    return s;
  }

  EditorState _pushUndo(EditorState s) {
    final snap = EditorSnapshot(
      tokens: List<UiToken>.from(s.tokens),
      cursor: s.cursor,
      selStart: s.selStart,
      selEnd: s.selEnd,
      decimalSeparator: s.decimalSeparator,
    );
    final newUndo = List<EditorSnapshot>.from(s.undoStack)..add(snap);
    return s.copyWith(undoStack: newUndo, redoStack: const []);
  }

  EditorState _undo(EditorState s) {
    if (s.undoStack.isEmpty) return s;
    final undo = List<EditorSnapshot>.from(s.undoStack);
    final last = undo.removeLast();
    final redoSnap = EditorSnapshot(
      tokens: List<UiToken>.from(s.tokens),
      cursor: s.cursor,
      selStart: s.selStart,
      selEnd: s.selEnd,
      decimalSeparator: s.decimalSeparator,
    );
    final redo = List<EditorSnapshot>.from(s.redoStack)..add(redoSnap);
    return s.copyWith(
      tokens: last.tokens,
      cursor: last.cursor,
      selStart: last.selStart,
      selEnd: last.selEnd,
      decimalSeparator: last.decimalSeparator,
      undoStack: undo,
      redoStack: redo,
    );
  }

  EditorState _redo(EditorState s) {
    if (s.redoStack.isEmpty) return s;
    final redo = List<EditorSnapshot>.from(s.redoStack);
    final next = redo.removeLast();
    final undoSnap = EditorSnapshot(
      tokens: List<UiToken>.from(s.tokens),
      cursor: s.cursor,
      selStart: s.selStart,
      selEnd: s.selEnd,
      decimalSeparator: s.decimalSeparator,
    );
    final undo = List<EditorSnapshot>.from(s.undoStack)..add(undoSnap);
    return s.copyWith(
      tokens: next.tokens,
      cursor: next.cursor,
      selStart: next.selStart,
      selEnd: next.selEnd,
      decimalSeparator: next.decimalSeparator,
      undoStack: undo,
      redoStack: redo,
    );
  }

  // Deletes selection if present and returns updated (t, i, deleted) tuple
  (List<UiToken>, int, bool) _deleteSelectionIfAny(EditorState s) {
    final t = List<UiToken>.from(s.tokens);
    if (s.selStart != null && s.selEnd != null && s.selEnd! > s.selStart!) {
      t.removeRange(s.selStart!, s.selEnd!);
      final newCursor = s.selStart!;
      return (t, newCursor, true);
    }
    return (t, s.cursor, false);
  }

  EditorState _insertDigit(EditorState s, String d) {
    var (t, i, _) = _deleteSelectionIfAny(s);
    if (i > 0 && t[i - 1].type == UiTokenType.number) {
      // append to previous number
      final prev = t[i - 1];
      t[i - 1] = UiToken(UiTokenType.number, prev.text + d);
      return s.copyWith(tokens: t, cursor: i, selStart: null, selEnd: null);
    }
    t.insert(i, UiToken(UiTokenType.number, d));
    return s.copyWith(tokens: t, cursor: i + 1, selStart: null, selEnd: null);
  }

  EditorState _insertDot(EditorState s) {
    var (t, i, _) = _deleteSelectionIfAny(s);
    final dot = s.decimalSeparator;
    if (i > 0 && t[i - 1].type == UiTokenType.number) {
      final prev = t[i - 1];
      if (prev.text.contains(dot)) return s; // prevent double separator
      t[i - 1] = UiToken(UiTokenType.number, prev.text + dot);
      return s.copyWith(tokens: t, cursor: i, selStart: null, selEnd: null);
    }
    // start a new number with leading zero
    t.insert(i, UiToken(UiTokenType.number, '0$dot'));
    return s.copyWith(tokens: t, cursor: i + 1, selStart: null, selEnd: null);
  }

  EditorState _insertOperator(EditorState s, String op) {
    var (t, i, _) = _deleteSelectionIfAny(s);
    // Map UI ops to engine ops for storage consistency
    final engineOp = (op == '\u00d7')
        ? '*'
        : (op == '\u00f7')
        ? '/'
        : op;
    // disallow two operators in a row; replace previous if needed
    if (i > 0 && t[i - 1].type == UiTokenType.operator) {
      t[i - 1] = UiToken(UiTokenType.operator, engineOp);
      return s.copyWith(tokens: t, cursor: i, selStart: null, selEnd: null);
    }
    t.insert(i, UiToken(UiTokenType.operator, engineOp));
    return s.copyWith(tokens: t, cursor: i + 1, selStart: null, selEnd: null);
  }

  EditorState _insertParen(EditorState s, bool left) {
    var (t, i, _) = _deleteSelectionIfAny(s);
    t.insert(
      i,
      UiToken(
        left ? UiTokenType.leftParen : UiTokenType.rightParen,
        left ? '(' : ')',
      ),
    );
    return s.copyWith(tokens: t, cursor: i + 1, selStart: null, selEnd: null);
  }

  EditorState _insertFunction(EditorState s, String name) {
    var (t, i, _) = _deleteSelectionIfAny(s);
    // Insert as identifier token followed by '('
    t.insertAll(i, [
      UiToken(UiTokenType.function, name),
      const UiToken(UiTokenType.leftParen, '('),
    ]);
    return s.copyWith(tokens: t, cursor: i + 2, selStart: null, selEnd: null);
  }

  EditorState _insertPercent(EditorState s) {
    var (t, i, _) = _deleteSelectionIfAny(s);
    // Only valid if there's an operand before and not already a percent
    if (i == 0) return s;
    final leftIdx = i - 1;
    final before = t[leftIdx];
    if (before.type == UiTokenType.operator ||
        before.type == UiTokenType.leftParen ||
        before.type == UiTokenType.percent) {
      return s; // invalid placement or duplicate
    }

    // Insert a postfix percent token; Normalizer expands it later
    t.insert(i, const UiToken(UiTokenType.percent, '%'));
    return s.copyWith(tokens: t, cursor: i + 1, selStart: null, selEnd: null);
  }

  int _findOperandStart(List<UiToken> tokens, int idx) {
    if (idx < 0) return 0;
    if (tokens[idx].type == UiTokenType.rightParen) {
      int depth = 0;
      for (int i = idx; i >= 0; i--) {
        if (tokens[i].type == UiTokenType.rightParen)
          depth++;
        else if (tokens[i].type == UiTokenType.leftParen) {
          depth--;
          if (depth == 0) {
            int start = i;
            while (start - 1 >= 0 &&
                tokens[start - 1].type == UiTokenType.function) {
              start--;
            }
            return start;
          }
        }
      }
      return 0;
    }
    int start = idx;
    while (start - 1 >= 0 && tokens[start - 1].type == UiTokenType.function) {
      start--;
    }
    return start;
  }

  EditorState _toggleSign(EditorState s) {
    var (t, i, _) = _deleteSelectionIfAny(s);
    if (i == 0) {
      t.insert(0, const UiToken(UiTokenType.operator, '-'));
      return s.copyWith(tokens: t, cursor: 1, selStart: null, selEnd: null);
    }
    // if previous is a number, toggle its sign by prefixing/removing '-'
    final prev = t[i - 1];
    if (prev.type == UiTokenType.number) {
      if (prev.text.startsWith('-')) {
        t[i - 1] = UiToken(UiTokenType.number, prev.text.substring(1));
      } else {
        t[i - 1] = UiToken(UiTokenType.number, '-' + prev.text);
      }
      return s.copyWith(tokens: t, selStart: null, selEnd: null);
    }
    // else just insert a unary minus operator
    t.insert(i, const UiToken(UiTokenType.operator, '-'));
    return s.copyWith(tokens: t, cursor: i + 1, selStart: null, selEnd: null);
  }

  EditorState _backspace(EditorState s) {
    // If selection, delete it and stop
    var (t, i, deleted) = _deleteSelectionIfAny(s);
    if (deleted) {
      return s.copyWith(tokens: t, cursor: i, selStart: null, selEnd: null);
    }
    if (i == 0) {
      if (t.isEmpty)
        return s.copyWith(tokens: t, cursor: 0, selStart: null, selEnd: null);
      // delete from end
      i = t.length;
    }
    final delIndex = i - 1;
    if (delIndex < 0 || delIndex >= t.length) {
      return s.copyWith(tokens: t, cursor: 0, selStart: null, selEnd: null);
    }
    final token = t[delIndex];
    if (token.type == UiTokenType.number && token.text.isNotEmpty) {
      final newText = token.text.substring(0, token.text.length - 1);
      if (newText.isEmpty || newText == '-' || newText == '0') {
        t.removeAt(delIndex);
        return s.copyWith(
          tokens: t,
          cursor: delIndex,
          selStart: null,
          selEnd: null,
        );
      } else {
        t[delIndex] = UiToken(UiTokenType.number, newText);
        return s.copyWith(
          tokens: t,
          cursor: delIndex + 1,
          selStart: null,
          selEnd: null,
        );
      }
    }
    t.removeAt(delIndex);
    return s.copyWith(
      tokens: t,
      cursor: delIndex,
      selStart: null,
      selEnd: null,
    );
  }
}
