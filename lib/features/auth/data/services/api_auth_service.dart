import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_exception.dart';
import '../../models/user.dart';
import 'auth_service.dart';

/// Autenticação contra o backend. Um login bem-sucedido guarda o token na
/// sessão do [ApiClient]; toda chamada seguinte já sai autenticada.
class ApiAuthService implements AuthService {
  final ApiClient _api;

  ApiAuthService({required ApiClient api}) : _api = api;

  @override
  Future<User?> loginAsync({
    required String email,
    required String password,
  }) async {
    try {
      final json = await _api.post(
        '/auth/login',
        body: {'email': email, 'password': password},
      ) as Map<String, dynamic>;

      _api.session.store(json['accessToken'] as String);

      return userFromApi(json['user'] as Map<String, dynamic>);
    } on ApiException catch (exception) {
      if (exception.isUnauthorized) {
        return null;
      }

      rethrow;
    }
  }

  /// Papéis do backend achatados nos dois do app: dono e funcionário veem a
  /// mesma área da oficina.
  static User userFromApi(Map<String, dynamic> json) {
    final role = json['role'] == 'CUSTOMER' ? UserRole.client : UserRole.workshop;

    return User(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: role,
    );
  }
}
