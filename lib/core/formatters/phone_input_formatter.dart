import 'package:flutter/services.dart';

/// Máscara de telefone que se adapta ao comprimento digitado.
///
/// Até 10 dígitos formata como fixo `(11) 3333-4444`; no 11º dígito passa a
/// celular `(11) 99999-8888`. Uma máscara fixa erraria um dos dois formatos.
class PhoneInputFormatter extends TextInputFormatter {
  static const int _maxDigits = 11;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > _maxDigits
        ? digits.substring(0, _maxDigits)
        : digits;

    final formatted = format(limited);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Aplica a máscara a uma sequência de dígitos já sanitizada.
  static String format(String digits) {
    if (digits.isEmpty) {
      return '';
    }

    final buffer = StringBuffer('(');

    if (digits.length <= 2) {
      buffer.write(digits);
      return buffer.toString();
    }

    buffer
      ..write(digits.substring(0, 2))
      ..write(') ');

    final subscriber = digits.substring(2);

    // Com 9 dígitos o bloco inicial tem 5 (celular); caso contrário, 4.
    final firstBlockLength = subscriber.length > 8 ? 5 : 4;

    if (subscriber.length <= firstBlockLength) {
      buffer.write(subscriber);
      return buffer.toString();
    }

    buffer
      ..write(subscriber.substring(0, firstBlockLength))
      ..write('-')
      ..write(subscriber.substring(firstBlockLength));

    return buffer.toString();
  }
}
