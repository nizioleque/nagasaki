import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
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
  late List<List<FieldData>> grid;
  late int bombsLeft;
  late int clickedFields;
  late int time;
  late int flaggedFields;
  Timer? timer;
  late bool timerActive;
  late GameSettings sett;

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
                            int i = data.index ~/ sett.columns;
                            int j = data.index % sett.columns;
                            switch (data.pressType) {
                              case PressType.tap:
                                handleFieldTap(i, j);
                                break;
                              case PressType.longPress:
                                handleFieldLongPress(i, j);
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
    grid = List.generate(s.rows, (i) {
      return List.generate(s.columns, (j) {
        return FieldData();
      });
    });

    bombsLeft = s.bombs;
    blockGrid = false;
    time = 0;
    clickedFields = 0;
    flaggedFields = 0;
    resetTimer();
  }

  int countBombsAround(List<List<FieldData>> grid, int i, int j) {
    int counter = 0;
    if (i - 1 >= 0 && j - 1 >= 0 && grid[i - 1][j - 1].isBomb) {
      counter++;
    }
    if (i - 1 >= 0 && grid[i - 1][j].isBomb) {
      counter++;
    }
    if (i - 1 >= 0 && j + 1 < sett.columns && grid[i - 1][j + 1].isBomb) {
      counter++;
    }
    if (j - 1 >= 0 && grid[i][j - 1].isBomb) {
      counter++;
    }
    if (j + 1 < sett.columns && grid[i][j + 1].isBomb) {
      counter++;
    }
    if (i + 1 < sett.rows && j - 1 >= 0 && grid[i + 1][j - 1].isBomb) {
      counter++;
    }
    if (i + 1 < sett.rows && grid[i + 1][j].isBomb) {
      counter++;
    }
    if (i + 1 < sett.rows &&
        j + 1 < sett.columns &&
        grid[i + 1][j + 1].isBomb) {
      counter++;
    }
    return counter;
  }

  void handleFieldTap(int i, int j) {
    debugPrint('[handleFieldTap] $i, $j');
    // cant click if game over
    if (blockGrid) return;
    // cant click if flagged
    if (grid[i][j].isFlagged) return;

    // first click - generate bombs
    if (clickedFields == 0) {
      generateBombs(i, j);
    }

    if (!grid[i][j].isClicked) {
      setState(() {
        makeFieldVisible(i, j);
      });
    }
    debugPrint('$clickedFields clicked fields');
    if (grid[i][j].isBomb) {
      gameOver();
    } else if (clickedFields + sett.bombs == sett.columns * sett.rows) {
      gameWon();
    }
  }

  void generateBombs([int? iTap, int? jTap]) {
    // select random coordinates and add bombs
    var rng = Random();
    Set<int> randomSet = <int>{};
    while (randomSet.length != sett.bombs) {
      int randomNumber = rng.nextInt(sett.columns * sett.rows);

      // check if i, j != first clicked field
      // to avoid generating a bomb under the user's finger
      int i = randomNumber ~/ sett.columns;
      int j = randomNumber % sett.columns;
      if (i != iTap || j != jTap) {
        randomSet.add(randomNumber);
      }
    }

    for (var element in randomSet) {
      grid[element ~/ sett.columns][element % sett.columns].isBomb = true;
    }

    // count bombs
    for (var i = 0; i < sett.rows; i++) {
      for (var j = 0; j < sett.columns; j++) {
        grid[i][j].bombsAround = countBombsAround(grid, i, j);
      }
    }
  }

  void handleFieldLongPress(int i, int j) {
    debugPrint('[handleLongPressTap] $i, $j');
    // cant put flag when game over
    if (blockGrid) return;
    // cant put flag when clicked
    if (grid[i][j].isClicked) return;
    // mark as bomb / question mark
    if (!grid[i][j].isFlagged) {
      // add flag?
      // reached maximum of flags
      if (flaggedFields == sett.bombs) return;
      // prevent this from running many times!
      debugPrint('flagged mine $i, $j');
      setState(() {
        grid[i][j].isFlagged = true;
        flaggedFields++;
        bombsLeft--;
      });
      // if there is flag already, remove it
    } else if (grid[i][j].isFlagged) {
      debugPrint('removed flag $i $j');
      setState(() {
        grid[i][j].isFlagged = false;
        flaggedFields--;
        bombsLeft++;
      });
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

                      return validateRange(value, 2, fields - 1);
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

  void makeFieldVisible(int i, int j) {
    if (grid[i][j].isFlagged) return;
    grid[i][j].isClicked = true;
    clickedFields++;
    if (grid[i][j].isBomb) return;
    if (grid[i][j].bombsAround == 0) {
      if (i - 1 >= 0 && j - 1 >= 0 && !grid[i - 1][j - 1].isClicked) {
        makeFieldVisible(i - 1, j - 1);
      }
      if (i - 1 >= 0 && !grid[i - 1][j].isClicked) {
        makeFieldVisible(i - 1, j);
      }
      if (i - 1 >= 0 && j + 1 < sett.columns && !grid[i - 1][j + 1].isClicked) {
        makeFieldVisible(i - 1, j + 1);
      }
      if (j - 1 >= 0 && !grid[i][j - 1].isClicked) {
        makeFieldVisible(i, j - 1);
      }
      if (j + 1 < sett.columns && !grid[i][j + 1].isClicked) {
        makeFieldVisible(i, j + 1);
      }
      if (i + 1 < sett.rows && j - 1 >= 0 && !grid[i + 1][j - 1].isClicked) {
        makeFieldVisible(i + 1, j - 1);
      }
      if (i + 1 < sett.rows && !grid[i + 1][j].isClicked) {
        makeFieldVisible(i + 1, j);
      }
      if (i + 1 < sett.rows &&
          j + 1 < sett.columns &&
          !grid[i + 1][j + 1].isClicked) {
        makeFieldVisible(i + 1, j + 1);
      }
    }
  }

  void resetTimer() {
    // cancel timer if already exists
    timer?.cancel();

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
}
