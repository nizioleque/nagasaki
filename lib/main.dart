import 'package:flutter/material.dart';
import 'widgets.dart';
import 'classes.dart';

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
  final int rows = 10;
  final int columns = 10;
  final int nBombs = 10;

  late bool blockGrid = false;
  late List<List<FieldData>> grid;
  late int bombsLeft;
  late int clickedFields = 0;

  @override
  void initState() {
    super.initState();
    prepareGrid();
  }

  @override
  Widget build(BuildContext context) {
    // return widget
    return Scaffold(
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
                    ElevatedButton(
                      onPressed: settings(),
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
                        aspectRatio: columns / rows,
                        child: GameArea(
                          columns: columns,
                          rows: rows,
                          grid: grid,
                          onChanged: (FieldChangeData data) {
                            debugPrint(
                                '[HomePage] onChanged, index: ${data.index}, type: ${data.pressType}');
                            int i = data.index ~/ columns;
                            int j = data.index % columns;
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

  void prepareGrid() {
    // create a 2D table for the grid and initialize with default BombBoxes
    grid = List.generate(rows, (i) {
      return List.generate(columns, (j) {
        return FieldData();
      });
    });

    // select random coordinates and add bombs
    var randomPicker = List<int>.generate(rows * columns, (i) => i)..shuffle();
    for (var i = 0; i < nBombs; i++) {
      var index = randomPicker.removeLast();
      grid[index ~/ columns][index % columns].isBomb = true;
    }

    // count bombs
    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < columns; j++) {
        grid[i][j].bombsAround = countBombsAround(grid, i, j);
      }
    }

    bombsLeft = nBombs;
  }

  int countBombsAround(List<List<FieldData>> grid, int i, int j) {
    int counter = 0;
    if (i - 1 >= 0 && j - 1 >= 0 && grid[i - 1][j - 1].isBomb) {
      counter++;
    }
    if (i - 1 >= 0 && grid[i - 1][j].isBomb) {
      counter++;
    }
    if (i - 1 >= 0 && j + 1 < columns && grid[i - 1][j + 1].isBomb) {
      counter++;
    }
    if (j - 1 >= 0 && grid[i][j - 1].isBomb) {
      counter++;
    }
    if (j + 1 < columns && grid[i][j + 1].isBomb) {
      counter++;
    }
    if (i + 1 < rows && j - 1 >= 0 && grid[i + 1][j - 1].isBomb) {
      counter++;
    }
    if (i + 1 < rows && grid[i + 1][j].isBomb) {
      counter++;
    }
    if (i + 1 < rows && j + 1 < columns && grid[i + 1][j + 1].isBomb) {
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

    /* if (!grid[i][j].isVisible) {
      setState(() {
        grid[i][j].isVisible = true;
      });
    } */

    if (!grid[i][j].isClicked) {
      setState(() {
        makeFieldVisible(i, j);
      });
    }
    debugPrint('$clickedFields clicked fields');
    if (clickedFields + nBombs == columns * rows) gameWon();
    if (grid[i][j].isBomb) gameOver();
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

      // prevent this from running many times!
      debugPrint('flagged mine $i, $j');
      setState(() {
        grid[i][j].isFlagged = true;
        bombsLeft--;
      });
      // if there is flag already, remove it
    } else if (grid[i][j].isFlagged) {
      debugPrint('removed flag $i $j');
      setState(() {
        grid[i][j].isFlagged = false;
        bombsLeft++;
      });
    }
  }

  void gameOver() {
    debugPrint('Game Over!');
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('GAME OVER'),
        content: const Text("You've hit a bomb!"),
        backgroundColor: Colors.red,
      ),
    );
    blockGrid = true;
  }

  void gameWon() {
    debugPrint('You Won!');
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text("YOU WON"),
              content: const Text("You've found all bombs!"),
              backgroundColor: Colors.lightGreen,
            ));
    blockGrid = true;
  }

  void resetGame() {
    setState(() {
      prepareGrid();
      blockGrid = false;
      clickedFields = 0;
    });
  }

  settings() {}

  void makeFieldVisible(int i, int j) {
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
      if (i - 1 >= 0 && j + 1 < columns && !grid[i - 1][j + 1].isClicked) {
        makeFieldVisible(i - 1, j + 1);
      }
      if (j - 1 >= 0 && !grid[i][j - 1].isClicked) {
        makeFieldVisible(i, j - 1);
      }
      if (j + 1 < columns && !grid[i][j + 1].isClicked) {
        makeFieldVisible(i, j + 1);
      }
      if (i + 1 < rows && j - 1 >= 0 && !grid[i + 1][j - 1].isClicked) {
        makeFieldVisible(i + 1, j - 1);
      }
      if (i + 1 < rows && !grid[i + 1][j].isClicked) {
        makeFieldVisible(i + 1, j);
      }
      if (i + 1 < rows && j + 1 < columns && !grid[i + 1][j + 1].isClicked) {
        makeFieldVisible(i + 1, j + 1);
      }
    }
  }
}
