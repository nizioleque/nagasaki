import 'package:flutter/material.dart';

import 'constants.dart';
import 'grid.dart';
import 'widgets/dialog.dart';

Future<bool> showEndGameDialog(
    BuildContext context, Grid grid, bool success) async {
  bool newGame = false;

  await showDialog(
    context: context,
    builder: (BuildContext context) => CustomDialog(
      // backgroundColor: Color(0xffff9999),
      // borderTopColor: Color(0xffff8080),
      // borderBottomColor: Color(0xffff6666),
      title: success ? "You won!" : "You lost!",
      titleColor: success ? Constants.gameWinColor : Constants.gameLoseColor,
      content: Column(
        children: [
          CustomDialogRow(
            label: "Time",
            value: grid.time.toString(),
          ),
          CustomDialogRow(
            label: "Bombs disarmed",
            value: grid.disarmedBombs.toString(),
          ),
          CustomDialogRow(
            label: "False positives",
            value: (grid.flagged - grid.disarmedBombs).toString(),
          ),
          CustomDialogRow(
            label: "Bombs exploded",
            value: success ? '0' : (grid.bombs - grid.disarmedBombs).toString(),
          ),
        ],
      ),
      actions: [
        CustomDialogTextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          text: "Close",
        ),
        CustomDialogTextButton(
          onPressed: () {
            // new game
            newGame = true;
            Navigator.of(context).pop();
          },
          text: "New Game",
          accented: true,
        ),
      ],
    ),
  );

  return newGame;
}
