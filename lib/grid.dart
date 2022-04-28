import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:nagasaki/classes.dart';
import 'classes.dart';

class Grid {
  late List<FieldData> grid;
  late GameSettings sett;
  bool locked = false;

  int clickedFields = 0;
  int deletedFields = 0;
  int flaggedFields = 0;
  int bombsLeft = 0;

  // constructor
  Grid({required this.sett}) {
    grid = List.generate(sett.rows * sett.columns, (i) => FieldData());
  }

  FieldData atIndex(int index) {
    return grid[index];
  }

  FieldData atij(int i, int j) {
    return grid[i * sett.columns + j];
  }

  FieldData atPos(FieldPosition pos) {
    return grid[pos.i * sett.columns + pos.j];
  }

  int get columns => sett.columns;
  int get rows => sett.rows;
}

class FieldsAroundIterator extends Iterator<FieldData> {
  late Grid grid;
  late FieldPosition pos;
  late int endi;
  late int endj;
  int returned = -1;
  // late FieldData _current;

  FieldsAroundIterator({required this.grid, required index}) {
    pos = FieldPosition(index, grid.columns);
    endi = grid.rows - 1;
    endj = grid.columns - 1;
    // _current = g.atIndex(index);
  }

  @override
  FieldData get current {
    switch (returned) {
      case 0:
        return grid.atij(pos.i - 1, pos.j);
      case 1:
        return grid.atij(pos.i - 1, pos.j + 1);
      case 2:
        return grid.atij(pos.i, pos.j + 1);
      case 3:
        return grid.atij(pos.i + 1, pos.j + 1);
      case 4:
        return grid.atij(pos.i + 1, pos.j);
      case 5:
        return grid.atij(pos.i + 1, pos.j - 1);
      case 6:
        return grid.atij(pos.i, pos.j - 1);
      case 7:
        return grid.atij(pos.i - 1, pos.j - 1);
      default:
        return grid.atPos(pos);
    }
  }

  @override
  bool moveNext() {
    returned++;

    switch (returned) {
      case 0:
        if (pos.i == 0) {
          return moveNext();
        }
        break;
      case 1:
        if (pos.i == 0 || pos.j == endj) return moveNext();
        break;
      case 2:
        if (pos.j == endj) return moveNext();
        break;
      case 3:
        if (pos.i == endi || pos.j == endj) return moveNext();
        break;
      case 4:
        if (pos.i == endi) return moveNext();
        break;
      case 5:
        if (pos.i == endi || pos.j == 0) return moveNext();
        break;
      case 6:
        if (pos.j == 0) return moveNext();
        break;
      case 7:
        if (pos.i == 0 || pos.j == 0) return moveNext();
        break;
      default:
        return false;
    }

    return true;
  }
}

class FieldsAround extends IterableBase<FieldData> {
  late Grid grid;
  late int index;

  FieldsAround({required this.grid, required this.index});

  @override
  Iterator<FieldData> get iterator => FieldsAroundIterator(
        grid: grid,
        index: index,
      );
}

/*
class FieldsAroundIteratorTEST extends Iterator<FieldPosition> {
  late Grid grid;
  late FieldPosition pos;
  late int endi;
  late int endj;
  int returned = -1;
  // late FieldData _current;

  FieldsAroundIteratorTEST({required this.grid, required index}) {
    pos = FieldPosition.fromIndex(index, grid.columns);
    endi = grid.rows - 1;
    endj = grid.columns - 1;

    debugPrint("CONSTR ITERATOR ${pos.i} ${pos.j} $endi $endj");
    // _current = g.atIndex(index);
  }

  @override
  FieldPosition get current {
    debugPrint("CURRENT $returned");

    switch (returned) {
      case 0:
        return FieldPosition(pos.i - 1, pos.j);
      case 1:
        return FieldPosition(pos.i - 1, pos.j + 1);
      case 2:
        return FieldPosition(pos.i, pos.j + 1);
      case 3:
        return FieldPosition(pos.i + 1, pos.j + 1);
      case 4:
        return FieldPosition(pos.i + 1, pos.j);
      case 5:
        return FieldPosition(pos.i + 1, pos.j - 1);
      case 6:
        return FieldPosition(pos.i, pos.j - 1);
      case 7:
        return FieldPosition(pos.i - 1, pos.j - 1);
      default:
        return pos;
    }
  }

  @override
  bool moveNext() {
    debugPrint("MOVE NEXT $returned");
    returned++;

    switch (returned) {
      case 0:
        if (pos.i == 0) return moveNext();
        break;
      case 1:
        if (pos.i == 0 || pos.j == endj) return moveNext();
        break;
      case 2:
        if (pos.j == endj) return moveNext();
        break;
      case 3:
        if (pos.i == endi || pos.j == endj) return moveNext();
        break;
      case 4:
        if (pos.i == endi) return moveNext();
        break;
      case 5:
        if (pos.i == endi || pos.j == 0) return moveNext();
        break;
      case 6:
        if (pos.j == 0) return moveNext();
        break;
      case 7:
        if (pos.i == 0 || pos.j == 0) return moveNext();
        break;
      default:
        return false;
    }

    debugPrint("END MOVE NEXT");
    return true;
  }
}

class FieldsAroundTEST extends IterableBase<FieldPosition> {
  late Grid grid;
  late int index;

  FieldsAroundTEST({required this.grid, required this.index});

  @override
  Iterator<FieldPosition> get iterator => FieldsAroundIteratorTEST(
        grid: grid,
        index: index,
      );
}
*/