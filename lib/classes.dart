class FieldData {
  bool isBomb;
  bool isClicked;
  bool isFlagged;
  int bombsAround;

  FieldData([
    this.isBomb = false,
    this.isClicked = false,
    this.isFlagged = false,
    this.bombsAround = 0,
  ]);
}

class FieldChangeData {
  int index;
  PressType pressType;

  FieldChangeData(
    this.index,
    this.pressType,
  );
}

enum PressType {
  tap,
  longPress,
}
