import 'package:flutter/material.dart';

import 'grid.dart';

showEndGameDialog(BuildContext context, Grid grid, bool success) async {
  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: success ? const Text("YOU WON") : const Text("You lost"),
      content: success
          ? const Text("You've found all bombs!")
          : const Text("You've hit a bomb!"),
      backgroundColor: success ? Colors.lightGreen : Colors.red,
    ),
  );
}
