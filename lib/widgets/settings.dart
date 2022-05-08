import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../settings.dart';

// settings dialog number fields
class SettingsNumberField extends StatelessWidget {
  const SettingsNumberField({
    Key? key,
    required this.controller,
    required this.validator,
    required this.text,
  }) : super(key: key);

  final TextEditingController controller;
  final String? Function(String?) validator;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 5,
      child: TextFormField(
        autovalidateMode: AutovalidateMode.always,
        validator: validator,
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: text,
        ),
      ),
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
      padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 4.0),
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
          // Radio<Difficulty>(
          //   materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          //   groupValue: groupValue,
          //   value: value,
          //   onChanged: (Difficulty? newValue) {
          //     onChanged(newValue!);
          //   },
          // ),
          Switch(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: value,
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
