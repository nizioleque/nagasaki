import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'classes.g.dart';

@JsonSerializable()
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

  factory FieldData.fromJson(Map<String, dynamic> json) =>
      _$FieldDataFromJson(json);
  Map<String, dynamic> toJson() => _$FieldDataToJson(this);
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
@JsonSerializable()
class GameSettings {
  int columns;
  int rows;
  int bombs;

  GameSettings({
    this.columns = 10,
    this.rows = 10,
    this.bombs = 10,
  });

  factory GameSettings.fromJson(Map<String, dynamic> json) =>
      _$GameSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$GameSettingsToJson(this);
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
