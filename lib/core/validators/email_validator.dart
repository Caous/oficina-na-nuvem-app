/// Validação de endereço de e-mail.
class EmailValidator {
  EmailValidator._();

  /// Exige nome, `@`, domínio e um TLD com ao menos duas letras, recusando
  /// pontos consecutivos ou nas extremidades.
  static final RegExp _pattern = RegExp(
    r"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+"
    r"(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*"
    r'@'
    r'[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?'
    r'(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)*'
    r'\.[A-Za-z]{2,}$',
  );

  static String? validate(String? value) {
    final email = (value ?? '').trim();

    if (email.isEmpty) {
      return 'Informe o e-mail.';
    }

    if (!_pattern.hasMatch(email)) {
      return 'E-mail inválido. Confira o endereço.';
    }

    return null;
  }

  /// Versão opcional: campo vazio é aceito, preenchido precisa ser válido.
  static String? validateOptional(String? value) {
    return (value ?? '').trim().isEmpty ? null : validate(value);
  }
}
