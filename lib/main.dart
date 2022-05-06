import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nagasaki/helpers.dart';
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
    return MaterialApp(
      home: const MyHomePage(),
      theme: ThemeData(
          textTheme: GoogleFonts.oxaniumTextTheme(
        Theme.of(context).textTheme,
      )),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  static const bgColor = Color(0xFFD4D4D4);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  late Grid grid;
  Timer? timer;
  bool active = true;
  bool dataLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    loadState();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    timer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("didChangeAPpLifecycleState, state: $state");

    if (active && state != AppLifecycleState.resumed) {
      debugPrint('app paused');

      saveState();
      active = false;

      // pause timer
      resetTimer();
    }

    if (!active && state == AppLifecycleState.resumed) {
      debugPrint('app resumed');
      // restart timer
      if (!grid.locked && grid.clicked > 0) startTimer();

      active = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // return widget
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: const Color(0xffD9D9D9),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 130,
                decoration: BoxDecoration(
                  color: MyHomePage.bgColor,
                  border: outsetBorder(
                    8.0,
                    const Color(0xffF2F2F2),
                    const Color(0xff7F7F7F),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    HeaderButton(
                      onTap: prepareGame,
                      child: const Icon(Icons.refresh),
                    ),
                    HeaderCounter(
                      dataText: dataLoaded ? grid.flagsLeft.toString() : "",
                      labelText: "bombs",
                    ),
                    HeaderCounter(
                      dataText: dataLoaded ? grid.time.toString() : "",
                      labelText: "timer",
                    ),
                    HeaderButton(
                      onTap: tapSettings,
                      child: const Icon(Icons.settings),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  color: MyHomePage.bgColor,
                  child: Center(
                    child: dataLoaded
                        ? AspectRatio(
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
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void prepareGame([GameSettings? s]) async {
    // get current settings if not supplied
    s ??= grid.settings;

    // set new grid
    setState(() {
      grid = Grid(sett: s!);
      dataLoaded = true;
    });

    resetTimer();
  }

  void saveState() async {
    debugPrint('saveState!!!');

    final prefs = await SharedPreferences.getInstance();

    try {
      String gridEncoded = jsonEncode(grid);
      prefs.setString('state', gridEncoded);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void loadState() async {
    debugPrint('loadState!!!');

    final prefs = await SharedPreferences.getInstance();

    var stateStr = prefs.getString('state') ?? '';

    if (stateStr == '') {
      debugPrint('EMPTY STATESTR');

      // new game
      setState(() {
        grid = Grid(sett: GameSettings());
        dataLoaded = true;
      });
      return;
    }

    // loading existing game
    var stateJson = jsonDecode(stateStr);
    var stateGrid = Grid.fromJson(stateJson);

    try {
      setState(() {
        grid = stateGrid;
        dataLoaded = true;

        if (!grid.locked && grid.clicked > 0) startTimer();
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        grid = Grid(sett: GameSettings());
        dataLoaded = true;
      });
    }
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
      grid.lock();

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

  void tapSettings() async {
    // don't react to clicks before user data is loaded
    if (!dataLoaded) return;

    // show settings
    List result = await openSettings(grid, context);

    if (result[0] == true) {
      // apply new settings
      setState(() {
        prepareGame(result[1]);
      });
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
            grid.time++;
          }
        });
      },
    );
  }
}
