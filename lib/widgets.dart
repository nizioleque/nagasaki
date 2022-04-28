import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'classes.dart';
import 'grid.dart';

// grid widget class
class GameArea extends StatelessWidget {
  const GameArea({
    Key? key,
    required this.grid,
    required this.onChanged,
  }) : super(key: key);

  final Grid grid;
  final ValueChanged<FieldChangeData> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: grid.columns,
      padding: const EdgeInsets.all(0),
      childAspectRatio: 1,
      children: List.generate(
        grid.fields,
        (index) => Field(
          data: grid.at(index),
          handleTap: () {
            debugPrint('[GameArea] detected tap');
            onChanged(FieldChangeData(index, PressType.tap));
          },
          handleLongPress: () {
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

  final void Function() handleTap;
  final void Function() handleLongPress;
  final FieldData data;

  // long press duration [miliseconds]
  static const longPressDuration = 200;

  // bomb/flag img scale
  static const imgSizeFactor = 0.7;

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
    // var color = widget.data.isBomb ? Colors.red : Colors.grey;

    return GestureDetector(
      onTapDown: (_) {
        // start long press timer
        longPressTimer = Timer(
          const Duration(milliseconds: Field.longPressDuration),
          () {
            // trigger long press
            debugPrint('[Field] detected long press');
            widget.handleLongPress();
          },
        );
      },
      onTapUp: (_) {
        if (longPressTimer != null && longPressTimer!.isActive) {
          // if timer is active, cancel
          longPressTimer?.cancel();

          // trigger tap
          debugPrint('[Field] detected tap');
          widget.handleTap();
        }
      },
      child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              border: widget.data.isClicked ? null : Border.all(width: 4.0),
            ),
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                if (widget.data.bombsAround > 0 &&
                    widget.data.isClicked &&
                    !widget.data.isBomb)
                  Text(
                    widget.data.bombsAround.toString(),
                  ),
                if (widget.data.isBomb && widget.data.isClicked)
                  const FieldImage(imgPath: 'assets/images/bomb.png'),
                if (widget.data.isFlagged)
                  const FieldImage(imgPath: 'assets/images/flag.png')
              ],
            ),
          )),
    );
  }
}

class FieldImage extends StatelessWidget {
  const FieldImage({
    Key? key,
    required this.imgPath,
  }) : super(key: key);

  final String imgPath;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: Field.imgSizeFactor,
      widthFactor: Field.imgSizeFactor,
      child: Image(
        image: AssetImage(imgPath),
        fit: BoxFit.contain,
      ),
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
