/// Formatação de valores monetários em Real, sem dependências externas.
abstract final class BrlFormatter {
  /// Formata `1234.5` como `R$ 1.234,50`.
  static String format(double value) => 'R\$ ${formatWithoutSymbol(value)}';

  /// Formata `1234.5` como `1.234,50`.
  static String formatWithoutSymbol(double value) {
    final cents = (value * 100).round();
    final isNegative = cents < 0;
    final absoluteCents = cents.abs();

    final integerPart = (absoluteCents ~/ 100).toString();
    final decimalPart = (absoluteCents % 100).toString().padLeft(2, '0');

    final buffer = StringBuffer();

    for (var index = 0; index < integerPart.length; index++) {
      final remaining = integerPart.length - index;

      if (index > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(integerPart[index]);
    }

    final formatted = '$buffer,$decimalPart';

    return isNegative ? '-$formatted' : formatted;
  }

  /// Converte texto digitado (`1.234,50` ou `1234.50`) em `double`.
  ///
  /// Retorna `null` quando o texto não representa um número — cabe ao chamador
  /// decidir o que fazer, em vez de assumir zero silenciosamente.
  static double? tryParse(String raw) {
    final sanitized = raw
        .replaceAll(RegExp(r'[R$\s]'), '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    if (sanitized.isEmpty) {
      return null;
    }

    return double.tryParse(sanitized);
  }
}
