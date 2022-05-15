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

  late List<Image> toLoad;

  @override
  void initState() {
    super.initState();
    loadImages();
    WidgetsBinding.instance?.addObserver(this);
    loadState();
    Settings.loadPreferences();
    // .then((value) => enableSound = value.soundOn);
  }

  @override
  void didChangeDependencies() {
    for (var element in toLoad) {
      
      precacheImage(element.image, context);
    }
    super.didChangeDependencies();
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
    var deviceSize = MediaQuery.of(context).size.shortestSide;
    // debugPrint(deviceSize.toString());

    // double scaledSize(double size) {
    //   return deviceSize.shortestSide * size / 500;
    // }

    // return widget
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: const Color(0xffD9D9D9),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double height = constraints.maxHeight / Constants.headerFlex;

              // make the header shorter if it's too narrow
              if (constraints.maxWidth / height < Constants.minAspectRatio) {
                height = constraints.maxWidth / Constants.minAspectRatio;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: Constants.maxHeaderHeight,
                    ),
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: Constants.backgroundColor,
                        border: outsetBorder(
                          deviceSize * Constants.mainBorderWidth,
                          Constants.borderBottomColor,
                          Constants.borderTopColor,
                        ),
                      ),
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, childConstraints) {
                            double height = childConstraints.maxHeight;
                            double width = Constants.maxAspectRatio * height;

                            double scaledSize(double size) {
                              return height * size / 100;
                            }

                            return SizedBox(
                              width: width,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  HeaderButton(
                                    onTap: resetGame,
                                    child: const Icon(Icons.refresh),
                                    height: scaledSize(40.0),
                                  ),
                                  HeaderCounter(
                                    value: dataLoaded ? grid.flagsLeft : 0,
                                    labelText: "bombs",
                                    height: scaledSize(100),
                                  ),
                                  HeaderCounter(
                                    value: dataLoaded ? grid.time : 0,
                                    labelText: "timer",
                                    height: scaledSize(100),
                                  ),
                                  HeaderButton(
                                    onTap: tapSettings,
                                    child: const Icon(Icons.settings),
                                    height: scaledSize(40.0),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: Constants.headerFlex - 1,
                    child: Container(
                      color: Constants.backgroundColor,
                      child: Center(
                        child: dataLoaded
                            ? Container(
                                decoration: BoxDecoration(
                                  border: outsetBorder(
                                    deviceSize * Constants.mainBorderWidth,
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
              );
            },
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

  void loadImages() {
    toLoad = <Image>[];
    toLoad.add(Image.asset('assets/images/digital_null.png'));
    for (int i = 0; i < 10; i++) {
      toLoad.add(Image.asset('assets/images/digital_$i.png'));
    }
    toLoad.add(Image.asset('assets/images/field_null.png'));
    for (int i = 1; i < 9; i++) {
      toLoad.add(Image.asset('assets/images/field_$i.png'));
    }
    toLoad.add(Image.asset('assets/images/bomb.png'));
    toLoad.add(Image.asset('assets/images/flag.png'));
    toLoad.add(Image.asset('assets/images/mark.png'));
    toLoad.add(Image.asset('assets/images/button.png'));
    toLoad.add(Image.asset('assets/images/button-pressed.png'));
    toLoad.add(Image.asset('assets/images/field_hidden.png'));
    toLoad.add(Image.asset('assets/images/field_correct.png'));
    toLoad.add(Image.asset('assets/images/field_wrong.png'));
  }
}
