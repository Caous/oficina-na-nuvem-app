import 'package:oficina_app/features/auth/data/services/account_registration_service.dart';
import 'package:oficina_app/features/auth/models/account_registration.dart';
import 'package:oficina_app/features/auth/models/user.dart';

/// Implementação mock de [AccountRegistrationService], usada enquanto não
/// há um backend real. Simula latência de rede e valida e-mail/senha como
/// rede de segurança, já que a validação principal ocorre no formulário.
class MockAccountRegistrationService implements AccountRegistrationService {
  static const _networkDelay = Duration(milliseconds: 800);

  @override
  Future<User> registerClient(ClientRegistration registration) async {
    await Future.delayed(_networkDelay);

    _validateCredentials(
      email: registration.email,
      password: registration.password,
    );

    return User(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: registration.name.trim(),
      email: registration.email.trim(),
      userName: registration.name.trim().toLowerCase().replaceAll(' ', ''),
      role: UserRole.client,
    );
  }

  @override
  Future<User> registerWorkshop(WorkshopRegistration registration) async {
    await Future.delayed(_networkDelay);

    _validateCredentials(
      email: registration.email,
      password: registration.password,
    );

    return User(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: registration.tradeName.trim(),
      email: registration.email.trim(),
      userName: registration.tradeName.trim().toLowerCase().replaceAll(
        ' ',
        '',
      ),
      role: UserRole.workshop,
    );
  }

  void _validateCredentials({
    required String email,
    required String password,
  }) {
    if (!email.contains('@')) {
      throw ArgumentError('Informe um e-mail válido.');
    }

    if (password.length < 6) {
      throw ArgumentError('A senha deve ter pelo menos 6 caracteres.');
    }
  }
}
