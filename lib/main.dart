import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets.dart';
import 'classes.dart';
import 'helpers.dart';
import 'grid.dart';

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

  late Grid grid;
  late int time;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // TODO: load user settings from storage??

    prepareGame();
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
                          grid.flagsLeft.toString(),
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
                        aspectRatio: grid.columns / grid.rows,
                        child: GameArea(
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

  void prepareGame([GameSettings? s]) {
    s ??= GameSettings(
      columns: 10,
      rows: 10,
      bombs: 10,
    );

    grid = Grid(sett: s);

    time = 0;
    resetTimer();
  }

  // FieldPosition indexToij(int index, int columns) {
  //   return FieldPosition(index ~/ columns, index % columns);
  // }

  // int ijToIndex(int i, int j, int columns) {
  //   return i * columns + j;
  // }

  void firstTap(int index) {
    // generate bombs
    grid.generateBombs(index);

    // start timer
    startTimer();
  }

  void handleFieldTap(int index) {
    setState(() {
      grid.tap(index);
    });

    if (grid.at(index).isBomb) {
      // tempExplode(index);
      gameOver();
    } else if (grid.clicked + grid.bombs == grid.fields) {
      gameWon();
    }
  }

  void handleFieldLongPress(int index) {
    setState(() {
      grid.flag(index);
    });
    HapticFeedback.selectionClick();
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

    grid.lock();
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

    grid.lock();
  }

  void resetGame() {
    setState(() {
      prepareGame();
    });
  }

  void openSettings() {
    final _controllers = [for (var i = 0; i < 3; i++) TextEditingController()];
    final _formKey = GlobalKey<FormState>();
    var sett = grid.settings;

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
          if (grid.locked) {
            timer.cancel();
          } else {
            time++;
          }
        });
      },
    );
  }
}
