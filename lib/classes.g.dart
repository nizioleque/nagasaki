// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'classes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FieldData _$FieldDataFromJson(Map<String, dynamic> json) => FieldData(
      isBomb: json['isBomb'] as bool? ?? false,
      isClicked: json['isClicked'] as bool? ?? false,
      state: $enumDecodeNullable(_$FieldStateEnumMap, json['state']) ??
          FieldState.none,
      isDeleted: json['isDeleted'] as bool? ?? false,
      bombsAround: json['bombsAround'] as int? ?? 0,
    );

Map<String, dynamic> _$FieldDataToJson(FieldData instance) => <String, dynamic>{
      'isBomb': instance.isBomb,
      'isClicked': instance.isClicked,
      'state': _$FieldStateEnumMap[instance.state],
      'isDeleted': instance.isDeleted,
      'bombsAround': instance.bombsAround,
    };

const _$FieldStateEnumMap = {
  FieldState.none: 'none',
  FieldState.flagged: 'flagged',
  FieldState.sus: 'sus',
};

GameSettings _$GameSettingsFromJson(Map<String, dynamic> json) => GameSettings(
      columns: json['columns'] as int? ?? 10,
      rows: json['rows'] as int? ?? 10,
      bombs: json['bombs'] as int? ?? 10,
    );

Map<String, dynamic> _$GameSettingsToJson(GameSettings instance) =>
    <String, dynamic>{
      'columns': instance.columns,
      'rows': instance.rows,
      'bombs': instance.bombs,
    };

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      soundOn: json['soundOn'] as bool? ?? true,
      radioOption:
          $enumDecodeNullable(_$DifficultyEnumMap, json['radioOption']) ??
              Difficulty.beginner,
      customSettings: json['customSettings'] == null
          ? const GameSettings()
          : GameSettings.fromJson(
              json['customSettings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'soundOn': instance.soundOn,
      'radioOption': _$DifficultyEnumMap[instance.radioOption],
      'customSettings': instance.customSettings,
    };

const _$DifficultyEnumMap = {
  Difficulty.beginner: 'beginner',
  Difficulty.intermediate: 'intermediate',
  Difficulty.expert: 'expert',
  Difficulty.custom: 'custom',
};
