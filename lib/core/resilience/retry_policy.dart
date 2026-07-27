import 'dart:async';

/// Política de repetição para operações que podem falhar por instabilidade
/// momentânea (rede, indisponibilidade do serviço).
///
/// Segue a ideia de "policy" do Polly: a política envolve a operação e decide
/// quantas vezes repetir e quanto esperar entre as tentativas. Falhas
/// definitivas — como um CEP que não existe — não devem ser repetidas; para
/// isso use [retryWhen] e deixe o erro passar.
class RetryPolicy {
  /// Número máximo de tentativas, incluindo a primeira.
  final int maxAttempts;

  /// Espera antes da segunda tentativa. As seguintes crescem por [backoffFactor].
  final Duration initialDelay;

  /// Multiplicador aplicado à espera a cada nova tentativa.
  final double backoffFactor;

  /// Tempo máximo de cada tentativa isolada.
  final Duration? attemptTimeout;

  /// Decide se um erro merece nova tentativa. Por padrão, todos merecem.
  final bool Function(Object error) retryWhen;

  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 400),
    this.backoffFactor = 2,
    this.attemptTimeout = const Duration(seconds: 8),
    bool Function(Object error)? retryWhen,
  }) : retryWhen = retryWhen ?? _alwaysRetry;

  static bool _alwaysRetry(Object error) => true;

  /// Executa [action] repetindo em caso de falha.
  ///
  /// Relança o último erro quando todas as tentativas se esgotam, para que o
  /// chamador decida o que mostrar ao usuário.
  Future<T> execute<T>(Future<T> Function() action) async {
    var attempt = 0;
    var delay = initialDelay;

    while (true) {
      attempt++;

      try {
        final timeout = attemptTimeout;

        return timeout == null
            ? await action()
            : await action().timeout(timeout);
      } catch (error) {
        final isLastAttempt = attempt >= maxAttempts;

        if (isLastAttempt || !retryWhen(error)) {
          rethrow;
        }

        await Future<void>.delayed(delay);
        delay = Duration(
          milliseconds: (delay.inMilliseconds * backoffFactor).round(),
        );
      }
    }
  }
}
