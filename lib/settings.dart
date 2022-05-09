import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'classes.dart';
import 'helpers.dart';
import 'widgets/dialog.dart';
import 'widgets/settings.dart';

class Settings {
  static UserPreferences? currentPreferences;

  static Future<UserPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    var prefStr = prefs.getString('userPreferences') ?? '';

    if (prefStr == '') {
      currentPreferences = UserPreferences();
      return currentPreferences!;
    }

    // loading existing game
    var prefJson = jsonDecode(prefStr);
    var prefObj = UserPreferences.fromJson(prefJson);

    try {
      currentPreferences = prefObj;
    } catch (e) {
      debugPrint(e.toString());
    }

    return currentPreferences!;
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

  static Future<SettingsChange> openSettings(BuildContext context) async {
    final _controllers = [for (var i = 0; i < 3; i++) TextEditingController()];
    final _formKey = GlobalKey<FormState>();

    var settingsChange = SettingsChange();

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

    Difficulty radioValue = currentPreferences!.radioOption;
    bool soundOn = currentPreferences!.soundOn;

    var dialogContent = SettingsDialogContent(
      controllers: _controllers,
      initialPrefs: currentPreferences!,
      onRadioTap: (Difficulty newValue) {
        radioValue = newValue;
      },
      onSoundTap: (bool newValue) {
        soundOn = newValue;
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
          CustomDialogTextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            text: "Cancel",
          ),
          CustomDialogTextButton(
            text: "Apply",
            onPressed: () {
              debugPrint(
                  'radioValue: $radioValue, currPref: ${currentPreferences!.radioOption}');
              // settings changed if different radio button clicked
              settingsChange.difficultyChanged =
                  radioValue != currentPreferences!.radioOption;
              settingsChange.soundChanged =
                  soundOn != currentPreferences!.soundOn;

              bool canHide = true;

              if (settingsChange.soundChanged) {
                settingsChange.newSound = soundOn;
              }

              switch (radioValue) {
                case Difficulty.beginner:
                  settingsChange.newSettings = const GameSettings(
                    rows: 10,
                    columns: 10,
                    bombs: 10,
                  );
                  break;

                case Difficulty.intermediate:
                  settingsChange.newSettings = const GameSettings(
                    rows: 15,
                    columns: 10,
                    bombs: 30,
                  );
                  break;

                case Difficulty.expert:
                  settingsChange.newSettings = const GameSettings(
                    rows: 20,
                    columns: 15,
                    bombs: 30,
                  );
                  break;

                case Difficulty.custom:
                  if (_formKey.currentState!.validate()) {
                    settingsChange.newSettings = GameSettings(
                      columns: int.parse(_controllers[0].text),
                      rows: int.parse(_controllers[1].text),
                      bombs: int.parse(_controllers[2].text),
                    );
                    // settings changed if custom value changed
                    settingsChange.difficultyChanged = true;
                    currentPreferences!.customSettings =
                        settingsChange.newSettings!;
                  } else {
                    // don't let the settings menu close if there are validation errors
                    canHide = false;
                  }
                  break;
              }

              if (settingsChange.anyChange) {
                debugPrint('settings changed');
                currentPreferences!.radioOption = radioValue;
                currentPreferences!.soundOn = soundOn;
                savePreferences();
              }

              // hide dialog
              if (canHide) Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );

    return settingsChange;
  }
}

class SettingsDialogContent extends StatefulWidget {
  const SettingsDialogContent({
    Key? key,
    required List<TextEditingController> controllers,
    required this.onRadioTap,
    required this.onSoundTap,
    required this.initialPrefs,
  })  : _controllers = controllers,
        super(key: key);

  final List<TextEditingController> _controllers;
  final ValueChanged<Difficulty> onRadioTap;
  final ValueChanged<bool> onSoundTap;
  final UserPreferences initialPrefs;

  @override
  State<SettingsDialogContent> createState() => _SettingsDialogContentState();
}

enum Difficulty { beginner, intermediate, expert, custom }

class _SettingsDialogContentState extends State<SettingsDialogContent> {
  Difficulty? _difficulty;
  bool? _soundOn;
  @override
  Widget build(BuildContext context) {
    _difficulty ??= widget.initialPrefs.radioOption;
    _soundOn ??= widget.initialPrefs.soundOn;
    debugPrint('build, diff: $_difficulty');

    return Column(
      // mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SettingsDialogSectionHeader(text: "Sound"),
        Padding(
          padding: const EdgeInsets.only(top: 2.0, bottom: 12.0),
          child: SettingsToggle(
            label: "Sound effects",
            value: _soundOn!,
            onChanged: (bool newValue) {
              widget.onSoundTap(newValue);
              setState(() {
                _soundOn = newValue;
              });
            },
          ),
        ),
        const SettingsDialogSectionHeader(text: "Difficulty"),
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: DifficultyRadio(
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
