import 'package:flutter/material.dart';

validateRange(String? value, int from, int to) {
  if (value == null || value.isEmpty) return "That's not a number!";
  var v = int.tryParse(value);
  if (v == null) return "That's not a number!";
  if (v < from) return "That's not enough!";
  if (v > to) return "That's too much!";
  return null;
}

Border outsetBorder(double borderWidth, Color borderColorTopRight,
    Color borderColorBottomLeft) {
  return Border(
    top: BorderSide(color: borderColorTopRight, width: borderWidth),
    right: BorderSide(color: borderColorTopRight, width: borderWidth),
    bottom: BorderSide(color: borderColorBottomLeft, width: borderWidth),
    left: BorderSide(color: borderColorBottomLeft, width: borderWidth),
  );
}
