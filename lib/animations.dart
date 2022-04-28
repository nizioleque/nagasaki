  // void explode(int index) {
  //   var pos = indexToij(index, sett.columns);
  //   int time = 1000;
  //   var miliseconds = Duration(milliseconds: time ~/ sett.bombs);
  //   int k = 0;
  //   Timer timer = Timer.periodic(miliseconds, (Timer timer) {
  //     if (k == bombs.length) {
  //       setState(() {
  //         timer.cancel();
  //         gameOver();
  //       });
  //     } else {
  //       if (bombs.elementAt(k).i == pos.i && bombs.elementAt(k).j == pos.j) k++;
  //       setState(() {
  //         debugPrint("boom");
  //         grid[ijToIndex(
  //                 bombs.elementAt(k).i, bombs.elementAt(k).j, sett.columns)]
  //             .isClicked = true;
  //       });
  //       // }

  //       k++;
  //     }
  //   });
  // }

  // void tempExplode(int index) {
  //   var pos = indexToij(index, sett.columns);
  //   var i = pos.i;
  //   var j = pos.j;

  //   var oneSec = Duration(milliseconds: 10);
  //   List<FieldPosition> aboutToDelete = List<FieldPosition>.empty();
  //   aboutToDelete = aboutToDelete.toList();
  //   aboutToDelete.add(FieldPosition(i, j));
  //   Timer timer = Timer.periodic(oneSec, (Timer timer) {
  //     if (deletedFields == sett.rows * sett.columns) {
  //       setState(() {
  //         timer.cancel();
  //         gameOver();
  //       });
  //     } else {
  //       debugPrint("$deletedFields deleted fields");
  //       List<FieldPosition> temp = List<FieldPosition>.empty();
  //       temp = temp.toList();
  //       aboutToDelete.forEach((element) {
  //         if (element.i - 1 >= 0 &&
  //             !grid[ijToIndex(element.i - 1, element.j, sett.columns)]
  //                 .isDeleted) {
  //           grid[ijToIndex(element.i - 1, element.j, sett.columns)].isDeleted =
  //               true;
  //           temp.add(FieldPosition(element.i - 1, element.j));
  //         }
  //         if (element.i + 1 < sett.rows &&
  //             !grid[ijToIndex(element.i + 1, element.j, sett.columns)]
  //                 .isDeleted) {
  //           grid[ijToIndex(element.i + 1, element.j, sett.columns)].isDeleted =
  //               true;
  //           temp.add(FieldPosition(element.i + 1, element.j));
  //         }
  //         if (element.j - 1 >= 0 &&
  //             !grid[ijToIndex(element.i, element.j - 1, sett.columns)]
  //                 .isDeleted) {
  //           grid[ijToIndex(element.i, element.j - 1, sett.columns)].isDeleted =
  //               true;
  //           temp.add(FieldPosition(element.i, element.j - 1));
  //         }
  //         if (element.j + 1 < sett.columns &&
  //             !grid[ijToIndex(element.i, element.j + 1, sett.columns)]
  //                 .isDeleted) {
  //           grid[ijToIndex(element.i, element.j + 1, sett.columns)].isDeleted =
  //               true;
  //           temp.add(FieldPosition(element.i, element.j + 1));
  //         }
  //       });
  //       setState(() {
  //         aboutToDelete.forEach((element) {
  //           grid[ijToIndex(element.i, element.j, sett.columns)].isClicked =
  //               true;
  //           grid[ijToIndex(element.i, element.j, sett.columns)].isDeleted =
  //               true;
  //           deletedFields++;
  //         });
  //       });
  //       aboutToDelete = temp;
  //     }
  //   });
  // }

  // void waitForExplosion() {
  //   int start = 10000;
  //   var milisecond = Duration(milliseconds: 10000 ~/ sett.bombs);
  //   Timer timer = Timer.periodic(milisecond, (Timer timer) {
  //     if (start < 0) {
  //       setState(() {
  //         timer.cancel();
  //         gameOver();
  //       });
  //     } else {
  //       setState(() {
  //         start -= 1000 ~/ sett.bombs;
  //       });
  //     }
  //   });
  // }