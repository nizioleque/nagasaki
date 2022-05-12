import 'package:flutter/material.dart';
import 'package:nagasaki/helpers.dart';

import '../constants.dart';

class HeaderButton extends StatefulWidget {
  const HeaderButton({
    Key? key,
    required this.onTap,
    required this.child,
    required this.borderWidth,
  }) : super(key: key);

  final void Function() onTap;
  final Widget child;
  final double borderWidth;

  @override
  State<HeaderButton> createState() => _HeaderButtonState();
}

class _HeaderButtonState extends State<HeaderButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.4,
      child: GestureDetector(
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
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: pressed
                    ? Constants.headerButtonPressedColor
                    : Constants.headerButtonColor,
                border: outsetBorder(
                  widget.borderWidth,
                  pressed
                      ? Constants.headerButtonBorderTopPressedColor
                      : Constants.headerButtonBorderTopColor,
                  pressed
                      ? Constants.headerButtonBorderBottomPressedColor
                      : Constants.headerButtonBorderBottomColor,
                ),
              ),
              child: FractionallySizedBox(
                heightFactor: 0.9,
                child: FittedBox(
                  child: widget.child,
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
    required this.textSize,
    required this.textPadding,
  }) : super(key: key);

  final int value;
  final String labelText;
  final double textSize;
  final double textPadding;

  // static const height = 55.0;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _getChildren(value),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: textPadding),
            child: Text(
              labelText.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                fontSize: textSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getChildren(int value) {
    if (value >= 1000) {
      return [
        Image.asset('assets/images/digital_9.png'),
        Image.asset('assets/images/digital_9.png'),
        Image.asset('assets/images/digital_9.png'),
      ];
    }
    if (value >= 100) {
      return [
        Image.asset('assets/images/digital_${value ~/ 100}.png'),
        Image.asset('assets/images/digital_${(value % 100) ~/ 10}.png'),
        Image.asset('assets/images/digital_${value % 10}.png'),
      ];
    }
    if (value >= 10) {
      return [
        Image.asset('assets/images/digital_null.png'),
        Image.asset('assets/images/digital_${(value % 100) ~/ 10}.png'),
        Image.asset('assets/images/digital_${value % 10}.png'),
      ];
    }
    return [
      Image.asset('assets/images/digital_null.png'),
      Image.asset('assets/images/digital_null.png'),
      Image.asset('assets/images/digital_$value.png'),
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

class ConstrainedHeightFlexible extends StatelessWidget {
  final double minHeight;
  final double maxHeight;
  final int flex;
  final int flexSum;
  final Widget child;
  final BoxConstraints outerConstraints;
  const ConstrainedHeightFlexible(
      {Key? key,
      required this.minHeight,
      required this.maxHeight,
      required this.flex,
      required this.flexSum,
      required this.outerConstraints,
      required this.child})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: minHeight,
        maxHeight: maxHeight,
      ),
      child: SizedBox(
        height: _getHeight(outerConstraints.maxHeight),
        child: child,
      ),
    );
  }

  double _getHeight(double outerContainerHeight) {
    return outerContainerHeight * flex / flexSum;
  }
}

class ConstrainedWidthFlexible extends StatelessWidget {
  final double minWidth;
  final double maxWidth;
  final int flex;
  final int flexSum;
  final Widget child;
  final BoxConstraints outerConstraints;
  const ConstrainedWidthFlexible(
      {Key? key,
      required this.minWidth,
      required this.maxWidth,
      required this.flex,
      required this.flexSum,
      required this.outerConstraints,
      required this.child})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
      ),
      child: SizedBox(
        width: _getWidth(outerConstraints.maxWidth),
        child: child,
      ),
    );
  }

  double _getWidth(double outerContainerWidth) {
    return outerContainerWidth * flex / flexSum;
  }
}
