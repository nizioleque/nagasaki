import 'package:flutter/material.dart';

import 'grid.dart';

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
    builder: (BuildContext context) => AlertDialog(
      title: const Text("You Lost"),
      contentPadding: const EdgeInsets.all(24.0),
      scrollable: true,
      content: Column(
        children: [
          Row(children: const [Text("Time"), Text("100")]),
          Row(children: const [Text("Bombs disarmed"), Text("69")]),
          Row(children: const [Text("False positives"), Text("20")]),
          Row(children: const [Text("Bombs exploded"), Text("5")]),
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
