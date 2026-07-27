import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_app/core/validators/cpf_validator.dart';

void main() {
  group('CpfValidator.validate', () {
    test('aceita CPF válido sem máscara', () {
      expect(CpfValidator.validate('52998224725'), isNull);
    });

    test('aceita CPF válido com máscara', () {
      expect(CpfValidator.validate('529.982.247-25'), isNull);
    });

    test('aceita outro CPF válido conhecido', () {
      expect(CpfValidator.validate('111.444.777-35'), isNull);
    });

    test('recusa CPF vazio', () {
      expect(CpfValidator.validate(''), isNotNull);
    });

    test('recusa valor nulo', () {
      expect(CpfValidator.validate(null), isNotNull);
    });

    test('recusa CPF com comprimento errado', () {
      expect(CpfValidator.validate('1234567890'), isNotNull);
    });

    test('recusa CPF com todos os dígitos iguais', () {
      expect(CpfValidator.validate('111.111.111-11'), isNotNull);
    });

    test('recusa CPF com dígito verificador errado', () {
      expect(CpfValidator.validate('529.982.247-26'), isNotNull);
    });
  });
}
