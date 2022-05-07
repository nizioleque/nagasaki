import 'package:flutter/material.dart';

import '../constants.dart';
import '../helpers.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
    this.backgroundColor = Constants.backgroundColor,
    this.borderTopColor = Constants.borderTopColor,
    this.borderBottomColor = Constants.borderBottomColor,
  }) : super(key: key);

  final String title;
  final Widget content;
  final List<Widget> actions;

  final Color backgroundColor;
  final Color borderTopColor;
  final Color borderBottomColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor,
      shape: outsetBorder(
        10.0,
        borderTopColor,
        borderBottomColor,
        // borderRadius: BorderRadius.circular(20.0),
      ), //this right here
      child: SizedBox(
        width: 260,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 18.0,
            horizontal: 32.0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    fontSize: 32,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: content,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: actions,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomDialogRow extends StatelessWidget {
  const CustomDialogRow({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 30,
          ),
        ),
      ],
    );
  }
}
