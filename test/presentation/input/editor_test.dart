import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/calculator/presentation/input/commands.dart';
import 'package:myapp/features/calculator/presentation/input/editor.dart';
import 'package:myapp/features/calculator/presentation/input/editor_state.dart';
import 'package:myapp/features/calculator/presentation/input/tokens.dart';

void main() {
  group('Editor - tokenization & editing', () {
    late Editor editor;
    late EditorState state;

    setUp(() {
      editor = Editor();
      state = EditorState.empty();
    });

    test('Insert digits composes number token', () {
      state = editor.apply(state, InsertDigit('1'));
      state = editor.apply(state, InsertDigit('2'));
      expect(state.tokens.length, 1);
      expect(state.tokens[0].type, UiTokenType.number);
      expect(state.tokens[0].text, '12');
    });

    test('Insert dot respects locale and prevents double separator', () {
      state = state.copyWith(decimalSeparator: ',');
      state = editor.apply(state, InsertDigit('3'));
      state = editor.apply(state, InsertDot());
      state = editor.apply(state, InsertDigit('1'));
      state = editor.apply(state, InsertDigit('4'));
      // second dot should be ignored
      state = editor.apply(state, InsertDot());
      expect(state.tokens.single.type, UiTokenType.number);
      expect(state.tokens.single.text, '3,14');
    });

    test('Insert percent allowed only after operand', () {
      // starting percent should be ignored
      state = editor.apply(state, InsertPercent());
      expect(state.tokens, isEmpty);
      // number then percent
      state = editor.apply(state, InsertDigit('1'));
      state = editor.apply(state, InsertDigit('0'));
      state = editor.apply(state, InsertPercent());
      expect(state.tokens.map((t) => t.text).toList(), ['10', '%']);
      // percent followed by another percent should be ignored
      final prev = state;
      state = editor.apply(state, InsertPercent());
      expect(state.tokens, prev.tokens);
    });

    test('Backspace deletes within number and tokens', () {
      state = editor.apply(state, InsertDigit('1'));
      state = editor.apply(state, InsertDigit('2'));
      state = editor.apply(state, InsertOperator('+'));
      state = editor.apply(state, InsertDigit('3'));
      expect(state.tokens.map((t) => t.text).toList(), ['12', '+', '3']);

      // backspace removes last digit
      state = editor.apply(state, BackspaceCmd());
      expect(state.tokens.map((t) => t.text).toList(), ['12', '+']);
      // backspace removes operator
      state = editor.apply(state, BackspaceCmd());
      expect(state.tokens.map((t) => t.text).toList(), ['12']);
      // backspace trims number
      state = editor.apply(state, BackspaceCmd());
      expect(state.tokens.map((t) => t.text).toList(), ['1']);
    });

    test('Selection deletion works', () {
      state = editor.apply(state, InsertDigit('1'));
      state = editor.apply(state, InsertDigit('2'));
      state = editor.apply(state, InsertOperator('+'));
      state = editor.apply(state, InsertDigit('3'));
      state = editor.apply(state, InsertDigit('4'));
      // tokens: ['12','+','34']
      state = editor.apply(state, SetSelection(start: 0, end: 1));
      state = editor.apply(state, BackspaceCmd());
      expect(state.tokens.map((t) => t.text).toList(), ['+', '34']);
    });

    test('Undo/Redo restores previous states', () {
      state = editor.apply(state, InsertDigit('7'));
      state = editor.apply(state, InsertOperator('+'));
      state = editor.apply(state, InsertDigit('5'));
      expect(state.tokens.map((t) => t.text).toList(), ['7', '+', '5']);

      state = editor.apply(state, UndoCmd());
      expect(state.tokens.map((t) => t.text).toList(), ['7', '+']);

      state = editor.apply(state, RedoCmd());
      expect(state.tokens.map((t) => t.text).toList(), ['7', '+', '5']);
    });
  });
}
