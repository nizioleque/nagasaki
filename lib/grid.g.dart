// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grid.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Grid _$GridFromJson(Map<String, dynamic> json) => Grid(
      sett: GameSettings.fromJson(json['sett'] as Map<String, dynamic>),
    )
      ..grid = (json['grid'] as List<dynamic>)
          .map((e) => FieldData.fromJson(e as Map<String, dynamic>))
          .toList()
      ..time = json['time'] as int
      ..locked = json['locked'] as bool
      ..clickedFields = json['clickedFields'] as int
      ..flaggedFields = json['flaggedFields'] as int
      ..deletedFields = json['deletedFields'] as int
      ..totalFields = json['totalFields'] as int
      ..disarmedBombs = json['disarmedBombs'] as int
      ..explosionStarted = json['explosionStarted'] as bool
      ..explosionRadius = json['explosionRadius'] as int;

Map<String, dynamic> _$GridToJson(Grid instance) => <String, dynamic>{
      'grid': instance.grid.map((e) => e.toJson()).toList(),
      'sett': instance.sett.toJson(),
      'time': instance.time,
      'locked': instance.locked,
      'clickedFields': instance.clickedFields,
      'flaggedFields': instance.flaggedFields,
      'deletedFields': instance.deletedFields,
      'totalFields': instance.totalFields,
      'disarmedBombs': instance.disarmedBombs,
      'explosionStarted': instance.explosionStarted,
      'explosionRadius': instance.explosionRadius,
    };
