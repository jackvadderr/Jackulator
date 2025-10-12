import '../input/editor_state.dart';
import '../input/tokens.dart';

class NormalizerOptions {
  final bool closeParens;
  final bool percentRelative; // planned: A op B% relative to A
  const NormalizerOptions({
    this.closeParens = true,
    this.percentRelative = false,
  });
}

class Normalizer {
  // Change signature: required positional EditorState, opts still named
  static String toEngineExpression(
    EditorState s, {
    NormalizerOptions opts = const NormalizerOptions(),
  }) {
    if (s.tokens.isEmpty) return '';

    // Work on a mutable copy of tokens
    final tokens = List<UiToken>.from(s.tokens);

    // Transform postfix percent into division by 100 on its immediate left operand
    int i = 0;
    while (i < tokens.length) {
      if (tokens[i].type == UiTokenType.percent) {
        final leftIdx = i - 1;
        if (leftIdx >= 0) {
          final start = _findOperandStart(tokens, leftIdx);
          // Extract operand segment [start..leftIdx]
          final segment = tokens.sublist(start, leftIdx + 1);
          // Replace [start..i] with: '(' + segment + '/' + '100' + ')'
          final replacement = <UiToken>[
            const UiToken(UiTokenType.leftParen, '('),
            ...segment,
            const UiToken(UiTokenType.operator, '/'),
            const UiToken(UiTokenType.number, '100'),
            const UiToken(UiTokenType.rightParen, ')'),
          ];
          tokens.removeRange(start, i + 1); // remove operand + percent
          tokens.insertAll(start, replacement);
          // Move i to end of the inserted replacement to continue scanning
          i = start + replacement.length;
          continue;
        } else {
          // Stray leading percent, drop it
          tokens.removeAt(i);
          continue;
        }
      }
      i++;
    }

    // Render to engine string
    final buf = StringBuffer();
    for (final t in tokens) {
      buf.write(_writeEngineToken(t));
    }

    final expr = buf.toString();
    return opts.closeParens ? _balanceParens(expr) : expr;
  }

  static String _writeEngineToken(UiToken t) {
    switch (t.type) {
      case UiTokenType.operator:
        return t.text; // '*' and '/' already normalized in editor
      case UiTokenType.number:
        return t.text.replaceAll(',', '.');
      default:
        return t.text;
    }
  }

  static int _findOperandStart(List<UiToken> tokens, int idx) {
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

  static String _balanceParens(String s) {
    int open = 0;
    int close = 0;
    for (final ch in s.codeUnits) {
      if (ch == '('.codeUnitAt(0))
        open++;
      else if (ch == ')'.codeUnitAt(0))
        close++;
    }
    if (open > close) {
      s += ')' * (open - close);
    }
    return s;
  }
}
