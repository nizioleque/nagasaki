validateRange(String? value, int i, int j) {
  if (value == null || value.isEmpty) return "That's not a number!";
  var v = int.tryParse(value);
  if (v == null) return "That's not a number!";
  if (v < i) return "That's not enough!";
  if (v > j) return "That's too much!";
  return null;
}
