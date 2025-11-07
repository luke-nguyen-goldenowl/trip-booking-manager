import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class VietnameseThousandsFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('vi_VN');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.trim().isEmpty) {
      return const TextEditingValue(text: '');
    }
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final formatted = _formatter.format(int.parse(digitsOnly));
    int newCursorPosition =
        formatted.length -
        (newValue.text.length - newValue.selection.baseOffset);

    if (newCursorPosition < 0) newCursorPosition = 0;
    if (newCursorPosition > formatted.length) {
      newCursorPosition = formatted.length;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorPosition),
    );
  }
}
