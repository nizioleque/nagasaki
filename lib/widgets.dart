import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
class Field extends StatefulWidget {
  const Field({
    Key? key,
    required this.handleTap,
    required this.handleLongPress,
    required this.data,
  }) : super(key: key);

  final ValueChanged<bool> handleTap;
  final ValueChanged<bool> handleLongPress;
  final FieldData data;

  // long press duration [miliseconds]
  static const longPressDuration = 200;

  @override
  State<Field> createState() => _FieldState();
}

class _FieldState extends State<Field> {
  Timer? longPressTimer;

  @override
  Widget build(BuildContext context) {
    var color = widget.data.isClicked
        ? (widget.data.isBomb ? Colors.red : Colors.grey)
        : (widget.data.isFlagged ? Colors.green : Colors.grey);

    return GestureDetector(
      onTap: () {
        debugPrint('[Field] detected tap');
        widget.handleTap(false);
      },
      onPanDown: (_) {
        longPressTimer = Timer(
          const Duration(milliseconds: Field.longPressDuration),
          () {
            debugPrint('[Field] detected long press');
            widget.handleLongPress(false);
          },
        );
      },
      onPanCancel: () {
        longPressTimer?.cancel();
      },
      child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              border: widget.data.isClicked ? null : Border.all(width: 4.0),
              image: widget.data.isBomb && widget.data.isClicked
                  ? const DecorationImage(
                      image: AssetImage('assets/images/bomb.png'),
                      // fit: BoxFit.fill,
                    )
                  : (widget.data.isFlagged
                      ? const DecorationImage(
                          image: AssetImage('assets/images/flag.png'),
                          // fit: BoxFit.fill,
                        )
                      : null),
            ),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                (widget.data.bombsAround > 0 &&
                        widget.data.isClicked &&
                        !widget.data.isBomb)
                    ? widget.data.bombsAround.toString()
                    : '',
              ),
            ),
          )),
    );
  }
}

// settings dialog number fields
class SettingsNumberField extends StatelessWidget {
  const SettingsNumberField({
    Key? key,
    required this.controller,
    required this.validator,
    required this.text,
  }) : super(key: key);

  final TextEditingController controller;
  final String? Function(String?) validator;
  final String text;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.always,
      validator: validator,
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: text,
      ),
    );
  }
}
