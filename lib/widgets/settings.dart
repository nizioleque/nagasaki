import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
