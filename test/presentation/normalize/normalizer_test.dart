import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/calculator/presentation/input/editor_state.dart';
import 'package:myapp/features/calculator/presentation/input/tokens.dart';
import 'package:myapp/features/calculator/presentation/normalize/normalizer.dart';

void main() {
  group('Normalizer', () {
    test('number% becomes (number/100)', () {
      final s = EditorState(
        tokens: const [
          UiToken(UiTokenType.number, '10'),
          UiToken(UiTokenType.percent, '%'),
        ],
      );
      final expr = Normalizer.toEngineExpression(s);
      expect(expr, '(10/100)');
    });

    test('(1+2)% becomes ((1+2)/100)', () {
      final s = EditorState(
        tokens: const [
          UiToken(UiTokenType.leftParen, '('),
          UiToken(UiTokenType.number, '1'),
          UiToken(UiTokenType.operator, '+'),
          UiToken(UiTokenType.number, '2'),
          UiToken(UiTokenType.rightParen, ')'),
          UiToken(UiTokenType.percent, '%'),
        ],
      );
      final expr = Normalizer.toEngineExpression(s);
      expect(expr, '((1+2)/100)');
    });

    test('decimal comma normalized to dot', () {
      final s = EditorState(
        tokens: const [
          UiToken(UiTokenType.number, '3,14'),
          UiToken(UiTokenType.operator, '+'),
          UiToken(UiTokenType.number, '2'),
        ],
      );
      final expr = Normalizer.toEngineExpression(s);
      expect(expr, '3.14+2');
    });

    test('balanced parentheses added when missing', () {
      final s = EditorState(
        tokens: const [
          UiToken(UiTokenType.function, 'sqrt'),
          UiToken(UiTokenType.leftParen, '('),
          UiToken(UiTokenType.number, '9'),
          // missing )
        ],
      );
      final expr = Normalizer.toEngineExpression(s);
      expect(expr, 'sqrt(9)');
    });
  });
}
