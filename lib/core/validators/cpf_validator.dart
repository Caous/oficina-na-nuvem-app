class CpfValidator {
  CpfValidator._();

  static String? validate(String? value) {
    final cpf = value?.replaceAll(RegExp(r'\D'), '') ?? '';

    if (cpf.isEmpty) {
      return 'Informe o CPF.';
    }

    if (cpf.length != 11) {
      return 'Informe um CPF válido.';
    }

    if (RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
      return 'Informe um CPF válido.';
    }

    final firstDigit = _calculateDigit(
      cpf.substring(0, 9),
      10,
    );

    final secondDigit = _calculateDigit(
      cpf.substring(0, 9) + firstDigit.toString(),
      11,
    );

    final isValid =
        cpf[9] == firstDigit.toString() &&
        cpf[10] == secondDigit.toString();

    if (!isValid) {
      return 'Informe um CPF válido.';
    }

    return null;
  }

  static int _calculateDigit(
    String value,
    int initialWeight,
  ) {
    var total = 0;

    for (var index = 0; index < value.length; index++) {
      total += int.parse(value[index]) * (initialWeight - index);
    }

    final remainder = total % 11;

    return remainder < 2 ? 0 : 11 - remainder;
  }
}