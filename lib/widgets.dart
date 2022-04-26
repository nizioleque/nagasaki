import 'package:flutter/material.dart';
import 'classes.dart';

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

// field widget class
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
    var color = data.isBomb
        ? (data.isFlagged ? Colors.green : Colors.orange)
        : Colors.grey;

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
              color: color,
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
