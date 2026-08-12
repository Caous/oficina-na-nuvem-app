import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';
import 'auth_session.dart';

/// Cliente HTTP do backend: monta a URL, anexa o token da sessão e converte
/// resposta em JSON ou em [ApiException] com a mensagem do servidor.
///
/// Todos os services de API dependem só dele, então preocupações de transporte
/// (headers, encoding, erros) vivem em um único lugar.
class ApiClient {
  final http.Client _http;
  final AuthSession session;
  final String _baseUrl;

  ApiClient({
    required http.Client httpClient,
    required this.session,
    String? baseUrl,
  }) : _http = httpClient,
       _baseUrl = baseUrl ?? ApiConfig.baseUrl;

  Future<dynamic> get(String path, {Map<String, String>? query}) {
    return _send('GET', path, query: query);
  }

  Future<dynamic> post(String path, {Object? body}) {
    return _send('POST', path, body: body);
  }

  Future<dynamic> put(String path, {Object? body}) {
    return _send('PUT', path, body: body);
  }

  Future<dynamic> patch(String path, {Object? body}) {
    return _send('PATCH', path, body: body);
  }

  Future<dynamic> delete(String path) {
    return _send('DELETE', path);
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);

    final request = http.Request(method, uri);
    request.headers['Accept'] = 'application/json';

    final token = session.accessToken;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }

    // Em debug, toda chamada aparece no console do `flutter run` — é o
    // primeiro lugar onde se olha quando uma tela falha.
    try {
      final response = await http.Response.fromStream(await _http.send(request));

      if (kDebugMode) {
        debugPrint('[API] $method $uri → ${response.statusCode}');
      }

      return _decode(response);
    } on Object catch (error) {
      if (kDebugMode) {
        debugPrint('[API] $method $uri → FALHOU: $error');
      }

      rethrow;
    }
  }

  dynamic _decode(http.Response response) {
    final text = utf8.decode(response.bodyBytes);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return text.isEmpty ? null : jsonDecode(text);
    }

    throw _errorFrom(response.statusCode, text);
  }

  ApiException _errorFrom(int statusCode, String text) {
    String message = 'Erro inesperado ao falar com o servidor.';
    Map<String, String> fields = const {};

    try {
      final json = jsonDecode(text) as Map<String, dynamic>;

      message = json['message']?.toString() ?? message;

      final rawFields = json['fields'];
      if (rawFields is Map<String, dynamic>) {
        fields = rawFields.map(
          (key, value) => MapEntry(key, value.toString()),
        );
      }
    } catch (_) {
      // Corpo não-JSON (proxy, HTML de erro): fica a mensagem genérica.
    }

    return ApiException(statusCode: statusCode, message: message, fields: fields);
  }
}
