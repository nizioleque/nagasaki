import 'package:flutter/material.dart';

class FieldData {
  bool isBomb;
  bool isClicked;
  FieldState state;
  bool isDeleted;
  int bombsAround;

  FieldData({
    this.isBomb = false,
    this.isClicked = false,
    this.state = FieldState.none,
    this.isDeleted = false,
    this.bombsAround = 0,
  });
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

enum FieldState {
  none,
  flagged,
  sus,
}

// setting values
class GameSettings {
  int columns;
  int rows;
  int bombs;

  GameSettings({
    this.columns = 10,
    this.rows = 10,
    this.bombs = 10,
  });
}

class FieldPosition {
  final int i;
  final int j;

  static fromIndex(int index, int columns) {
    return FieldPosition(index ~/ columns, index % columns);
  }

  FieldPosition(this.i, this.j);
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is FieldPosition && other.i == i && other.j == j;
  }

  @override
  int get hashCode => hashValues(i, j);
}
