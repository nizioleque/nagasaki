import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nagasaki/settings.dart';

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
  final int columns;
  final int rows;
  final int bombs;

  const GameSettings({
    this.columns = 9,
    this.rows = 9,
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

@JsonSerializable()
class UserPreferences {
  bool soundOn;
  Difficulty radioOption;
  GameSettings customSettings;

  UserPreferences({
    this.soundOn = true,
    this.radioOption = Difficulty.beginner,
    this.customSettings = const GameSettings(),
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);
}

class SettingsChange {
  bool difficultyChanged;
  GameSettings? newSettings;

  bool soundChanged;
  bool? newSound;

  SettingsChange({
    this.difficultyChanged = false,
    this.newSettings,
    this.soundChanged = false,
    this.newSound,
  });

  bool get anyChange => difficultyChanged || soundChanged;
}
