import 'package:flutter/material.dart';
import 'package:nagasaki/helpers.dart';

import '../constants.dart';

class HeaderButton extends StatefulWidget {
  const HeaderButton({
    Key? key,
    required this.onTap,
    required this.child,
    required this.height,
  }) : super(key: key);

  final void Function() onTap;
  final Widget child;
  final double height;

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
      onTapCancel: () {
        setState(() {
          pressed = false;
        });
      },
      child: Center(
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: pressed
                ? Constants.backgroundColorDark
                : Constants.backgroundColor,
            border: outsetBorder(
              widget.height * 0.12,
              pressed ? Constants.borderBottomColor : Constants.borderTopColor,
              pressed ? Constants.borderTopColor : Constants.borderBottomColor,
            ),
            // color: pressed
            //     ? Constants.headerButtonPressedColor
            //     : Constants.headerButtonColor,
            // border: outsetBorder(
            //   widget.height * 0.15,
            //   pressed
            //       ? Constants.headerButtonBorderTopPressedColor
            //       : Constants.headerButtonBorderTopColor,
            //   pressed
            //       ? Constants.headerButtonBorderBottomPressedColor
            //       : Constants.headerButtonBorderBottomColor,
            // ),
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: FractionallySizedBox(
              heightFactor: 0.9,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: pressed
                      ? Constants.headerButtonPressedColor
                      : Constants.headerButtonColor,
                  border: Border.all(
                    color: Colors.black,
                    width: widget.height * 0.04,
                  ),
                ),
                child: FractionallySizedBox(
                  heightFactor: 0.9,
                  // widthFactor: 0.9,
                  child: FittedBox(
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HeaderCounter extends StatelessWidget {
  const HeaderCounter({
    Key? key,
    required this.value,
    required this.labelText,
    required this.height,
  }) : super(key: key);

  final int value;
  final String labelText;

  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: height * 0.55,
          decoration: BoxDecoration(
            color: Colors.black,
            border: outsetBorder(
              height * 0.055,
              Constants.counterBorderTopColor,
              Constants.counterBorderBottomColor,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _getChildren(value),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: height * 0.06),
          child: Text(
            labelText.toUpperCase(),
            textScaleFactor: 1.0,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              fontSize: height * 0.14,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _getChildren(int value) {
    if (value >= 1000) {
      return [
        CachedData.images['digital_9']!,
        CachedData.images['digital_9']!,
        CachedData.images['digital_9']!,
      ];
    }
    if (value >= 100) {
      return [
        CachedData.images['digital_${value ~/ 100}']!,
        CachedData.images['digital_${(value % 100) ~/ 10}']!,
        CachedData.images['digital_${value % 10}']!,
      ];
    }
    if (value >= 10) {
      return [
        CachedData.images['digital_null']!,
        CachedData.images['digital_${(value % 100) ~/ 10}']!,
        CachedData.images['digital_${value % 10}']!,
      ];
    }
    return [
      CachedData.images['digital_null']!,
      CachedData.images['digital_null']!,
      CachedData.images['digital_$value']!,
    ];
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
    double h = MediaQuery.of(context).textScaleFactor;

    return SizedBox(
      height: 40 * h,
      child: Text(
        dataText,
        style: TextStyle(
          fontSize: 45,
          color: visible ? const Color(0xffFB0007) : Colors.transparent,
          fontWeight: FontWeight.w700,
          height: 1,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
