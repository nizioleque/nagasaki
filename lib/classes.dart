class FieldData {
  bool isBomb;
  bool isVisible;
  int bombsAround;

  FieldData([
    this.isBomb = false,
    this.isVisible = false,
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
