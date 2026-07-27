import 'package:oficina_app/shared/address_lookup/models/address.dart';

/// Tipo de conta escolhido no cadastro.
enum AccountType { client, workshop }

/// Dados coletados no formulário de cadastro de cliente.
class ClientRegistration {
  final String name;
  final String document;
  final String email;
  final String phone;
  final Address address;
  final String password;

  const ClientRegistration({
    required this.name,
    required this.document,
    required this.email,
    required this.phone,
    required this.address,
    required this.password,
  });
}

/// Dados coletados no formulário de cadastro de oficina.
class WorkshopRegistration {
  final String tradeName;
  final String document;
  final String email;
  final String phone;
  final Address address;
  final String password;

  const WorkshopRegistration({
    required this.tradeName,
    required this.document,
    required this.email,
    required this.phone,
    required this.address,
    required this.password,
  });
}
