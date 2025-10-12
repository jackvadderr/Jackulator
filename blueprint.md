# Blueprint: Calculadora Flutter com Identidade "Sidecar"

## Visão Geral

Este documento descreve o projeto de um aplicativo de calculadora para Flutter. O objetivo é criar uma aplicação funcional, intuitiva e com uma identidade visual única, que, embora inspirada por princípios de design modernos, se diferencia dos layouts padrão de calculadoras de sistemas operacionais.

O aplicativo utiliza o pacote `provider` para um gerenciamento de estado limpo e reativo, e uma arquitetura que separa a lógica de negócio (operações) da interface do usuário e do gerenciamento de estado.

---

## Arquitetura por Camadas (Input → Presentation → Normalization → Engine)

- InputLayer
  - Representa a expressão como uma lista de tokens (UiToken) com cursor/seleção.
  - Implementa comandos de edição atômicos (inserir dígito, operador, função, parênteses, backspace, toggle-sign, mover cursor, setar seleção, undo/redo).
  - Trata localidade via `EditorState.decimalSeparator` ('.' ou ',').
  - Arquivos: `presentation/input/{commands.dart, tokens.dart, editor_state.dart, editor.dart}`.

- PresentationLayer
  - Somente leitura: serializa tokens para a UI (× e ÷ no display, destaque de seleção/cursor no futuro).
  - Arquivo: `presentation/presentation/ui_serializer.dart`.

- NormalizationLayer
  - Transforma tokens em uma string segura e desambiguada para a engine.
  - Regras: normaliza vírgula decimal para ponto; fecha parênteses opcionais; resolve `%` postfix.
  - Arquivo: `presentation/normalize/normalizer.dart`.

- EngineAdapter
  - Interface segura com a engine de domínio, suportando preview ao vivo (opcional) e avaliação final.
  - Arquivo: `presentation/adapter/engine_adapter.dart`.

- Provider/UI
  - `CalculatorProvider` orquestra a entrada da UI, roteando teclas para o Editor, e utiliza Normalizer/Engine.
  - Propriedades expostas: `liveDisplayExpression`, `formattedOutput`, `livePreviewValue` (opcional), `enableLivePreview()`.

---

## Semântica de Percentual

- Escolha atual (documentada): `%` é um operador postfix unário que divide o operando imediato por 100.
  - Exemplos: `10%` → `(10/100)`; `(1+2)%` → `((1+2)/100)`.
  - Comportamento relativo (ex.: `50 + 10% = 55`) não está habilitado por padrão e poderá ser adicionado via `NormalizerOptions.percentRelative`.

- Implementação:
  - No `Editor`, `%` só é válido após um operando (número, `)`, ou função fechada); múltiplos `%` consecutivos são bloqueados.
  - No `Normalizer`, cada ocorrência de `%` é reescrita tokenicamente para `(operando/100)` garantindo segurança e previsibilidade.

---

## UX de Edição e Undo/Redo

- Cursor e Seleção: `EditorState` mantém `cursor`, `selStart/selEnd`; comandos permitem mover e selecionar.
- Backspace inteligente: apaga dígitos dentro de um número e remove tokens respeitando seleção.
- Undo/Redo: implementado via Command Pattern com snapshots imutáveis; `UndoCmd`/`RedoCmd` restauram estados.

---

## Localidade e Formatação

- Entrada: `InsertDot` respeita `decimalSeparator` ('.' ou ',') e previne duplo separador no mesmo número.
- Normalização: vírgulas são convertidas para ponto antes de enviar à engine.
- Saída: `formattedOutput` segue política atual do provider; `EngineAdapter` inclui formatação consistente para preview e '='.

---

## Preview ao Vivo (Opcional)

- `EngineAdapter.tryPreview` avalia a expressão normalizada de forma segura e retorna string ou `null` quando incompleta/ inválida.
- Ativação: `CalculatorProvider.enableLivePreview(true)` expõe `livePreviewValue` para a UI (sem efeitos colaterais na engine/histórico principal).

---

## Testes

- Foram adicionados testes unitários cobrindo:
  - Editor: tokenização, ponto decimal local, `%`, backspace, seleção, undo/redo.
  - Normalizer: semântica de `%`, normalização de vírgula, fechamento automático de parênteses.
  - EngineAdapter: preview simples, expressão incompleta e `%` não relativo.

---

## Próximos Passos

- Implementar semântica percentual relativa (opcional) protegida por configuração.
- Expor UI de cursor/seleção e atalhos (longo-toque, arrastar) quando aplicável.
- Internacionalização completa de rótulos e formatos.
- Property-based tests para casos de borda (ex.: sequências de backspace, inserção aleatória e `%` em expressões complexas).
