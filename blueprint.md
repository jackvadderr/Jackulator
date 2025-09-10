
# Blueprint: Calculadora Flutter com Identidade "Sidecar"

## Visão Geral

Este documento descreve o projeto de um aplicativo de calculadora para Flutter. O objetivo é criar uma aplicação funcional, intuitiva e com uma identidade visual única, que, embora inspirada por princípios de design modernos, se diferencia dos layouts padrão de calculadoras de sistemas operacionais.

O aplicativo utiliza o pacote `provider` para um gerenciamento de estado limpo e eficiente.

---

## Design e Recursos Implementados

### Identidade Visual: O Layout "Sidecar"

A principal característica do design é o layout "Sidecar", que organiza os botões em uma grade 5x5 consistente, dividida em duas áreas funcionais.

1.  **Grid Principal (4 colunas à esquerda):** Contém todas as operações de cálculo do dia a dia.
    *   Números (0-9)
    *   Operadores aritméticos (`÷`, `×`, `-`, `+`, `=`)
    *   Funções essenciais (`%`, `±`)
    *   O botão inteligente `AC/C`

2.  **Coluna "Sidecar" (1 coluna à direita):** Uma "coluna de poder" dedicada exclusivamente às funções de memória, criando um fluxo de trabalho claro e separado para armazenamento de valores.
    *   `MC` (Memory Clear)
    *   `MR` (Memory Recall)
    *   `M+` (Memory Add)
    *   `M-` (Memory Subtract)
    *   `MS` (Memory Store)

### Paleta de Cores

A paleta de cores foi escolhida para reforçar a identidade visual e a usabilidade:

*   **Fundo:** `CupertinoColors.black`
*   **Botões de Números:** `Color(0xFF333333)` (Cinza Escuro) - O núcleo da calculadora.
*   **Botões de Operadores:** `CupertinoColors.systemOrange` - Cor de destaque para as ações principais.
*   **Botões de Função (Topo):** `Color(0xFFa5a5a5)` (Cinza Claro) - Para funções secundárias.
*   **Coluna "Sidecar" (Memória):** `Color(0xFF505050)` (Cinza Médio) - Uma cor distinta que reforça a separação funcional da área de memória.

### Funcionalidades Chave

*   **Cálculos Padrão:** Operações aritméticas básicas.
*   **Funções de Memória Completas:** O aplicativo oferece um conjunto completo de ferramentas de memória, com os botões `MC` e `MR` sendo desabilitados de forma inteligente quando a memória está vazia.
*   **Indicador de Memória:** Um indicador "M" aparece no display para fornecer feedback visual claro de que um valor está armazenado.
*   **Botão "AC/C" Inteligente:** O botão de limpar alterna automaticamente seu rótulo e função entre "All Clear" e "Clear", dependendo do estado da entrada atual.
*   **Layout Adaptável:** Os botões utilizam `FittedBox` para garantir que o texto se ajuste perfeitamente ao espaço disponível, prevenindo cortes visuais em diferentes tamanhos de tela.
*   **Feedback de Operador:** O operador ativo (`÷`, `×`, `-`, `+`) é visualmente destacado para que o usuário sempre saiba qual operação está pendente.
