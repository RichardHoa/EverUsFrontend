import 'package:flutter/services.dart';

/// Lowest budget per person, in VND, the planner accepts.
const int minBudgetVnd = 50000;

/// Longest amount the budget field accepts, in digits.
const int _maxBudgetDigits = 12;

/// Reads the digits out of [text] as an amount, or null when there are none.
int? parseVnd(String text) {
  final digits = text.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return null;
  return int.parse(digits.length > _maxBudgetDigits ? digits.substring(0, _maxBudgetDigits) : digits);
}

/// Formats [amount] with thousands separators, e.g. 500000 → "500,000".
String formatVnd(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

/// Whether [amount] is enough to plan a date.
bool isValidBudget(int? amount) => amount != null && amount >= minBudgetVnd;

/// Keeps a text field to digits only, shown with thousands separators.
class VndInputFormatter extends TextInputFormatter {
  const VndInputFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final amount = parseVnd(newValue.text);
    final text = amount == null ? '' : formatVnd(amount);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
