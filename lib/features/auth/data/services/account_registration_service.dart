import 'package:oficina_app/features/auth/models/account_registration.dart';
import 'package:oficina_app/features/auth/models/user.dart';

/// Contrato de acesso a dados para o cadastro de contas (cliente ou
/// oficina). Implementações concretas decidem a origem dos dados (mock,
/// API, etc.) — o repositório e o view model dependem apenas desta
/// abstração.
abstract class AccountRegistrationService {
  Future<User> registerClient(ClientRegistration registration);

  Future<User> registerWorkshop(WorkshopRegistration registration);
}
