import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/calculator/domain/calculator_engine.dart';
import 'package:myapp/features/calculator/presentation/adapter/engine_adapter.dart';
import 'package:myapp/features/calculator/presentation/input/editor_state.dart';
import 'package:myapp/features/calculator/presentation/input/tokens.dart';

void main() {
  group('EngineAdapter live preview', () {
    late CalculatorEngine engine;
    late EngineAdapter adapter;

    setUp(() {
      engine = CalculatorEngine();
      adapter = EngineAdapter(engine);
    });

    test('computes preview for simple addition', () {
      final s = EditorState(
        tokens: const [
          UiToken(UiTokenType.number, '1'),
          UiToken(UiTokenType.operator, '+'),
          UiToken(UiTokenType.number, '2'),
        ],
      );
      final preview = adapter.tryPreview(s);
      expect(preview, '3');
    });

    test('returns null for incomplete expression', () {
      final s = EditorState(
        tokens: const [
          UiToken(UiTokenType.number, '1'),
          UiToken(UiTokenType.operator, '+'),
        ],
      );
      final preview = adapter.tryPreview(s);
      expect(preview, isNull);
    });

    test('percent semantics: 50 + 10% = 50.1 (not relative)', () {
      final s = EditorState(
        tokens: const [
          UiToken(UiTokenType.number, '50'),
          UiToken(UiTokenType.operator, '+'),
          UiToken(UiTokenType.number, '10'),
          UiToken(UiTokenType.percent, '%'),
        ],
      );
      final preview = adapter.tryPreview(s);
      expect(preview, '50.1');
    });

    test('locale decimal comma is accepted and normalized', () {
      final s = EditorState(
        tokens: const [
          UiToken(UiTokenType.number, '1,5'),
          UiToken(UiTokenType.operator, '+'),
          UiToken(UiTokenType.number, '2'),
        ],
        decimalSeparator: ',',
      );
      final preview = adapter.tryPreview(s);
      expect(preview, '3.5');
    });
  });
}
