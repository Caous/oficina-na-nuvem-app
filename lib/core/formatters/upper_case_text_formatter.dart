import 'package:flutter/services.dart';

/// Mantém o texto sempre em caixa alta enquanto o usuário digita.
///
/// Usado em CNPJ alfanumérico e placas, onde o formato oficial é maiúsculo.
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
