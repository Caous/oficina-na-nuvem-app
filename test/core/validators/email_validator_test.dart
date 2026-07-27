import 'package:flutter_test/flutter_test.dart';
import 'package:oficina_app/core/validators/email_validator.dart';

void main() {
  group('EmailValidator.validate', () {
    test('aceita e-mail curto válido', () {
      expect(EmailValidator.validate('a@b.co'), isNull);
    });

    test('aceita e-mail com nome composto e domínio .com.br', () {
      expect(EmailValidator.validate('nome.sobrenome@dominio.com.br'), isNull);
    });

    test('aceita e-mail com tag (+)', () {
      expect(EmailValidator.validate('nome+tag@dominio.com'), isNull);
    });

    test('recusa e-mail vazio', () {
      expect(EmailValidator.validate(''), isNotNull);
    });

    test('recusa valor nulo', () {
      expect(EmailValidator.validate(null), isNotNull);
    });

    test('recusa e-mail sem arroba', () {
      expect(EmailValidator.validate('nomedominio.com'), isNotNull);
    });

    test('recusa e-mail sem domínio', () {
      expect(EmailValidator.validate('nome@'), isNotNull);
    });

    test('recusa e-mail sem TLD', () {
      expect(EmailValidator.validate('nome@dominio'), isNotNull);
    });

    test('recusa e-mail com TLD de uma letra', () {
      expect(EmailValidator.validate('nome@dominio.c'), isNotNull);
    });

    test('recusa e-mail com espaço no meio', () {
      expect(EmailValidator.validate('no me@dominio.com'), isNotNull);
    });

    test('recusa e-mail com dois arrobas', () {
      expect(EmailValidator.validate('nome@@dominio.com'), isNotNull);
    });

    test('recusa e-mail com ponto no fim', () {
      expect(EmailValidator.validate('nome@dominio.com.'), isNotNull);
    });
  });

  group('EmailValidator.validateOptional', () {
    test('aceita vazio', () {
      expect(EmailValidator.validateOptional(''), isNull);
    });

    test('aceita nulo', () {
      expect(EmailValidator.validateOptional(null), isNull);
    });

    test('aceita valor válido preenchido', () {
      expect(EmailValidator.validateOptional('a@b.co'), isNull);
    });

    test('recusa valor inválido preenchido', () {
      expect(EmailValidator.validateOptional('invalido'), isNotNull);
    });
  });
}
