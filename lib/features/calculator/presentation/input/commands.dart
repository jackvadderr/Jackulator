abstract class EditCommand {}

class InsertDigit extends EditCommand {
  final String digit; // '0'..'9'
  InsertDigit(this.digit);
}

class InsertDot extends EditCommand {}

class InsertOperator extends EditCommand {
  final String op; // '+', '-', '×', '÷', '^'
  InsertOperator(this.op);
}

class InsertParen extends EditCommand {
  final bool left; // true for '(', false for ')'
  InsertParen(this.left);
}

class InsertFunction extends EditCommand {
  final String name; // 'sin', 'cos', 'tan', 'sqrt', ...
  InsertFunction(this.name);
}

class InsertPercent extends EditCommand {}

class BackspaceCmd extends EditCommand {}

class ClearAllCmd extends EditCommand {}

class ToggleSignCmd extends EditCommand {}

// Cursor and selection management
class MoveCursor extends EditCommand {
  final int delta; // relative move, can be negative
  MoveCursor(this.delta);
}

class SetCursor extends EditCommand {
  final int position; // absolute position [0..tokens.length]
  SetCursor(this.position);
}

class SetSelection extends EditCommand {
  final int? start; // null to clear
  final int? end; // exclusive
  SetSelection({this.start, this.end});
}

// Undo/Redo commands
class UndoCmd extends EditCommand {}

class RedoCmd extends EditCommand {}
