import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_app/core/validators/phone_validator.dart';

void main() {
  group('PhoneValidator.validate', () {
    test('aceita celular válido', () {
      expect(PhoneValidator.validate('(11) 98888-1111'), isNull);
    });

    test('aceita telefone fixo válido', () {
      expect(PhoneValidator.validate('(11) 3333-4444'), isNull);
    });

    test('recusa telefone vazio', () {
      expect(PhoneValidator.validate(''), isNotNull);
    });

    test('recusa valor nulo', () {
      expect(PhoneValidator.validate(null), isNotNull);
    });

    test('recusa telefone curto demais', () {
      expect(PhoneValidator.validate('(11) 333-444'), isNotNull);
    });

    test('recusa telefone longo demais', () {
      expect(PhoneValidator.validate('(11) 999888-1111'), isNotNull);
    });

    test('recusa DDD inexistente', () {
      expect(PhoneValidator.validate('(10) 98888-1111'), isNotNull);
    });

    test('recusa outro DDD inexistente', () {
      expect(PhoneValidator.validate('(20) 3333-4444'), isNotNull);
    });

    test('recusa celular que não começa com 9', () {
      expect(PhoneValidator.validate('(11) 88888-1111'), isNotNull);
    });

    test('recusa fixo começando com 1', () {
      expect(PhoneValidator.validate('(11) 1333-4444'), isNotNull);
    });

    test('recusa fixo começando com 9 (confundível com celular)', () {
      expect(PhoneValidator.validate('(11) 9333-4444'), isNotNull);
    });
  });

  group('PhoneValidator.validateOptional', () {
    test('aceita vazio', () {
      expect(PhoneValidator.validateOptional(''), isNull);
    });

    test('aceita nulo', () {
      expect(PhoneValidator.validateOptional(null), isNull);
    });

    test('aceita valor válido preenchido', () {
      expect(PhoneValidator.validateOptional('(11) 98888-1111'), isNull);
    });

    test('recusa valor inválido preenchido', () {
      expect(PhoneValidator.validateOptional('(10) 98888-1111'), isNotNull);
    });
  });

  group('PhoneValidator.sanitize', () {
    test('remove caracteres não numéricos', () {
      expect(PhoneValidator.sanitize('(11) 98888-1111'), '11988881111');
    });

    test('trata valor nulo como vazio', () {
      expect(PhoneValidator.sanitize(null), '');
    });
  });
}
