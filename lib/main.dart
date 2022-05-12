import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nagasaki/settings.dart';
import 'helpers.dart';
import 'widgets/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'end_dialog.dart';
import 'widgets/game_area.dart';
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
    Settings.loadPreferences();
    // .then((value) => enableSound = value.soundOn);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    timer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (active && state != AppLifecycleState.resumed) {
      saveState();
      active = false;

      // pause timer
      resetTimer();
    }

    if (!active && state == AppLifecycleState.resumed) {
      // restart timer
      if (!grid.locked && grid.clicked > 0) startTimer();

      active = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;
    debugPrint(deviceSize.toString());

    // return widget
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: const Color(0xffD9D9D9),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ConstrainedHeightFlexible(
                  maxHeight: 1000,
                  minHeight: 100,
                  outerConstraints: constraints,
                  flex: 1,
                  flexSum: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Constants.backgroundColor,
                      border: outsetBorder(
                        8.0,
                        Constants.borderBottomColor,
                        Constants.borderTopColor,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        color: Colors.red,
                        child: AspectRatio(
                          aspectRatio: 5,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: FractionallySizedBox(
                                  heightFactor: 0.8,
                                  // widthFactor: 0.3,
                                  child: HeaderButton(
                                    onTap: resetGame,
                                    child: const Icon(Icons.refresh),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: FractionallySizedBox(
                                  heightFactor: 0.7,
                                  child: HeaderCounter(
                                    dataText: dataLoaded ? grid.flagsLeft : 0,
                                    labelText: "bombs",
                                  ),
                                ),
                              ),
                              Expanded(
                                child: FractionallySizedBox(
                                  heightFactor: 0.7,
                                  child: HeaderCounter(
                                    dataText: dataLoaded ? grid.time : 0,
                                    labelText: "timer",
                                  ),
                                ),
                              ),
                              Expanded(
                                child: FractionallySizedBox(
                                  heightFactor: 0.8,
                                  child: HeaderButton(
                                    onTap: tapSettings,
                                    child: const Icon(Icons.settings),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    color: Constants.backgroundColor,
                    child: Center(
                      child: dataLoaded
                          ? Container(
                              decoration: BoxDecoration(
                                border: outsetBorder(
                                  deviceSize.shortestSide / 50,
                                  Constants.borderBottomColor,
                                  Constants.borderTopColor,
                                ),
                              ),
                              child: AspectRatio(
                                aspectRatio: grid.columns / grid.rows,
                                child: GameArea(
                                  grid: grid,
                                  onChanged: (FieldChangeData data) {
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
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void resetGame({
    GameSettings? settings,
    bool? playSound,
  }) async {
    // get current settings if not supplied
    settings ??= grid.settings;

    playSound ??= grid.playSound;

    // set new grid
    setState(() {
      grid = Grid(sett: settings!, playSound: playSound!);
      dataLoaded = true;
    });

    resetTimer();
    saveState();
  }

  void saveState() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      String gridEncoded = jsonEncode(grid);
      prefs.setString('state', gridEncoded);
    } catch (e) {
      debugPrint(e.toString());
    }

    debugPrint('saved state');
  }

  void loadState() async {
    final prefs = await SharedPreferences.getInstance();

    var stateStr = prefs.getString('state') ?? '';

    if (stateStr == '') {
      // new game
      setState(() {
        grid = Grid(sett: const GameSettings(), playSound: true);
        dataLoaded = true;
      });
      return;
    }

    // loading existing game
    var stateJson = jsonDecode(stateStr);

    try {
      var stateGrid = Grid.fromJson(stateJson);
      setState(() {
        grid = stateGrid;
        dataLoaded = true;

        if (!grid.locked && grid.clicked > 0) startTimer();
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        grid = Grid(sett: const GameSettings(), playSound: true);
        dataLoaded = true;
      });
    }
  }

  void firstTap(int index, Grid grid) {
    grid.firstAction = false;
    // generate bombs
    grid.generateBombs(index);

    // start timer
    startTimer();
  }

  void handleFieldTap(int index) {
    if (grid.firstAction) firstTap(index, grid);

    bool success = true;
    setState(() {
      success = grid.tap(index);
    });

    if (!success) return;
    saveState();

    if (grid.at(index).isBomb) {
      grid.lock();

      Timer.periodic(
        const Duration(milliseconds: 50),
        (Timer timer) {
          if (grid.explode(index)) {
            setState(() {});
          } else {
            timer.cancel();
            gameEnd(false);
            saveState();
          }
        },
      );
      // gameOver();
    } else if (grid.clicked + grid.bombs == grid.fields) {
      gameEnd(true);
      saveState();
    }
  }

  void handleFieldLongPress(int index) {
    if (grid.firstAction) return;

    bool success = true;
    setState(() {
      success = grid.flag(index);
    });

    if (!success) return;
    saveState();

    HapticFeedback.selectionClick();
  }

  Future<void> gameEnd(bool success) async {
    grid.lock();
    var newGame = await showEndGameDialog(context, grid, success);
    if (newGame) resetGame();
  }

  void tapSettings() async {
    // don't react to clicks before user data is loaded
    if (!dataLoaded) return;

    // show settings
    SettingsChange result = await Settings.openSettings(context);

    if (result.soundChanged) {
      grid.playSound = result.newSound!;
      debugPrint('grid.playSound = ${grid.playSound}');
    }

    if (result.difficultyChanged) {
      // apply new settings
      setState(() {
        resetGame(
          settings: result.newSettings,
          playSound: grid.playSound,
        );
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
