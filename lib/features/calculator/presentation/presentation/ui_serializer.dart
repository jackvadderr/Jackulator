import '../input/editor_state.dart';
import '../input/tokens.dart' as ui;

class UiSerializer {
  static String serialize(EditorState state) {
    final tokens = state.tokens;
    final buf = StringBuffer();

    int i = 0;
    while (i < tokens.length) {
      final t = tokens[i];
      // Detect pattern: '(' <operand> '/' '100' ')' and render as '<operand>%'
      if (t.type == ui.UiTokenType.leftParen) {
        final end = _findMatchingParen(tokens, i);
        if (end != null && end - i >= 3) {
          final divider = tokens[end - 1]; // expected '100'
          final slash = tokens[end - 2]; // expected '/'
          if (divider.type == ui.UiTokenType.number &&
              divider.text == '100' &&
              slash.type == ui.UiTokenType.operator &&
              slash.text == '/') {
            // Render operand between i+1 and end-3 (inclusive)
            final operand = _renderUi(tokens, i + 1, end - 3);
            buf.write(operand);
            buf.write('%');
            i = end + 1;
            continue;
          }
        }
      }

      // Default rendering
      if (t.type == ui.UiTokenType.operator) {
        if (t.text == '*')
          buf.write('×');
        else if (t.text == '/')
          buf.write('÷');
        else
          buf.write(t.text);
      } else {
        buf.write(t.text);
      }
      i++;
    }

    return buf.toString();
  }

  static int? _findMatchingParen(List<ui.UiToken> tokens, int leftIndex) {
    int depth = 0;
    for (int j = leftIndex; j < tokens.length; j++) {
      final tt = tokens[j];
      if (tt.type == ui.UiTokenType.leftParen)
        depth++;
      else if (tt.type == ui.UiTokenType.rightParen) {
        depth--;
        if (depth == 0) return j;
      }
    }
    return null;
  }

  static String _renderUi(List<ui.UiToken> tokens, int start, int end) {
    final b = StringBuffer();
    for (int k = start; k <= end; k++) {
      final t = tokens[k];
      if (t.type == ui.UiTokenType.operator) {
        if (t.text == '*')
          b.write('×');
        else if (t.text == '/')
          b.write('÷');
        else
          b.write(t.text);
      } else {
        b.write(t.text);
      }
    }
    return b.toString();
  }
}
