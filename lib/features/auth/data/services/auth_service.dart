import '../../models/user.dart';

/// Autenticação de usuários.
///
/// Abstrata para que a troca do mock por um cliente HTTP não alcance
/// repositório, view model ou UI.
abstract class AuthService {
  /// Retorna o usuário autenticado, ou `null` quando as credenciais não
  /// conferem.
  Future<User?> loginAsync({required String email, required String password});
}
