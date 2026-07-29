import 'package:flutter/foundation.dart';

/// Endereço do backend.
///
/// Pode ser sobrescrito no build com
/// `--dart-define=API_BASE_URL=https://api.exemplo.com/api`. Sem override,
/// aponta para o backend local — no emulador Android, `10.0.2.2` é o
/// localhost da máquina hospedeira.
abstract final class ApiConfig {
  static const String _fromEnvironment = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_fromEnvironment.isNotEmpty) {
      return _fromEnvironment;
    }

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api';
    }

    return 'http://localhost:8080/api';
  }
}
