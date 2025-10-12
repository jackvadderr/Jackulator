import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/calculator/presentation/input/commands.dart';
import 'package:myapp/features/calculator/presentation/input/editor.dart';
import 'package:myapp/features/calculator/presentation/input/editor_state.dart';
import 'package:myapp/features/calculator/presentation/input/tokens.dart';

void main() {
  group('Editor', () {
    test('inserts digits as a single number and handles dot', () {
      final editor = Editor();
      var state = EditorState.empty();

      state = editor.apply(state, InsertDigit('1'));
      state = editor.apply(state, InsertDigit('2'));
      state = editor.apply(state, InsertDot());
      state = editor.apply(state, InsertDigit('3'));

      expect(state.tokens.length, 1);
      final t = state.tokens.first;
      expect(t.type, UiTokenType.number);
      expect(t.text, '12.3');
    });

    test('maps × and ÷ to * and / operators', () {
      final editor = Editor();
      var state = EditorState.empty();

      state = editor.apply(state, InsertDigit('7'));
      state = editor.apply(state, InsertOperator('\u00d7'));
      state = editor.apply(state, InsertDigit('8'));
      state = editor.apply(state, InsertOperator('\u00f7'));
      state = editor.apply(state, InsertDigit('2'));

      final ops = state.tokens
          .where((t) => t.type == UiTokenType.operator)
          .toList();
      expect(ops.length, 2);
      expect(ops[0].text, '*');
      expect(ops[1].text, '/');
    });

    test('percent inserts only after operand', () {
      final editor = Editor();
      var s = EditorState.empty();

      // Leading percent should be ignored
      final before = s;
      s = editor.apply(s, InsertPercent());
      expect(s.tokens, before.tokens);

      // After number it should insert percent token
      s = editor.apply(s, InsertDigit('5'));
      s = editor.apply(s, InsertDigit('0'));
      s = editor.apply(s, InsertPercent());

      expect(s.tokens.length, 2);
      expect(s.tokens[0].type, UiTokenType.number);
      expect(s.tokens[0].text, '50');
      expect(s.tokens[1].type, UiTokenType.percent);
      expect(s.tokens[1].text, '%');
    });
  });
}
