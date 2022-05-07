import 'package:flutter/material.dart';
import 'package:nagasaki/main.dart';

import 'grid.dart';
import 'widgets/dialog.dart';

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

