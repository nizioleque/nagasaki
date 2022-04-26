import 'package:flutter/material.dart';

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
  final int nBombs = 30;

  late List<List<FieldData>> grid;

  @override
  void initState() {
    super.initState();

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
  }

  @override
  Widget build(BuildContext context) {
    var bombsLeft = nBombs;

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
                      onPressed: resetGame(),
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

  int countBombsAround(List<List<FieldData>> grid, int i, int j) {
    int counter = 0;
    if (i - 1 > 0 && j - 1 > 0 && grid[i - 1][j - 1].isBomb) {
      counter++;
    }
    if (i - 1 > 0 && grid[i - 1][j].isBomb) {
      counter++;
    }
    if (i - 1 > 0 && j + 1 < columns && grid[i - 1][j + 1].isBomb) {
      counter++;
    }
    if (j - 1 > 0 && grid[i][j - 1].isBomb) {
      counter++;
    }
    if (j + 1 < columns && grid[i][j + 1].isBomb) {
      counter++;
    }
    if (i + 1 < rows && j - 1 > 0 && grid[i + 1][j - 1].isBomb) {
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

  handleFieldTap(int i, int j) {
    debugPrint('[handleFieldTap] $i, $j');

    if (!grid[i][j].isVisible) {
      setState(() {
        grid[i][j].isVisible = true;
      });
    }

    if (grid[i][j].isBomb) gameOver();
  }

  handleFieldLongPress(int i, int j) {
    debugPrint('[handleLongPressTap] $i, $j');

    // mark as bomb / question mark
  }

  gameOver() {
    debugPrint('Game Over!');
  }

  resetGame() {}

  settings() {}
}

class FieldData {
  bool isBomb;
  bool isVisible;
  int bombsAround;

  FieldData([
    this.isBomb = false,
    this.isVisible = false,
    this.bombsAround = 0,
  ]);
}

class FieldChangeData {
  int index;
  PressType pressType;

  FieldChangeData(
    this.index,
    this.pressType,
  );
}

enum PressType {
  tap,
  longPress,
}

// grid widget class
class GameArea extends StatelessWidget {
  const GameArea({
    Key? key,
    required this.columns,
    required this.rows,
    required this.grid,
    required this.onChanged,
  }) : super(key: key);

  final int columns;
  final int rows;
  final List<List<FieldData>> grid;
  final ValueChanged<FieldChangeData> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      padding: const EdgeInsets.all(0),
      childAspectRatio: 1,
      children: List.generate(
        rows * columns,
        (index) => Field(
          data: grid[index ~/ columns][index % columns],
          handleTap: (bool b) {
            debugPrint('[GameArea] detected tap');
            onChanged(FieldChangeData(index, PressType.tap));
          },
          handleLongPress: (bool b) {
            debugPrint('[GameArea] detected long press');
            onChanged(FieldChangeData(index, PressType.longPress));
          },
        ),
      ),
    );
  }
}

class Field extends StatelessWidget {
  const Field({
    Key? key,
    required this.handleTap,
    required this.handleLongPress,
    required this.data,
  }) : super(key: key);

  final ValueChanged<bool> handleTap;
  final ValueChanged<bool> handleLongPress;
  final FieldData data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        debugPrint('[Field] detected tap');
        handleTap(false);
      },
      onLongPress: () {
        debugPrint('[Field] detected long press');
        handleLongPress(false);
      },
      child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            decoration: BoxDecoration(
              color: data.isBomb ? Colors.orange : Colors.grey,
              border: data.isVisible ? null : Border.all(width: 4.0),
            ),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                data.bombsAround.toString(),
              ),
            ),
          )),
    );
  }
}
