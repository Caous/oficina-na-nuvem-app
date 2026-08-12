import 'dart:io';

import 'package:flutter/foundation.dart';

import 'api_exception.dart';

/// Traduz a falha em uma frase que a pessoa entende, e registra o erro cru no
/// console.
///
/// Sem isso, um `catch` genérico transforma qualquer problema — servidor fora
/// do ar, e-mail repetido, senha curta — na mesma mensagem inútil, e o motivo
/// real não chega nem à tela nem ao log.
abstract final class ApiFailureMessage {
  /// [fallback] cobre o que não sabemos explicar; o log guarda o resto.
  static String of(Object error, {required String fallback}) {
    debugPrint('[API] $error');

    if (error is ApiException) {
      // Erro de validação: mostra o primeiro campo recusado, que é acionável.
      if (error.fields.isNotEmpty) {
        final field = error.fields.entries.first;
        return '${field.key}: ${field.value}';
      }

      return error.message;
    }

    if (error is SocketException || error is HttpException) {
      return 'Servidor fora do ar. Confira se a API está rodando e se o '
          'endereço configurado está correto.';
    }

    return fallback;
  }
}
