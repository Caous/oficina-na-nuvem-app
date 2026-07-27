/// Validação de telefone brasileiro, fixo ou celular.
class PhoneValidator {
  PhoneValidator._();

  /// DDDs em uso no país. Faixas não atribuídas são recusadas.
  static const Set<String> _areaCodes = {
    '11', '12', '13', '14', '15', '16', '17', '18', '19',
    '21', '22', '24', '27', '28',
    '31', '32', '33', '34', '35', '37', '38',
    '41', '42', '43', '44', '45', '46', '47', '48', '49',
    '51', '53', '54', '55',
    '61', '62', '63', '64', '65', '66', '67', '68', '69',
    '71', '73', '74', '75', '77', '79',
    '81', '82', '83', '84', '85', '86', '87', '88', '89',
    '91', '92', '93', '94', '95', '96', '97', '98', '99',
  };

  static String? validate(String? value) {
    final digits = sanitize(value);

    if (digits.isEmpty) {
      return 'Informe o telefone.';
    }

    if (digits.length < 10) {
      return 'Telefone incompleto. Confira o número.';
    }

    if (digits.length > 11) {
      return 'Telefone inválido. Confira o número.';
    }

    if (!_areaCodes.contains(digits.substring(0, 2))) {
      return 'DDD inválido. Confira o número.';
    }

    final subscriber = digits.substring(2);

    // Celular: 9 dígitos iniciando em 9. Fixo: 8 dígitos iniciando de 2 a 5.
    if (subscriber.length == 9) {
      if (!subscriber.startsWith('9')) {
        return 'Celular deve começar com 9. Confira o número.';
      }

      return null;
    }

    if (!RegExp(r'^[2-5]').hasMatch(subscriber)) {
      return 'Telefone fixo inválido. Confira o número.';
    }

    return null;
  }

  /// Versão opcional: campo vazio é aceito, preenchido precisa ser válido.
  static String? validateOptional(String? value) {
    return sanitize(value).isEmpty ? null : validate(value);
  }

  static String sanitize(String? value) {
    return (value ?? '').replaceAll(RegExp(r'\D'), '');
  }
}
