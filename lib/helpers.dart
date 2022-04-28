validateRange(String? value, int from, int to) {
  if (value == null || value.isEmpty) return "That's not a number!";
  var v = int.tryParse(value);
  if (v == null) return "That's not a number!";
  if (v < from) return "That's not enough!";
  if (v > to) return "That's too much!";
  return null;
}
