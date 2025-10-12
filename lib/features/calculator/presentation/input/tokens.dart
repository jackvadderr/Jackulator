// Token definitions for the input layer

enum UiTokenType {
  number,
  operator,
  leftParen,
  rightParen,
  function,
  comma,
  percent, // postfix percent token
}

class UiToken {
  final UiTokenType type;
  final String text; // user-visible text or canonical op (*, /)

  const UiToken(this.type, this.text);

  bool get isOperandLike =>
      type == UiTokenType.number ||
      type == UiTokenType.rightParen ||
      type ==
          UiTokenType.function; // function(...) counts as operand when closed
}
