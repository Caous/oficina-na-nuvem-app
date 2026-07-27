import '../../models/user.dart';
import '../services/auth_service.dart';

/// Acesso à autenticação.
class AuthRepository {
  final AuthService _authService;

  AuthRepository({required AuthService authService})
    : _authService = authService;

  Future<User?> login({required String email, required String password}) {
    return _authService.loginAsync(email: email, password: password);
  }
}
