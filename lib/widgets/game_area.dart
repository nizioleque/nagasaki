import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nagasaki/constants.dart';
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
  static const clickedOffset = 0.6;

  @override
  State<Field> createState() => _FieldState();
}

class _FieldState extends State<Field> {
  Timer? longPressTimer;

  @override
  Widget build(BuildContext context) {
    String imageName = 'field_hidden';

    if (widget.data.isClicked) {
      imageName = 'field_null';
      if (!widget.data.isBomb && widget.data.state == FieldState.flagged) {
        imageName = 'field_wrong';
      } else if (!widget.data.isBomb && widget.data.bombsAround > 0) {
        imageName = 'field_${widget.data.bombsAround}';
      } else if (widget.data.isBomb) {
        if (widget.data.state == FieldState.flagged) {
          imageName = 'field_correct';
        } else {
          imageName = 'field_wrong';
        }
      }
    }

    Image backgroundImage = CachedData.images[imageName]!;

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
          image: backgroundImage.image,
          fit: BoxFit.cover,
        )),
        child: Stack(
          alignment: AlignmentDirectional.center,
          fit: StackFit.expand,
          children: [
            if (widget.data.isBomb && widget.data.isClicked)
              const FieldImage(
                img: 'bomb',
                clicked: true,
              ),
            if (widget.data.state == FieldState.flagged &&
                !widget.data.isClicked)
              const FieldImage(
                img: 'flag',
                clicked: false,
              ),
            if (widget.data.state == FieldState.sus && !widget.data.isClicked)
              const FieldImage(
                img: 'mark',
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
    required this.img,
    required this.clicked,
  }) : super(key: key);

  final String img;
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
      child: FittedBox(
        child: CachedData.images[img],
        fit: BoxFit.contain,
      ),
    );
  }
}
