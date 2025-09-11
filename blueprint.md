
# Blueprint: Calculadora Flutter com Identidade "Sidecar"

## Visão Geral

Este documento descreve o projeto de um aplicativo de calculadora para Flutter. O objetivo é criar uma aplicação funcional, intuitiva e com uma identidade visual única, que, embora inspirada por princípios de design modernos, se diferencia dos layouts padrão de calculadoras de sistemas operacionais.

O aplicativo utiliza o pacote `provider` para um gerenciamento de estado limpo e reativo, e uma arquitetura que separa a lógica de negócio (operações) da interface do usuário e do gerenciamento de estado.

---

## Design e Recursos Implementados

### Arquitetura

- **State Management:** `Provider` é usado para gerenciar o estado da calculadora de forma centralizada (`CalculatorProvider`).
- **Lógica de Operações Isolada:** Cada operação matemática (adição, porcentagem, etc.) é encapsulada em sua própria classe (`AddOperation`, `PercentageOperation`), seguindo contratos definidos (`BinaryOperation`, `UnaryOperation`). Isso torna o código mais limpo, testável e fácil de expandir.
- **Estrutura de Features:** O código é organizado por funcionalidade (`features/calculator`), separando domínio (regras de negócio), apresentação (UI e provider) e widgets.

### Identidade Visual: O Layout "Sidecar"

A principal característica do design é o layout "Sidecar", que organiza os botões em uma grade 5x5 consistente, dividida em duas áreas funcionais.

1.  **Grid Principal (4 colunas à esquerda):** Contém todas as operações de cálculo do dia a dia.
2.  **Coluna "Sidecar" (1 coluna à direita):** Uma "coluna de poder" dedicada exclusivamente às funções de memória.

### Paleta de Cores

A paleta de cores foi escolhida para reforçar a identidade visual e a usabilidade:

*   **Fundo:** `CupertinoColors.black`
*   **Botões de Números:** `Color(0xFF333333)` (Cinza Escuro)
*   **Botões de Operadores:** `CupertinoColors.systemOrange`
*   **Botões de Função (Topo):** `Color(0xFFa5a5a5)` (Cinza Claro)
*   **Coluna "Sidecar" (Memória):** `Color(0xFF505050)` (Cinza Médio)

### Funcionalidades Chave Implementadas

- **Cálculos Padrão:** Operações aritméticas básicas com feedback visual para o operador ativo.
- **Funções de Memória Completas:** Conjunto completo de ferramentas de memória (`MC`, `MR`, `M+`, `M-`, `MS`) com feedback visual (indicador "M") e desativação inteligente de botões.
- **Botão "AC/C" Inteligente:** O botão de limpar alterna sua função e rótulo entre "All Clear" e "Clear" com base no estado da entrada.
- **Histórico de Cálculos:** Um "bottom sheet" acessível por um ícone de relógio exibe uma lista de todos os cálculos finalizados com `=`. 
- **Desfazer e Refazer (Undo/Redo):** Botões no topo do display permitem ao usuário navegar pelo histórico de estados da calculadora, desfazendo e refazendo cada ação passo a passo.

---

## Plano de Desenvolvimento Atual

### **Feature: Modos de Calculadora (Básico e Científico)**

O próximo passo é expandir a calculadora para suportar dois modos distintos, transformando-a em uma ferramenta mais versátil.

#### **1. Lógica e Estado**

-   **Controle de Modo:** Um novo estado será adicionado ao `CalculatorProvider` para gerenciar o modo ativo (`CalculatorMode.basic` vs. `CalculatorMode.scientific`).
-   **Novas Operações:** Funções científicas (sin, cos, tan, log, √, x², etc.) serão criadas em um novo arquivo (`scientific_operations.dart`), seguindo a arquitetura de operações já estabelecida.

#### **2. Interface do Usuário (UI)**

-   **Seletor de Modo:** Um controle segmentado (`CupertinoSegmentedControl`) será adicionado à UI para permitir a troca fácil entre os modos "Básico" e "Científico".
-   **Layout Dinâmico:** A grade de botões se adaptará ao modo selecionado:
    -   **Modo Básico:** Manterá a grade 5x5 atual.
    -   **Modo Científico:** Expandirá a grade (provavelmente para 5x6 ou 5x7) para acomodar os novos botões de funções científicas.
