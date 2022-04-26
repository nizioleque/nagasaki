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
  final int nBombs = 10;

  @override
  Widget build(BuildContext context) {
    
    // create a 2D table for the grid and initialize with default BombBoxes
    List<List<BombBox>> grid = List.generate(rows, (i) {
      return List.generate(columns, (j) {
        return BombBox();
      });
    });

    // select random coordinates and add bombs
    var randomPicker = List<int>.generate(rows * columns, (i) => i)..shuffle();
    for (var i = 0; i < nBombs; i++) {
      var index = randomPicker.removeLast();
      grid[index ~/ columns][index % columns].isBomb = true;
    }

    var bombsLeft = nBombs;

    // return widget
    return Scaffold(
      body: Column(
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: AspectRatio(
                  aspectRatio: columns / rows,
                  child: GameArea(columns: columns, rows: rows, grid: grid),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  resetGame() {}

  settings() {}
}

class BombBox {
  bool isBomb;
  bool isVisible;
  int bombsAround;

  BombBox([this.isBomb = false, this.isVisible = false, this.bombsAround = 0]);

  getWidget() {
    var fillColor = isBomb ? Colors.red : Colors.grey;

    return Container(
      decoration: BoxDecoration(
        color: fillColor,
        border: isVisible ? null : Border.all(width: 4.0),
      ),
    );
  }
}

// grid widget class
class GameArea extends StatelessWidget {
  const GameArea(
      {Key? key, required this.columns, required this.rows, required this.grid})
      : super(key: key);

  final int columns;
  final int rows;
  final List<List<BombBox>> grid;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      childAspectRatio: 1,
      children: List.generate(
        rows * columns,
        (index) => Padding(
          padding: const EdgeInsets.all(2.0),
          child: grid[index ~/ columns][index % columns].getWidget(),
        ),
      ),
    );
  }
}
