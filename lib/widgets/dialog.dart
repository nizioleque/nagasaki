import 'package:flutter/material.dart';

import '../constants.dart';
import '../helpers.dart';
import '../settings.dart';

class CustomDialog extends StatelessWidget {
  const CustomDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.actions,
    this.titleColor = Colors.black,
    this.backgroundColor = Constants.backgroundColor,
    this.borderTopColor = Constants.borderTopColor,
    this.borderBottomColor = Constants.borderBottomColor,
  }) : super(key: key);

  final String title;
  final Widget content;
  final List<Widget> actions;

  final Color titleColor;
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
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    fontSize: 32,
                    color: titleColor,
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: content,
                  ),
                ),
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

class CustomDialogTextButton extends StatelessWidget {
  const CustomDialogTextButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.accented = false,
  }) : super(key: key);

  final Function() onPressed;
  final String text;
  final bool accented;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      child: Text(text.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          )),
    );
  }
}

class SettingsDialogSectionHeader extends StatelessWidget {
  const SettingsDialogSectionHeader({
    Key? key,
    required this.text,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
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
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            groupValue: groupValue,
            activeColor: Constants.settingsAccentColor,
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

class SettingsToggle extends StatelessWidget {
  const SettingsToggle({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Row(
        children: <Widget>[
          Switch(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: value,
            activeColor: Constants.settingsAccentColor,
            onChanged: (bool newValue) {
              onChanged(newValue);
            },
          ),
          Text(label),
        ],
      ),
    );
  }
}
