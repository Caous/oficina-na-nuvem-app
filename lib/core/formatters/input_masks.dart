import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'phone_input_formatter.dart';
import 'upper_case_text_formatter.dart';

/// Máscaras de entrada usadas nos formulários.
class InputMasks {
  InputMasks._();

  static MaskTextInputFormatter cpf() {
    return MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {'#': RegExp(r'[0-9]')},
    );
  }

  /// Máscara de CNPJ alfanumérico: os 12 primeiros caracteres aceitam letras
  /// ou dígitos e apenas os verificadores finais são numéricos.
  ///
  /// Use junto de [upperCase] para que as letras fiquem sempre em caixa alta,
  /// como exige o formato oficial.
  static MaskTextInputFormatter cnpj() {
    return MaskTextInputFormatter(
      mask: 'AA.AAA.AAA/AAAA-##',
      filter: {'A': RegExp(r'[0-9A-Za-z]'), '#': RegExp(r'[0-9]')},
    );
  }

  /// Telefone com máscara adaptável a fixo (10 dígitos) e celular (11).
  static TextInputFormatter phone() => PhoneInputFormatter();

  /// Converte a digitação para caixa alta.
  static TextInputFormatter upperCase() => UpperCaseTextFormatter();

  /// Placa no padrão Mercosul/antigo: 7 caracteres alfanuméricos.
  static MaskTextInputFormatter plate() {
    return MaskTextInputFormatter(
      mask: 'AAA-AAAA',
      filter: {'A': RegExp(r'[0-9A-Za-z]')},
    );
  }
}
