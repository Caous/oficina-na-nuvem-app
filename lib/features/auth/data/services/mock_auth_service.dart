import '../../models/user.dart';
import 'auth_service.dart';

/// Autenticação em memória com uma conta de cada papel.
///
/// - Oficina: `ti@oficinanuvem.com.br` / `oficina123`
/// - Cliente: `cliente@email.com` / `cliente123`
class MockAuthService implements AuthService {
  static const Map<String, (String password, User user)> _accounts = {
    'ti@oficinanuvem.com.br': (
      'oficina123',
      User(
        id: '1',
        name: 'Administrator',
        email: 'ti@oficinanuvem.com.br',
        role: UserRole.workshop,
      ),
    ),
    'cliente@email.com': (
      'cliente123',
      User(
        id: '2',
        name: 'João Pereira',
        email: 'cliente@email.com',
        role: UserRole.client,
      ),
    ),
  };

  @override
  Future<User?> loginAsync({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 1));

    final account = _accounts[email.trim().toLowerCase()];

    if (account == null || account.$1 != password) {
      return null;
    }

    return account.$2;
  }
}
