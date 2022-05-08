import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'classes.dart';
import 'helpers.dart';
import 'widgets/dialog.dart';
import 'widgets/settings.dart';

class Settings {
  static UserPreferences? currentPreferences;

  static Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    var prefStr = prefs.getString('userPreferences') ?? '';

    if (prefStr == '') {
      currentPreferences = UserPreferences();
      return;
    }

    // loading existing game
    var prefJson = jsonDecode(prefStr);
    var prefObj = UserPreferences.fromJson(prefJson);

    try {
      currentPreferences = prefObj;
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> savePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      String prefEncoded = jsonEncode(currentPreferences);
      prefs.setString('userPreferences', prefEncoded);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<List> openSettings(BuildContext context) async {
    final _controllers = [for (var i = 0; i < 3; i++) TextEditingController()];
    final _formKey = GlobalKey<FormState>();
    GameSettings? newSett;
    var settingsChanged = false;

    if (currentPreferences == null) await loadPreferences();

    for (int i = 0; i < 3; i++) {
      int val;

      switch (i) {
        case 0:
          val = currentPreferences!.customSettings.columns;
          break;
        case 1:
          val = currentPreferences!.customSettings.rows;
          break;
        case 2:
          val = currentPreferences!.customSettings.bombs;
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

    Difficulty radioValue = Difficulty.beginner;
    bool soundOn = true;

    var dialogContent = SettingsDialogContent(
      controllers: _controllers,
      initialPrefs: currentPreferences!,
      onRadioTap: (Difficulty newDifficulty) {
        radioValue = newDifficulty;
      },
    );

    await showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        title: "Settings",
        content: Form(
          key: _formKey,
          child: dialogContent,
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
              // settings changed if different radio button clicked
              settingsChanged = radioValue != currentPreferences!.radioOption;
              bool canHide = true;

              switch (radioValue) {
                case Difficulty.beginner:
                  newSett = const GameSettings(
                    rows: 10,
                    columns: 10,
                    bombs: 10,
                  );
                  break;

                case Difficulty.intermediate:
                  newSett = const GameSettings(
                    rows: 15,
                    columns: 10,
                    bombs: 20,
                  );
                  break;

                case Difficulty.expert:
                  newSett = const GameSettings(
                    rows: 20,
                    columns: 15,
                    bombs: 30,
                  );
                  break;

                case Difficulty.custom:
                  if (_formKey.currentState!.validate()) {
                    newSett = GameSettings(
                      columns: int.parse(_controllers[0].text),
                      rows: int.parse(_controllers[1].text),
                      bombs: int.parse(_controllers[2].text),
                    );
                    // settings changed if custom value changed
                    settingsChanged = true;
                    currentPreferences!.customSettings = newSett!;
                  } else {
                    // don't let the settings menu close if there are validation errors
                    canHide = false;
                  }
                  break;
              }

              if (settingsChanged) {
                currentPreferences!.radioOption = radioValue;
                savePreferences();
              }

              // hide dialog
              if (canHide) Navigator.of(context).pop();
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );

    return [settingsChanged, newSett];
  }
}

class SettingsDialogContent extends StatefulWidget {
  const SettingsDialogContent({
    Key? key,
    required List<TextEditingController> controllers,
    required this.onRadioTap,
    required this.initialPrefs,
  })  : _controllers = controllers,
        super(key: key);

  final List<TextEditingController> _controllers;
  final ValueChanged<Difficulty> onRadioTap;
  final UserPreferences initialPrefs;

  @override
  State<SettingsDialogContent> createState() => _SettingsDialogContentState();
}

enum Difficulty { beginner, intermediate, expert, custom }

class _SettingsDialogContentState extends State<SettingsDialogContent> {
  Difficulty? _difficulty;
  @override
  Widget build(BuildContext context) {
    _difficulty ??= widget.initialPrefs.radioOption;

    return Column(
      // mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsDialogSectionHeader(text: "Sound"),
        const Text("disable sound..."),
        const SettingsDialogSectionHeader(text: "Difficulty"),
        DifficultyRadio(
          label: 'Beginner',
          value: Difficulty.beginner,
          groupValue: _difficulty!,
          onChanged: (Difficulty newValue) {
            widget.onRadioTap(newValue);
            setState(() {
              _difficulty = newValue;
            });
          },
        ),
        DifficultyRadio(
          label: 'Intermediate',
          value: Difficulty.intermediate,
          groupValue: _difficulty!,
          onChanged: (Difficulty newValue) {
            widget.onRadioTap(newValue);
            setState(() {
              _difficulty = newValue;
            });
          },
        ),
        DifficultyRadio(
          label: 'Expert',
          value: Difficulty.expert,
          groupValue: _difficulty!,
          onChanged: (Difficulty newValue) {
            widget.onRadioTap(newValue);
            setState(() {
              _difficulty = newValue;
            });
          },
        ),
        DifficultyRadio(
          label: 'Custom',
          value: Difficulty.custom,
          groupValue: _difficulty!,
          onChanged: (Difficulty newValue) {
            widget.onRadioTap(newValue);
            setState(() {
              _difficulty = newValue;
            });
          },
        ),
        if (_difficulty == Difficulty.custom)
          Row(
            children: [
              SettingsNumberField(
                controller: widget._controllers[0],
                validator: (value) => validateRange(value, 3, 30),
                text: "Columns",
              ),
              const Spacer(
                flex: 1,
              ),
              SettingsNumberField(
                controller: widget._controllers[1],
                validator: (value) => validateRange(value, 3, 30),
                text: "Rows",
              ),
              const Spacer(
                flex: 1,
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
                text: "Mines",
              ),
            ],
          ),
      ],
    );
  }
}
