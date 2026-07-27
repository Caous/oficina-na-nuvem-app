import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_app/core/formatters/phone_input_formatter.dart';

void main() {
  group('PhoneInputFormatter.format', () {
    test('retorna vazio para entrada vazia', () {
      expect(PhoneInputFormatter.format(''), '');
    });

    test('formata os dois primeiros dígitos com parêntese aberto', () {
      expect(PhoneInputFormatter.format('11'), '(11');
    });

    test('formata DDD completo com início do assinante', () {
      expect(PhoneInputFormatter.format('1139'), '(11) 39');
    });

    test('formata telefone fixo completo', () {
      expect(PhoneInputFormatter.format('1133334444'), '(11) 3333-4444');
    });

    test('formata celular completo', () {
      expect(PhoneInputFormatter.format('11988881111'), '(11) 98888-1111');
    });
  });

  group('PhoneInputFormatter.formatEditUpdate', () {
    final formatter = PhoneInputFormatter();

    TextEditingValue valueFor(String text) {
      return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
    }

    test('limita a entrada a 11 dígitos', () {
      final result = formatter.formatEditUpdate(
        valueFor(''),
        valueFor('119888811112222'),
      );

      expect(result.text, '(11) 98888-1111');
    });

    test('formata progressivamente conforme os dígitos são digitados', () {
      final result = formatter.formatEditUpdate(
        valueFor('(11) 3333-444'),
        valueFor('(11) 3333-4444'),
      );

      expect(result.text, '(11) 3333-4444');
    });

    test('posiciona o cursor ao final do texto formatado', () {
      final result = formatter.formatEditUpdate(
        valueFor(''),
        valueFor('11988881111'),
      );

      expect(result.selection.baseOffset, result.text.length);
    });
  });
}
