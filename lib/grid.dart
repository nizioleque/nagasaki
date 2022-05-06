import 'dart:math';

import 'package:flutter/material.dart';
import 'package:nagasaki/classes.dart';
import 'package:json_annotation/json_annotation.dart';

import 'classes.dart';
import 'iterators.dart';

part 'grid.g.dart';

@JsonSerializable(explicitToJson: true)
class Grid {
  late List<FieldData> grid;
  GameSettings sett = GameSettings();

  int time = 0;

  bool locked = false;

  int clickedFields = 0;
  int flaggedFields = 0;
  int deletedFields = 0;
  int totalFields = 0;

  bool explosionStarted = false;
  int explosionRadius = 0;
  late List _aboutToDelete;

  // constructor
  Grid({required this.sett}) {
    totalFields = sett.rows * sett.columns;
    grid = List.generate(totalFields, (i) => FieldData());
  }

  factory Grid.fromJson(Map<String, dynamic> json) => _$GridFromJson(json);
  Map<String, dynamic> toJson() => _$GridToJson(this);

  int get columns => sett.columns;
  int get rows => sett.rows;
  int get fields => totalFields;
  int get bombs => sett.bombs;
  int get flagged => flaggedFields;
  int get flagsLeft => bombs - flagged;
  int get clicked => clickedFields;
  int get deleted => deletedFields;
  GameSettings get settings => sett;

  int ijToIndex(int i, int j) => i * sett.columns + j;
  FieldPosition indexToij(int index) =>
      FieldPosition(index ~/ columns, index % columns);

  FieldData at(int index) {
    return grid[index];
  }

  FieldData atij(int i, int j) {
    return grid[i * sett.columns + j];
  }

  FieldData atPos(FieldPosition pos) {
    return grid[pos.i * sett.columns + pos.j];
  }

  void lock() {
    locked = true;
  }

  bool flag(int index) {
    var el = at(index);

    // cant put flag when game over
    if (locked) return false;

    // cant put flag when clicked
    if (el.isClicked) return false;

    if (el.state == FieldState.none) {
      // reached maximum of flags
      if (flagged == bombs) return false;

      // flag
      el.state = FieldState.flagged;
      flaggedFields++;
    } else if (el.state == FieldState.flagged) {
      // remove flag
      el.state = FieldState.sus;
      flaggedFields--;
    } else if (el.state == FieldState.sus) {
      el.state = FieldState.none;
    }

    return true;
  }

  bool tap(int index) {
    // cannot tap when game is over
    if (locked) return false;

    var el = at(index);

    // cannot tap if field is flagged
    if (el.state == FieldState.flagged) return false;

    // make visible
    if (!el.isClicked) makeFieldVisible(index);

    // game end checks --> main.dart
    return true;
  }

  int _countBombsAround(int index) {
    // count bombs around a bomb
    var counter = 0;
    for (FieldData f in FieldsAround(grid: this, index: index)) {
      if (f.isBomb) counter++;
    }
    return counter;
  }

  void generateBombs(int tapIndex) {
    // select random coordinates and add bombs
    var rng = Random();
    var bombs = <int>{};
    var tapPos = indexToij(tapIndex);

    while (bombs.length != sett.bombs) {
      int randomNumber = rng.nextInt(sett.columns * sett.rows);
      var randomPos = indexToij(randomNumber);

      // check if i, j != first clicked field
      // to avoid generating a bomb under the user's finger
      if (!(randomPos.i >= tapPos.i - 1 &&
          randomPos.i <= tapPos.i + 1 &&
          randomPos.j >= tapPos.j - 1 &&
          randomPos.j <= tapPos.j + 1)) {
        bombs.add(randomNumber);
      }
    }

    for (int i in bombs) {
      at(i).isBomb = true;
    }

    // set bomb counts
    for (int i = 0; i < grid.length; i++) {
      at(i).bombsAround = _countBombsAround(i);
    }
  }

  void makeFieldVisible(int index) {
    // make the field visible
    var field = at(index);

    if (field.state == FieldState.flagged) return;

    field.isClicked = true;
    clickedFields++;

    if (field.isBomb) return;

    // make fields around visible
    if (field.bombsAround == 0) {
      for (int f in FieldsAroundPosition(grid: this, index: index)) {
        if (!at(f).isClicked) makeFieldVisible(f);
      }
    }
  }

  bool explode(int index) {
    var pos = indexToij(index);
    var i = pos.i;
    var j = pos.j;

    if (!explosionStarted) {
      _aboutToDelete = [];
      _aboutToDelete.add(FieldPosition(i, j));
      explosionStarted = true;
      atij(i, j).isDeleted = true;
      deletedFields++;
    }
    if (deleted == rows * columns) {
      return false;
    } else {
      List<FieldPosition> temp = [];

      for (int index = 0; index < grid.length; index++) {
        // CIRCLE PATTERN
        var curPos = indexToij(index);
        var curi = curPos.i;
        var curj = curPos.j;
        if (!atij(curi, curj).isDeleted &&
            _getDistance(i, j, curi, curj) <= explosionRadius * 1.0 &&
            !(i == curi && j == curj)) {
          atij(curi, curj).isDeleted = true;
          temp.add(FieldPosition(curi, curj));
        }
      }
      _aboutToDelete = temp;
      explosionRadius++;
      for (var element in _aboutToDelete) {
        atij(element.i, element.j).isClicked = true;
        atij(element.i, element.j).isDeleted = true;
        deletedFields++;
      }
    }
    return true;
  }

  double _getDistance(int x1, int y1, int x2, int y2) {
    return sqrt((x1 - x2) * (x1 - x2) * 1.0 + (y1 - y2) * (y1 - y2) * 1.0);
  }
}
