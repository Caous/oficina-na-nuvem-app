/// Sessão autenticada em memória: o token JWT recebido no login/cadastro.
///
/// Vive pelo tempo do processo — fechar o app exige novo login. Persistir o
/// token (secure storage) é um passo futuro que não muda quem consome isto.
class AuthSession {
  String? _accessToken;

  String? get accessToken => _accessToken;

  bool get isAuthenticated => _accessToken != null;

  void store(String accessToken) {
    _accessToken = accessToken;
  }

  void clear() {
    _accessToken = null;
  }
}
