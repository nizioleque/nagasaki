import 'package:flutter/material.dart';
import 'package:nagasaki/main.dart';

import 'grid.dart';
import 'helpers.dart';

showEndGameDialog(BuildContext context, Grid grid, bool success) async {
  // showDialog<String>(
  //   context: context,
  //   builder: (BuildContext context) => AlertDialog(
  //     title: success ? const Text("YOU WON") : const Text("You lost"),
  //     content: success
  //         ? const Text("You've found all bombs!")
  //         : const Text("You've hit a bomb!"),
  //     backgroundColor: success ? Colors.lightGreen : Colors.red,
  //   ),
  // );

  await showDialog(
    context: context,
    builder: (BuildContext context) => CustomDialog(
      backgroundColor: MyHomePage.bgColor,
      borderTopColor: const Color(0xffF2F2F2),
      borderBottomColor: const Color(0xff7F7F7F),
      title: "You lost",
      content: Column(
        children: [
          CustomDialogRow(
            label: "Time",
            value: 100.toString(),
          ),
          const CustomDialogRow(
            label: "Bombs disarmed",
            value: "69",
          ),
          const CustomDialogRow(
            label: "False positives",
            value: "20",
          ),
          const CustomDialogRow(
            label: "Bombs exploded",
            value: "5",
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Close"),
        ),
        TextButton(
          onPressed: () {
            // new game
            Navigator.of(context).pop();
          },
          child: const Text("New Game"),
        ),
      ],
    ),
  );
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

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
    this.backgroundColor,
    this.borderTopColor,
    this.borderBottomColor,
  }) : super(key: key);

  final String title;
  final Widget content;
  final List<Widget> actions;

  final Color? backgroundColor;
  final Color? borderTopColor;
  final Color? borderBottomColor;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: backgroundColor ?? Colors.blue[100],
      shape: outsetBorder(
        10.0,
        borderTopColor ?? Colors.red,
        borderBottomColor ?? Colors.yellow,
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
                    color: Colors.red,
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

    return AlertDialog(
      title: const Text("You Lost"),
      contentPadding: const EdgeInsets.all(24.0),
      scrollable: true,
      content: content,
      actions: actions,
    );
  }
}
