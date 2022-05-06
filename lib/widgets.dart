import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'classes.dart';
import 'grid.dart';
import 'helpers.dart';

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
    String backgroundImage = 'assets/images/field-hidden.png';

    if (widget.data.isClicked) {
      backgroundImage = 'assets/images/field-0.png';
      if (!widget.data.isBomb && widget.data.bombsAround > 0) {
        backgroundImage = 'assets/images/field-${widget.data.bombsAround}.png';
      }
    }

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

class HeaderButton extends StatefulWidget {
  const HeaderButton({
    Key? key,
    required this.onTap,
    required this.child,
  }) : super(key: key);

  final void Function() onTap;
  final Widget child;

  @override
  State<HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<HeaderButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) {
        setState(() {
          pressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          pressed = false;
        });
      },
      child: Container(
        child: widget.child,
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: pressed
                ? const AssetImage('assets/images/button-pressed.png')
                : const AssetImage('assets/images/button.png'),
          ),
        ),
      ),
    );
  }
}

class HeaderCounter extends StatelessWidget {
  const HeaderCounter({
    Key? key,
    required this.dataText,
    required this.labelText,
  }) : super(key: key);

  final String dataText;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).textScaleFactor;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          // width: 105.0 * h,
          decoration: BoxDecoration(
            border: outsetBorder(
              4.0,
              const Color.fromARGB(255, 102, 56, 56),
              const Color.fromARGB(255, 20, 20, 20),
            ),
            color: const Color(0xff440000),
          ),
          child: Stack(
            alignment: Alignment.centerRight,
            fit: StackFit.loose,
            children: [
              CounterText(dataText: dataText, visible: true),
              const CounterText(dataText: "888", visible: false),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            labelText.toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class CounterText extends StatelessWidget {
  const CounterText({
    Key? key,
    required this.dataText,
    required this.visible,
  }) : super(key: key);

  final String dataText;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Text(
      dataText,
      textAlign: TextAlign.end,
      style: TextStyle(
        fontSize: 50,
        color: visible ? const Color(0xffff0000) : Colors.transparent,
        fontWeight: FontWeight.w700,
        height: 0.9,
        letterSpacing: 1.2,
      ),
    );
  }
}
