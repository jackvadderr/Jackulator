import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/calculator/presentation/input/editor_state.dart';
import 'package:myapp/features/calculator/presentation/input/tokens.dart';
import 'package:myapp/features/calculator/presentation/normalize/normalizer.dart';

void main() {
  group('Normalizer', () {
    test('transforms postfix percent into division by 100', () {
      final state = EditorState(
        tokens: const [
          UiToken(UiTokenType.number, '50'),
          UiToken(UiTokenType.percent, '%'),
        ],
      );

      final expr = Normalizer.toEngineExpression(state);
      expect(expr, '(50/100)');
    });

    test('balances missing closing parenthesis when enabled', () {
      final state = EditorState(
        tokens: const [
          UiToken(UiTokenType.leftParen, '('),
          UiToken(UiTokenType.number, '1'),
          UiToken(UiTokenType.operator, '+'),
          UiToken(UiTokenType.number, '2'),
        ],
      );

      final expr = Normalizer.toEngineExpression(state);
      expect(expr, '(1+2)');
    });

    test('normalizes decimal comma to dot in numbers', () {
      final state = EditorState(
        tokens: const [
          UiToken(UiTokenType.number, '1,5'),
          UiToken(UiTokenType.operator, '+'),
          UiToken(UiTokenType.number, '2'),
        ],
      );

      final expr = Normalizer.toEngineExpression(state);
      expect(expr, '1.5+2');
    });
  });
}
