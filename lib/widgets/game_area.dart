import 'dart:async';

import 'package:flutter/material.dart';
import '../classes.dart';
import '../grid.dart';

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
            onChanged(FieldChangeData(index, PressType.tap));
          },
          handleLongPress: () {
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
  static const imgSizeFactorHidden = 0.6;
  static const imgSizeFactorClicked = 0.7;
  static const clickedOffset = 0.4;

  @override
  State<Field> createState() => _FieldState();
}

class _FieldState extends State<Field> {
  Timer? longPressTimer;

  @override
  Widget build(BuildContext context) {
    String backgroundImage = 'assets/images/field_hidden.png';

    if (widget.data.isClicked) {
      backgroundImage = 'assets/images/field_null.png';
      if (!widget.data.isBomb && widget.data.state == FieldState.flagged) {
        backgroundImage = 'assets/images/field_wrong.png';
        // TODO add numbers inside??
      } else if (!widget.data.isBomb && widget.data.bombsAround > 0) {
        backgroundImage = 'assets/images/field_${widget.data.bombsAround}.png';
      } else if (widget.data.isBomb) {
        if (widget.data.state == FieldState.flagged) {
          backgroundImage = 'assets/images/field_correct.png';
        } else {
          backgroundImage = 'assets/images/field_wrong.png';
        }
      }
    }

    return GestureDetector(
      onTapDown: (_) {
        // start long press timer
        longPressTimer = Timer(
          const Duration(milliseconds: Field.longPressDuration),
          () {
            // trigger long press
            widget.handleLongPress();
          },
        );
      },
      onTapUp: (_) {
        if (longPressTimer != null && longPressTimer!.isActive) {
          // if timer is active, cancel
          longPressTimer?.cancel();

          // trigger tap
          widget.handleTap();
        }
      },
      child: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.cover,
        )),
        child: Stack(
          alignment: AlignmentDirectional.center,
          fit: StackFit.expand,
          children: [
            if (widget.data.isBomb && widget.data.isClicked)
              const FieldImage(
                imgPath: 'assets/images/bomb.png',
                clicked: true,
              ),
            if (widget.data.state == FieldState.flagged &&
                !widget.data.isClicked)
              const FieldImage(
                imgPath: 'assets/images/flag.png',
                clicked: false,
              ),
            if (widget.data.state == FieldState.sus && !widget.data.isClicked)
              const FieldImage(
                imgPath: 'assets/images/mark.png',
                clicked: false,
              )
          ],
        ),
      ),
    );
  }
}

class FieldImage extends StatelessWidget {
  const FieldImage({
    Key? key,
    required this.imgPath,
    required this.clicked,
  }) : super(key: key);

  final String imgPath;
  final bool clicked;

  @override
  Widget build(BuildContext context) {
    final imgSizeFactor =
        clicked ? Field.imgSizeFactorClicked : Field.imgSizeFactorHidden;

    final alignment = clicked
        ? const Alignment(Field.clickedOffset, Field.clickedOffset)
        : Alignment.center;

    return FractionallySizedBox(
      heightFactor: imgSizeFactor,
      widthFactor: imgSizeFactor,
      alignment: alignment,
      child: Image(
        image: AssetImage(imgPath),
        fit: BoxFit.contain,
      ),
    );
  }
}
