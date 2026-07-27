import 'package:oficina_app/features/auth/data/services/account_registration_service.dart';
import 'package:oficina_app/features/auth/models/account_registration.dart';
import 'package:oficina_app/features/auth/models/user.dart';

/// Ponte entre a camada de apresentação e o [AccountRegistrationService].
/// Depende apenas da interface abstrata do service (DIP), permitindo trocar
/// a implementação (mock, API) sem afetar o view model.
class AccountRegistrationRepository {
  final AccountRegistrationService _service;

  AccountRegistrationRepository({required AccountRegistrationService service})
    : _service = service;

  Future<User> registerClient(ClientRegistration registration) {
    return _service.registerClient(registration);
  }

  Future<User> registerWorkshop(WorkshopRegistration registration) {
    return _service.registerWorkshop(registration);
  }
}
