import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_app/core/validators/cnpj_validator.dart';

void main() {
  group('CnpjValidator.validate', () {
    test('aceita CNPJ numérico tradicional válido com máscara', () {
      // 11.222.333/0001-81
      // Base (12 primeiros): 1 1 2 2 2 3 3 3 0 0 0 1
      // Pesos DV1:           5 4 3 2 9 8 7 6 5 4 3 2
      // soma = 5+4+6+4+18+24+21+18+0+0+0+2 = 102 -> 102 % 11 = 3 -> dv1 = 11-3 = 8
      // Base+dv1: ...0001 8, pesos DV2: 6 5 4 3 2 9 8 7 6 5 4 3 2
      // soma = 6+5+8+6+4+27+24+21+0+0+0+3+16 = 120 -> 120 % 11 = 10 -> dv2 = 11-10 = 1
      expect(CnpjValidator.validate('11.222.333/0001-81'), isNull);
    });

    test('aceita CNPJ alfanumérico válido calculado', () {
      // Base (12 primeiros): 1 2 A B C 3 4 D 5 E 6 F
      // Valores (codeUnit-48): 1 2 17 18 19 3 4 20 5 21 6 22
      // Pesos DV1:             5 4 3  2  9 8 7  6 5  4 3  2
      // soma = 5+8+51+36+171+24+28+120+25+84+18+44 = 614
      // 614 % 11 = 9 -> dv1 = 11-9 = 2
      // Base+dv1 valores: ...22 2, pesos DV2: 6 5 4 3 2 9 8 7 6 5 4 3 2
      // soma = 6+10+68+54+38+27+32+140+30+105+24+66+4 = 604
      // 604 % 11 = 10 -> dv2 = 11-10 = 1
      // CNPJ resultante: 12ABC34D5E6F21
      expect(CnpjValidator.validate('12ABC34D5E6F21'), isNull);
    });

    test('recusa CNPJ vazio', () {
      expect(CnpjValidator.validate(''), isNotNull);
    });

    test('recusa valor nulo', () {
      expect(CnpjValidator.validate(null), isNotNull);
    });

    test('recusa CNPJ com comprimento errado', () {
      expect(CnpjValidator.validate('11.222.333/0001-8'), isNotNull);
    });

    test('recusa CNPJ com dígito verificador errado', () {
      expect(CnpjValidator.validate('11.222.333/0001-82'), isNotNull);
    });

    test('recusa CNPJ com caracteres repetidos nos 12 primeiros', () {
      expect(CnpjValidator.validate('AAAAAAAAAAAA00'), isNotNull);
    });

    test('recusa CNPJ com letra na posição de dígito verificador', () {
      expect(CnpjValidator.validate('12ABC34D5E6FA1'), isNotNull);
    });
  });

  group('CnpjValidator.sanitize', () {
    test('remove máscara e converte para caixa alta', () {
      expect(CnpjValidator.sanitize('12.abc.34d/5e6f-21'), '12ABC34D5E6F21');
    });

    test('trata valor nulo como vazio', () {
      expect(CnpjValidator.sanitize(null), '');
    });
  });
}
