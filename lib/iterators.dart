import 'dart:collection';

import 'classes.dart';
import 'grid.dart';

class FieldsAroundIterator extends Iterator<FieldData> {
  late Grid grid;
  // late FieldPosition pos;
  // late int endi;
  // late int endj;
  // int returned = -1;

  late FieldsAroundPositionIterator iter;

  FieldsAroundIterator({required this.grid, required index}) {
    // pos = FieldPosition(index, grid.columns);
    // endi = grid.rows - 1;
    // endj = grid.columns - 1;

    iter = FieldsAroundPositionIterator(grid: grid, index: index);
  }

  @override
  FieldData get current => grid.atIndex(iter.current);

  @override
  bool moveNext() => iter.moveNext();
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

class FieldsAroundPositionIterator extends Iterator<int> {
  late Grid grid;
  late FieldPosition pos;
  late int endi;
  late int endj;
  int returned = -1;

  FieldsAroundPositionIterator({required this.grid, required index}) {
    pos = FieldPosition.fromIndex(index, grid.columns);
    endi = grid.rows - 1;
    endj = grid.columns - 1;
  }

  @override
  int get current {
    switch (returned) {
      case 0:
        return grid.ijToIndex(pos.i - 1, pos.j);
      case 1:
        return grid.ijToIndex(pos.i - 1, pos.j + 1);
      case 2:
        return grid.ijToIndex(pos.i, pos.j + 1);
      case 3:
        return grid.ijToIndex(pos.i + 1, pos.j + 1);
      case 4:
        return grid.ijToIndex(pos.i + 1, pos.j);
      case 5:
        return grid.ijToIndex(pos.i + 1, pos.j - 1);
      case 6:
        return grid.ijToIndex(pos.i, pos.j - 1);
      case 7:
        return grid.ijToIndex(pos.i - 1, pos.j - 1);
      default:
        return grid.ijToIndex(pos.i, pos.j);
    }
  }

  @override
  bool moveNext() {
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

    return true;
  }
}

class FieldsAroundPosition extends IterableBase<int> {
  late Grid grid;
  late int index;

  FieldsAroundPosition({required this.grid, required this.index});

  @override
  Iterator<int> get iterator => FieldsAroundPositionIterator(
        grid: grid,
        index: index,
      );
}
