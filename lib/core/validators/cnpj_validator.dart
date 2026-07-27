/// Validação de CNPJ no formato alfanumérico.
///
/// A partir da regra da Receita Federal, os 12 primeiros caracteres podem ser
/// letras ou dígitos e apenas os 2 dígitos verificadores continuam numéricos.
/// O cálculo dos verificadores usa o valor ASCII do caractere menos 48, o que
/// mantém os CNPJs puramente numéricos existentes válidos.
class CnpjValidator {
  CnpjValidator._();

  static const int _length = 14;
  static const int _asciiOffset = 48;

  static const List<int> _firstDigitWeights = [
    5,
    4,
    3,
    2,
    9,
    8,
    7,
    6,
    5,
    4,
    3,
    2,
  ];

  static const List<int> _secondDigitWeights = [
    6,
    5,
    4,
    3,
    2,
    9,
    8,
    7,
    6,
    5,
    4,
    3,
    2,
  ];

  static String? validate(String? value) {
    final cnpj = sanitize(value);

    if (cnpj.isEmpty) {
      return 'Informe o CNPJ.';
    }

    if (cnpj.length != _length) {
      return 'CNPJ incompleto. Confira os dados.';
    }

    if (!RegExp(r'^[0-9A-Z]{12}[0-9]{2}$').hasMatch(cnpj)) {
      return 'CNPJ inválido. Confira os dados.';
    }

    // Sequências repetidas (00000000000000, AAAAAAAAAAAA00) nunca são válidas.
    if (RegExp(r'^(.)\1{11}').hasMatch(cnpj)) {
      return 'CNPJ inválido. Confira os dados.';
    }

    final firstDigit = _calculateDigit(cnpj.substring(0, 12), _firstDigitWeights);
    final secondDigit = _calculateDigit(
      cnpj.substring(0, 12) + firstDigit.toString(),
      _secondDigitWeights,
    );

    final isValid =
        cnpj[12] == firstDigit.toString() &&
        cnpj[13] == secondDigit.toString();

    if (!isValid) {
      return 'CNPJ inválido. Confira os dados.';
    }

    return null;
  }

  /// Remove máscara e normaliza para caixa alta.
  static String sanitize(String? value) {
    return (value ?? '')
        .toUpperCase()
        .replaceAll(RegExp(r'[^0-9A-Z]'), '');
  }

  static int _calculateDigit(String value, List<int> weights) {
    var total = 0;

    for (var index = 0; index < weights.length; index++) {
      total += _numericValueOf(value[index]) * weights[index];
    }

    final remainder = total % 11;

    return remainder < 2 ? 0 : 11 - remainder;
  }

  /// Valor do caractere conforme a regra: código ASCII menos 48.
  ///
  /// Dígitos `0`-`9` resultam em 0-9 e letras `A`-`Z` em 17-42.
  static int _numericValueOf(String character) {
    return character.codeUnitAt(0) - _asciiOffset;
  }
}
