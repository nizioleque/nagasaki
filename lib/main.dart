import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nagasaki/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets.dart';
import 'classes.dart';
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
  late Grid grid;
  late int time;
  Timer? timer;

  bool dataLoaded = false;

  @override
  void initState() {
    super.initState();

    grid = Grid(sett: GameSettings(bombs: 0, columns: 1, rows: 1));
    time = -1;
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
                      onPressed: dataLoaded ? resetGame : null,
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
                      onPressed: dataLoaded
                          ? () async {
                              List result = await openSettings(grid, context);
                              if (result[0] == true) {
                                setState(() {
                                  prepareGame(result[1]);
                                });
                              }
                            }
                          : null,
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

  Future<GameSettings> loadData() async {
    // obtain shared preferences
    debugPrint('loadData');
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // set value

    GameSettings settings = GameSettings(
      rows: prefs.getInt('rows') ?? 10,
      columns: prefs.getInt('columns') ?? 10,
      bombs: prefs.getInt('bombs') ?? 10,
    );

    return settings;
    // setState(() {
    //   prepareGame(settings);
    //   dataLoaded = true;
    // });
  }

  void prepareGame([GameSettings? s]) async {
    s = await loadData();

    debugPrint('loadEDData');

    // s ??= GameSettings(
    //   columns: 20,
    //   rows: 30,
    //   bombs: 500,
    // );

    setState(() {
      grid = Grid(sett: s);
      dataLoaded = true;
    });

    time = 0;
    resetTimer();
  }

  void firstTap(int index) {
    // generate bombs
    grid.generateBombs(index);

    // start timer
    startTimer();
  }

  void handleFieldTap(int index) {
    if (grid.clicked == 0) firstTap(index);

    bool success = true;
    setState(() {
      success = grid.tap(index);
    });
    if (!success) return;

    if (grid.at(index).isBomb) {
      // tempExplode(index);
      Timer.periodic(
        const Duration(milliseconds: 50),
        (Timer timer) {
          if (grid.explode(index)) {
            setState(() {});
          } else {
            timer.cancel();
            gameOver();
          }
        },
      );
      // gameOver();
    } else if (grid.clicked + grid.bombs == grid.fields) {
      gameWon();
    }
  }

  void handleFieldLongPress(int index) {
    bool success = true;
    setState(() {
      success = grid.flag(index);
    });
    if (!success) return;

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
