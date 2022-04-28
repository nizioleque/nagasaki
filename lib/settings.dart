import 'package:flutter/material.dart';
import 'package:nagasaki/classes.dart';
import 'package:nagasaki/widgets.dart';

import 'grid.dart';
import 'helpers.dart';

Future<List> openSettings(Grid grid, BuildContext context) async {
  final _controllers = [for (var i = 0; i < 3; i++) TextEditingController()];
  final _formKey = GlobalKey<FormState>();
  GameSettings? newSett;
  var settingsChanged = false;

  for (int i = 0; i < 3; i++) {
    int val;

    switch (i) {
      case 0:
        val = grid.columns;
        break;
      case 1:
        val = grid.rows;
        break;
      case 2:
        val = grid.bombs;
        break;
      default:
        val = 0;
    }

    var text = val.toString();

    _controllers[i].value = _controllers[i].value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
  }

  await showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text("SETTINGS"),
      contentPadding: const EdgeInsets.all(20.0),
      scrollable: true,
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SettingsNumberField(
              controller: _controllers[0],
              validator: (value) => validateRange(value, 3, 30),
              text: "Columns",
            ),
            SettingsNumberField(
              controller: _controllers[1],
              validator: (value) => validateRange(value, 3, 30),
              text: "Rows",
            ),
            SettingsNumberField(
                controller: _controllers[2],
                validator: (value) {
                  try {
                    var fields = int.parse(_controllers[0].text) *
                        int.parse(_controllers[1].text);

                    return validateRange(value, 2, fields - 9);
                  } catch (e) {
                    return null;
                  }
                },
                text: "Mines"),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            // var newCol = int.parse(_controllers[i].text);
            if (_formKey.currentState!.validate()) {
              newSett = GameSettings(
                columns: int.parse(_controllers[0].text),
                rows: int.parse(_controllers[1].text),
                bombs: int.parse(_controllers[2].text),
              );
              settingsChanged = true;
              Navigator.of(context).pop();
            }
          },
          child: const Text("Apply"),
        ),
      ],
    ),
  );

  return [settingsChanged, newSett];
}
