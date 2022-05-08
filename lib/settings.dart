import 'package:flutter/material.dart';

import 'classes.dart';
import 'grid.dart';
import 'helpers.dart';
import 'widgets/dialog.dart';
import 'widgets/settings.dart';

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
    builder: (BuildContext context) => CustomDialog(
      title: "Settings",
      content: Form(
        key: _formKey,
        child: SettingsDialogContent(controllers: _controllers),
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

class SettingsDialogContent extends StatefulWidget {
  const SettingsDialogContent({
    Key? key,
    required List<TextEditingController> controllers,
  })  : _controllers = controllers,
        super(key: key);

  final List<TextEditingController> _controllers;

  @override
  State<SettingsDialogContent> createState() => _SettingsDialogContentState();
}

enum Difficulty { beginner, intermediate, expert, custom }

class _SettingsDialogContentState extends State<SettingsDialogContent> {
  Difficulty _difficulty = Difficulty.beginner;

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        DifficultyRadio(
          label: 'Beginner',
          value: Difficulty.beginner,
          groupValue: _difficulty,
          onChanged: (Difficulty newValue) {
            setState(() {
              _difficulty = newValue;
            });
          },
        ),
        DifficultyRadio(
          label: 'Intermediate',
          value: Difficulty.intermediate,
          groupValue: _difficulty,
          onChanged: (Difficulty newValue) {
            setState(() {
              _difficulty = newValue;
            });
          },
        ),
        DifficultyRadio(
          label: 'Expert',
          value: Difficulty.expert,
          groupValue: _difficulty,
          onChanged: (Difficulty newValue) {
            setState(() {
              _difficulty = newValue;
            });
          },
        ),
        DifficultyRadio(
          label: 'Custom',
          value: Difficulty.custom,
          groupValue: _difficulty,
          onChanged: (Difficulty newValue) {
            setState(() {
              _difficulty = newValue;
            });
          },
        ),
        SettingsNumberField(
          controller: widget._controllers[0],
          validator: (value) => validateRange(value, 3, 30),
          text: "Columns",
        ),
        SettingsNumberField(
          controller: widget._controllers[1],
          validator: (value) => validateRange(value, 3, 30),
          text: "Rows",
        ),
        SettingsNumberField(
            controller: widget._controllers[2],
            validator: (value) {
              try {
                var fields = int.parse(widget._controllers[0].text) *
                    int.parse(widget._controllers[1].text);

                return validateRange(value, 2, fields - 9);
              } catch (e) {
                return null;
              }
            },
            text: "Mines"),
      ],
    );
  }
}

class DifficultyRadio extends StatelessWidget {
  const DifficultyRadio({
    Key? key,
    required this.label,
    required this.groupValue,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final String label;
  final Difficulty groupValue;
  final Difficulty value;
  final ValueChanged<Difficulty> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (value != groupValue) {
          onChanged(value);
        }
      },
      child: Row(
        children: <Widget>[
          Radio<Difficulty>(
            groupValue: groupValue,
            value: value,
            onChanged: (Difficulty? newValue) {
              onChanged(newValue!);
            },
          ),
          Text(label),
        ],
      ),
    );
  }
}
