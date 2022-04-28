import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets.dart';
import 'classes.dart';
import 'helpers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // final int rows = 10;
  // final int columns = 10;
  // final int nBombs = 4;

  late bool blockGrid;
  late List<FieldData> grid;
  late int bombsLeft;
  late int clickedFields;
  late int deletedFields;
  late int time;
  late int flaggedFields;
  Timer? timer;
  late bool timerActive;
  late GameSettings sett;
  late Set<FieldPosition> bombs;

  @override
  void initState() {
    super.initState();

    // TODO: load user settings from storage??
    sett = GameSettings(
      columns: 10,
      rows: 10,
      bombs: 10,
    );

    prepareGame(sett);
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // return widget
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: Colors.grey,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 150,
                color: Colors.grey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: resetGame,
                      child: const Text("Reset"),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          bombsLeft.toString(),
                          style: const TextStyle(
                            fontSize: 50,
                          ),
                        ),
                        const Text("bombs"),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          time.toString(),
                          style: const TextStyle(
                            fontSize: 50,
                          ),
                        ),
                        const Text("time"),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: openSettings,
                      child: const Text("Settings"),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: sett.columns / sett.rows,
                        child: GameArea(
                          columns: sett.columns,
                          rows: sett.rows,
                          grid: grid,
                          onChanged: (FieldChangeData data) {
                            debugPrint(
                                '[HomePage] onChanged, index: ${data.index}, type: ${data.pressType}');
                            switch (data.pressType) {
                              case PressType.tap:
                                handleFieldTap(data.index);
                                break;
                              case PressType.longPress:
                                handleFieldLongPress(data.index);
                                break;
                              default:
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void prepareGame(GameSettings s) {
    sett = s;

    // create a 2D table for the grid and initialize with default BombBoxes
    grid = List.generate(s.rows * s.columns, (i) => FieldData());

    bombsLeft = s.bombs;
    blockGrid = false;
    time = 0;
    clickedFields = 0;
    deletedFields = 0;
    flaggedFields = 0;
    resetTimer();
  }

  FieldPosition indexToij(int index, int columns) {
    return FieldPosition(index ~/ columns, index % columns);
  }

  int ijToIndex(int i, int j, int columns) {
    return i * columns + j;
  }

  void firstTap(int index) {
    // select random coordinates and add bombs
    var rng = Random();
    var bombs = <int>{};
    var tapPos = indexToij(index, sett.columns);

    while (bombs.length != sett.bombs) {
      int randomNumber = rng.nextInt(sett.columns * sett.rows);
      var randomPos = indexToij(randomNumber, sett.columns);
      // check if i, j != first clicked field
      // to avoid generating a bomb under the user's finger
      if (!(randomPos.i >= tapPos.i - 1 &&
          randomPos.i <= tapPos.i + 1 &&
          randomPos.j >= tapPos.j - 1 &&
          randomPos.j <= tapPos.j + 1)) {
        bombs.add(randomNumber);
      }
    }

    for (var element in bombs) {
      grid[element].isBomb = true;
    }

    // count bombs
    for (var index = 0; index < sett.rows * sett.columns; index++) {
      grid[index].bombsAround = countBombsAround(grid, index);
    }

    // start timer
    startTimer();
  }

  int countBombsAround(List<FieldData> grid, int index) {
    int counter = 0;
    var pos = indexToij(index, sett.columns);

    if (pos.i - 1 >= 0 &&
        pos.j - 1 >= 0 &&
        grid[ijToIndex(pos.i - 1, pos.j - 1, sett.columns)].isBomb) {
      counter++;
    }
    if (pos.i - 1 >= 0 &&
        grid[ijToIndex(pos.i - 1, pos.j, sett.columns)].isBomb) {
      counter++;
    }
    if (pos.i - 1 >= 0 &&
        pos.j + 1 < sett.columns &&
        grid[ijToIndex(pos.i - 1, pos.j + 1, sett.columns)].isBomb) {
      counter++;
    }
    if (pos.j - 1 >= 0 &&
        grid[ijToIndex(pos.i, pos.j - 1, sett.columns)].isBomb) {
      counter++;
    }
    if (pos.j + 1 < sett.columns &&
        grid[ijToIndex(pos.i, pos.j + 1, sett.columns)].isBomb) {
      counter++;
    }
    if (pos.i + 1 < sett.rows &&
        pos.j - 1 >= 0 &&
        grid[ijToIndex(pos.i + 1, pos.j - 1, sett.columns)].isBomb) {
      counter++;
    }
    if (pos.i + 1 < sett.rows &&
        grid[ijToIndex(pos.i + 1, pos.j, sett.columns)].isBomb) {
      counter++;
    }
    if (pos.i + 1 < sett.rows &&
        pos.j + 1 < sett.columns &&
        grid[ijToIndex(pos.i + 1, pos.j + 1, sett.columns)].isBomb) {
      counter++;
    }
    return counter;
  }

  void handleFieldTap(int index) {
    // cant click if game over
    if (blockGrid) return;
    // cant click if flagged
    if (grid[index].isFlagged) return;

    // first click - generate bombs
    if (clickedFields == 0) {
      firstTap(index);
    }

    if (!grid[index].isClicked) {
      setState(() {
        makeFieldVisible(index);
      });
    }
    debugPrint('$clickedFields clicked fields');
    if (grid[index].isBomb) {
      tempExplode(index);
      // GameOver();
    } else if (clickedFields + sett.bombs == sett.columns * sett.rows) {
      gameWon();
    }
  }

  void handleFieldLongPress(int index) {
    // cant put flag when game over
    if (blockGrid) return;

    // cant put flag when clicked
    if (grid[index].isClicked) return;

    // mark as flagged / question mark
    if (!grid[index].isFlagged) {
      // reached maximum of flags
      if (flaggedFields == sett.bombs) return;

      // set flag
      setState(() {
        grid[index].isFlagged = true;
        flaggedFields++;
        bombsLeft--;
      });

      // haptic feedback
      HapticFeedback.selectionClick();
    } else {
      // if there is flag already, remove it
      setState(() {
        grid[index].isFlagged = false;
        flaggedFields--;
        bombsLeft++;
      });

      HapticFeedback.selectionClick();
    }
  }

  void gameOver() {
    debugPrint('Game Over!');
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => const AlertDialog(
        title: Text('GAME OVER'),
        content: Text("You've hit a bomb!"),
        backgroundColor: Colors.red,
      ),
    );
    blockGrid = true;
  }

  void gameWon() {
    debugPrint('You Won!');
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => const AlertDialog(
        title: Text("YOU WON"),
        content: Text("You've found all bombs!"),
        backgroundColor: Colors.lightGreen,
      ),
    );
    blockGrid = true;
  }

  void resetGame() {
    setState(() {
      prepareGame(sett);
    });
  }

  void openSettings() {
    final _controllers = [for (var i = 0; i < 3; i++) TextEditingController()];
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("SETTINGS"),
        contentPadding: const EdgeInsets.all(20.0),
        scrollable: true,
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsNumberField(
                controller: _controllers[0],
                validator: (value) => validateRange(value, 3, 30),
                text: "Columns",
              ),
              SettingsNumberField(
                controller: _controllers[1],
                validator: (value) => validateRange(value, 3, 30),
                text: "Rows",
              ),
              SettingsNumberField(
                  controller: _controllers[2],
                  validator: (value) {
                    try {
                      var fields = int.parse(_controllers[0].text) *
                          int.parse(_controllers[1].text);

                      return validateRange(value, 2, fields - 9);
                    } catch (e) {
                      return null;
                    }
                  },
                  text: "Mines"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // var newCol = int.parse(_controllers[i].text);
              if (_formKey.currentState!.validate()) {
                setState(() {
                  GameSettings newSettings = GameSettings(
                    columns: int.parse(_controllers[0].text),
                    rows: int.parse(_controllers[1].text),
                    bombs: int.parse(_controllers[2].text),
                  );
                  prepareGame(newSettings);
                });

                Navigator.of(context).pop();
              }
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );

    for (int i = 0; i < 3; i++) {
      int val;

      switch (i) {
        case 0:
          val = sett.columns;
          break;
        case 1:
          val = sett.rows;
          break;
        case 2:
          val = sett.bombs;
          break;
        default:
          val = 0;
      }

      var text = val.toString();

      _controllers[i].value = _controllers[i].value.copyWith(
            text: text,
            selection: TextSelection.collapsed(offset: text.length),
          );
    }
  }

  void makeFieldVisible(int index) {
    var pos = indexToij(index, sett.columns);

    if (grid[index].isFlagged) return;
    grid[index].isClicked = true;
    clickedFields++;
    if (grid[index].isBomb) return;
    if (grid[index].bombsAround == 0) {
      if (pos.i - 1 >= 0 &&
          pos.j - 1 >= 0 &&
          !grid[ijToIndex(pos.i - 1, pos.j - 1, sett.columns)].isClicked) {
        makeFieldVisible(ijToIndex(pos.i - 1, pos.j - 1, sett.columns));
      }
      if (pos.i - 1 >= 0 &&
          !grid[ijToIndex(pos.i - 1, pos.j, sett.columns)].isClicked) {
        makeFieldVisible(ijToIndex(pos.i - 1, pos.j, sett.columns));
      }
      if (pos.i - 1 >= 0 &&
          pos.j + 1 < sett.columns &&
          !grid[ijToIndex(pos.i - 1, pos.j + 1, sett.columns)].isClicked) {
        makeFieldVisible(ijToIndex(pos.i - 1, pos.j + 1, sett.columns));
      }
      if (pos.j - 1 >= 0 &&
          !grid[ijToIndex(pos.i, pos.j - 1, sett.columns)].isClicked) {
        makeFieldVisible(ijToIndex(pos.i, pos.j - 1, sett.columns));
      }
      if (pos.j + 1 < sett.columns &&
          !grid[ijToIndex(pos.i, pos.j + 1, sett.columns)].isClicked) {
        makeFieldVisible(ijToIndex(pos.i, pos.j + 1, sett.columns));
      }
      if (pos.i + 1 < sett.rows &&
          pos.j - 1 >= 0 &&
          !grid[ijToIndex(pos.i + 1, pos.j - 1, sett.columns)].isClicked) {
        makeFieldVisible(ijToIndex(pos.i + 1, pos.j - 1, sett.columns));
      }
      if (pos.i + 1 < sett.rows &&
          !grid[ijToIndex(pos.i + 1, pos.j, sett.columns)].isClicked) {
        makeFieldVisible(ijToIndex(pos.i + 1, pos.j, sett.columns));
      }
      if (pos.i + 1 < sett.rows &&
          pos.j + 1 < sett.columns &&
          !grid[ijToIndex(pos.i + 1, pos.j + 1, sett.columns)].isClicked) {
        makeFieldVisible(ijToIndex(pos.i + 1, pos.j + 1, sett.columns));
      }
    }
  }

  void resetTimer() {
    // cancel timer if already exists
    timer?.cancel();
  }

  void startTimer() {
    // create new timer
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        setState(() {
          if (blockGrid) {
            timer.cancel();
          } else {
            time++;
          }
        });
      },
    );
  }

  void explode(int index) {
    var pos = indexToij(index, sett.columns);
    int time = 1000;
    var miliseconds = Duration(milliseconds: time ~/ sett.bombs);
    int k = 0;
    Timer timer = Timer.periodic(miliseconds, (Timer timer) {
      if (k == bombs.length) {
        setState(() {
          timer.cancel();
          gameOver();
        });
      } else {
        if (bombs.elementAt(k).i == pos.i && bombs.elementAt(k).j == pos.j) k++;
        setState(() {
          debugPrint("boom");
          grid[ijToIndex(
                  bombs.elementAt(k).i, bombs.elementAt(k).j, sett.columns)]
              .isClicked = true;
        });
        // }

        k++;
      }
    });
  }

  void tempExplode(int index) {
    var pos = indexToij(index, sett.columns);
    var i = pos.i;
    var j = pos.j;

    var oneSec = Duration(milliseconds: 10);
    List<FieldPosition> aboutToDelete = List<FieldPosition>.empty();
    aboutToDelete = aboutToDelete.toList();
    aboutToDelete.add(FieldPosition(i, j));
    Timer timer = Timer.periodic(oneSec, (Timer timer) {
      if (deletedFields == sett.rows * sett.columns) {
        setState(() {
          timer.cancel();
          gameOver();
        });
      } else {
        debugPrint("$deletedFields deleted fields");
        List<FieldPosition> temp = List<FieldPosition>.empty();
        temp = temp.toList();
        aboutToDelete.forEach((element) {
          if (element.i - 1 >= 0 &&
              !grid[ijToIndex(element.i - 1, element.j, sett.columns)]
                  .isDeleted) {
            grid[ijToIndex(element.i - 1, element.j, sett.columns)].isDeleted =
                true;
            temp.add(FieldPosition(element.i - 1, element.j));
          }
          if (element.i + 1 < sett.rows &&
              !grid[ijToIndex(element.i + 1, element.j, sett.columns)]
                  .isDeleted) {
            grid[ijToIndex(element.i + 1, element.j, sett.columns)].isDeleted =
                true;
            temp.add(FieldPosition(element.i + 1, element.j));
          }
          if (element.j - 1 >= 0 &&
              !grid[ijToIndex(element.i, element.j - 1, sett.columns)]
                  .isDeleted) {
            grid[ijToIndex(element.i, element.j - 1, sett.columns)].isDeleted =
                true;
            temp.add(FieldPosition(element.i, element.j - 1));
          }
          if (element.j + 1 < sett.columns &&
              !grid[ijToIndex(element.i, element.j + 1, sett.columns)]
                  .isDeleted) {
            grid[ijToIndex(element.i, element.j + 1, sett.columns)].isDeleted =
                true;
            temp.add(FieldPosition(element.i, element.j + 1));
          }
        });
        setState(() {
          aboutToDelete.forEach((element) {
            grid[ijToIndex(element.i, element.j, sett.columns)].isClicked =
                true;
            grid[ijToIndex(element.i, element.j, sett.columns)].isDeleted =
                true;
            deletedFields++;
          });
        });
        aboutToDelete = temp;
      }
    });
  }

  void waitForExplosion() {
    int start = 10000;
    var milisecond = Duration(milliseconds: 10000 ~/ sett.bombs);
    Timer timer = Timer.periodic(milisecond, (Timer timer) {
      if (start < 0) {
        setState(() {
          timer.cancel();
          gameOver();
        });
      } else {
        setState(() {
          start -= 1000 ~/ sett.bombs;
        });
      }
    });
  }
}
