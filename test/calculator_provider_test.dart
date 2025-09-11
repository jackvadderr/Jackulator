
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/features/calculator/presentation/provider/calculator_provider.dart';
import 'package:myapp/features/calculator/presentation/screens/calculator_screen.dart';
import 'package:myapp/main.dart';
import 'package:provider/provider.dart';

void main() {
  group('Calculator Integration and Logic Tests', () {
    // --- Provider Logic Tests ---
    group('CalculatorProvider Logic', () {
      late CalculatorProvider calculator;

      setUp(() {
        calculator = CalculatorProvider();
      });

      test('Initial State', () {
        expect(calculator.formattedOutput, '0');
        expect(calculator.displayExpression, '');
      });

      test('Number Input', () {
        calculator.onButtonPressed('1');
        calculator.onButtonPressed('2');
        calculator.onButtonPressed('.');
        calculator.onButtonPressed('5');
        expect(calculator.formattedOutput, '12.5');
      });

      test('Simple Addition: 5 + 8 =', () {
        calculator.onButtonPressed('5');
        calculator.onButtonPressed('+');
        calculator.onButtonPressed('8');
        calculator.onButtonPressed('=');
        expect(calculator.formattedOutput, '13');
        expect(calculator.displayExpression, '');
      });

      test('Order of Operations (PEMDAS): 2 + 3 * 4 =', () {
        calculator.onButtonPressed('2');
        calculator.onButtonPressed('+');
        calculator.onButtonPressed('3');
        calculator.onButtonPressed('×');
        calculator.onButtonPressed('4');
        calculator.onButtonPressed('=');
        expect(calculator.formattedOutput, '14');
      });

      test('Parentheses: (2 + 3) * 4 =', () {
        calculator.onButtonPressed('(');
        calculator.onButtonPressed('2');
        calculator.onButtonPressed('+');
        calculator.onButtonPressed('3');
        calculator.onButtonPressed(')');
        calculator.onButtonPressed('×');
        calculator.onButtonPressed('4');
        calculator.onButtonPressed('=');
        expect(calculator.formattedOutput, '20');
      });

      test('Scientific Functions: sqrt(9) + 1 =', () {
        calculator.onButtonPressed('√');
        calculator.onButtonPressed('9');
        calculator.onButtonPressed(')');
        calculator.onButtonPressed('+');
        calculator.onButtonPressed('1');
        calculator.onButtonPressed('=');
        expect(calculator.formattedOutput, '4');
      });

       test('Complex Scientific Expression: log10(100) * 3', () {
          calculator.onButtonPressed('log');
          calculator.onButtonPressed('1');
          calculator.onButtonPressed('0');
          calculator.onButtonPressed('0');
          calculator.onButtonPressed(')');
          calculator.onButtonPressed('×');
          calculator.onButtonPressed('3');
          calculator.onButtonPressed('=');
          expect(calculator.formattedOutput, '6');
        });

      test('Clear Logic (C and AC)', () {
        expect(calculator.clearButtonLabel, 'AC');
        calculator.onButtonPressed('1');
        calculator.onButtonPressed('2');
        expect(calculator.clearButtonLabel, 'C');
        calculator.onButtonPressed('AC');
        expect(calculator.formattedOutput, '0');
        expect(calculator.displayExpression, '');
        expect(calculator.clearButtonLabel, 'AC');
      });

      test('Backspace', () {
        calculator.onButtonPressed('1');
        calculator.onButtonPressed('2');
        calculator.onButtonPressed('3');
        calculator.backspace();
        expect(calculator.formattedOutput, '12');
      });

      test('Error Handling: Division by Zero', () {
        calculator.onButtonPressed('5');
        calculator.onButtonPressed('÷');
        calculator.onButtonPressed('0');
        calculator.onButtonPressed('=');
        expect(calculator.formattedOutput, 'Error');
      });

      test('Correct Handling: Malformed Expression Becomes Correct', () {
        calculator.onButtonPressed('5');
        calculator.onButtonPressed('+');
        calculator.onButtonPressed('×');
        calculator.onButtonPressed('2');
        calculator.onButtonPressed('=');
        expect(calculator.formattedOutput, '10');
      });

      // *** TESTE CORRIGIDO ***
      test('Undo/Redo Functionality', () {
        calculator.onButtonPressed('1');
        calculator.onButtonPressed('2');
        calculator.onButtonPressed('+');
        calculator.onButtonPressed('3');

        // Estado após digitar: expressão é '12+', output atual é '3'
        expect(calculator.displayExpression, '12+');
        expect(calculator.formattedOutput, '3');

        calculator.undo(); // Desfaz a entrada '3'
        // Estado: expressão continua '12+', output volta para '0'
        expect(calculator.displayExpression, '12+');
        expect(calculator.formattedOutput, '0');

        calculator.undo(); // Desfaz o operador '+'
        // Estado: expressão vazia, output é '12'
        expect(calculator.displayExpression, '');
        expect(calculator.formattedOutput, '12');

        calculator.redo(); // Refaz o operador '+'
        // Estado: expressão é '12+', output é '0'
        expect(calculator.displayExpression, '12+');
        expect(calculator.formattedOutput, '0');

        calculator.redo(); // Refaz a entrada '3'
        // Estado: volta ao início
        expect(calculator.displayExpression, '12+');
        expect(calculator.formattedOutput, '3');
      });

      test('Memory Functions', () {
        calculator.onButtonPressed('1');
        calculator.onButtonPressed('5');
        calculator.onButtonPressed('MS');
        expect(calculator.isMemorySet, isTrue);
        calculator.onButtonPressed('C');
        calculator.onButtonPressed('1');
        calculator.onButtonPressed('0');
        calculator.onButtonPressed('M+');
        calculator.onButtonPressed('C');
        calculator.onButtonPressed('MR');
        expect(calculator.formattedOutput, '25');
      });
    });

    // --- Widget Tests ---
    group('CalculatorScreen Widget Tests', () {
      Future<void> pumpCalculator(WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        await tester.pumpAndSettle();
      }

      testWidgets('should display 0 initially', (WidgetTester tester) async {
        await pumpCalculator(tester);
        // Verifica se o display de output principal mostra '0'
        final outputFinder = find.descendant(
          of: find.byKey(const Key('display_output')),
          matching: find.text('0'),
        );
        expect(outputFinder, findsOneWidget);
      });

      testWidgets('should show numbers on button press', (WidgetTester tester) async {
        await pumpCalculator(tester);
        await tester.tap(find.text('7'));
        await tester.pump();
        final outputFinder = find.descendant(
          of: find.byKey(const Key('display_output')),
          matching: find.text('7'),
        );
        expect(outputFinder, findsOneWidget);
      });

      testWidgets('should perform simple addition and show result', (WidgetTester tester) async {
        await pumpCalculator(tester);
        await tester.tap(find.text('2'));
        await tester.pump();
        await tester.tap(find.text('+'));
        await tester.pump();
        await tester.tap(find.text('3'));
        await tester.pump();

        // Verifica a expressão no display secundário
        expect(find.text('2+'), findsOneWidget);
        // Verifica o número atual no display principal
        final outputFinder = find.descendant(
          of: find.byKey(const Key('display_output')),
          matching: find.text('3'),
        );
        expect(outputFinder, findsOneWidget);

        await tester.tap(find.text('='));
        await tester.pump();

        // Verifica o resultado final no display principal
        final finalResultFinder = find.descendant(
          of: find.byKey(const Key('display_output')),
          matching: find.text('5'),
        );
        expect(finalResultFinder, findsOneWidget);
        // Verifica se a expressão do display secundário foi limpa
        expect(find.text('2+3'), findsNothing);
      });

       testWidgets('should switch to scientific mode and use a scientific function', (WidgetTester tester) async {
        await pumpCalculator(tester);

        // Acha e pressiona o botão de modo
        await tester.tap(find.byIcon(Icons.science_outlined));
        await tester.pumpAndSettle(); // Aguarda a animação da UI

        // Verifica se um botão científico (ex: 'sin') está visível
        expect(find.text('sin'), findsOneWidget);

        // Executa um cálculo científico
        await tester.tap(find.text('√'));
        await tester.pump();
        await tester.tap(find.text('9'));
        await tester.pump();
        await tester.tap(find.text(')'));
        await tester.pump();
        await tester.tap(find.text('='));
        await tester.pump();
        
        final finalResultFinder = find.descendant(
          of: find.byKey(const Key('display_output')),
          matching: find.text('3'),
        );
        expect(finalResultFinder, findsOneWidget);
      });
    });
  });
}
