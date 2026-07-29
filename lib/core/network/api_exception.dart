/// Falha vinda da API, já com a mensagem que o backend mandou no corpo.
///
/// Os view models tratam qualquer exceção como falha genérica; quem quiser
/// diferenciar (ex.: 401 no login) olha o [statusCode].
class ApiException implements Exception {
  final int statusCode;
  final String message;

  /// Mapa campo → mensagem quando a requisição falhou na validação (400).
  final Map<String, String> fields;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.fields = const {},
  });

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => 'ApiException($statusCode): $message';
}
