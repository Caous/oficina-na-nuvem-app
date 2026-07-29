import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_mappers.dart';
import '../../models/account_registration.dart';
import '../../models/user.dart';
import 'account_registration_service.dart';
import 'api_auth_service.dart';

/// Cadastro de contas contra o backend. O cadastro já devolve um token, então
/// a pessoa entra logada — sem segunda digitação de senha.
class ApiAccountRegistrationService implements AccountRegistrationService {
  final ApiClient _api;

  ApiAccountRegistrationService({required ApiClient api}) : _api = api;

  @override
  Future<User> registerClient(ClientRegistration registration) {
    return _register('/auth/register/customer', {
      'name': registration.name,
      'document': registration.document,
      'email': registration.email,
      'phone': registration.phone,
      'password': registration.password,
      'address': ApiMappers.addressToApi(registration.address),
    });
  }

  @override
  Future<User> registerWorkshop(WorkshopRegistration registration) {
    return _register('/auth/register/workshop', {
      'tradeName': registration.tradeName,
      'document': registration.document,
      'email': registration.email,
      'phone': registration.phone,
      'password': registration.password,
      'address': ApiMappers.addressToApi(registration.address),
    });
  }

  Future<User> _register(String path, Map<String, dynamic> body) async {
    final json = await _api.post(path, body: body) as Map<String, dynamic>;

    _api.session.store(json['accessToken'] as String);

    return ApiAuthService.userFromApi(json['user'] as Map<String, dynamic>);
  }
}
