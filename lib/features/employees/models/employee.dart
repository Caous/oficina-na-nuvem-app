import 'package:oficina_app/shared/address_lookup/models/address.dart';

/// Cargo de um funcionário da oficina.
enum EmployeeRole {
  chiefMechanic('Mecânico chefe'),
  mechanic('Mecânico'),
  electrician('Eletricista'),
  attendant('Atendente'),
  manager('Gerente');

  final String label;

  const EmployeeRole(this.label);
}

/// Funcionário da oficina.
class Employee {
  final String id;
  final String name;
  final String document;
  final String phone;
  final String email;
  final EmployeeRole role;
  final Address address;

  const Employee({
    required this.id,
    required this.name,
    required this.document,
    required this.phone,
    required this.email,
    required this.role,
    this.address = Address.empty,
  });

  /// Iniciais para o avatar da listagem (ex.: "Carlos Almeida" -> "CA").
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));

    if (parts.isEmpty || parts.first.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Employee copyWith({
    String? id,
    String? name,
    String? document,
    String? phone,
    String? email,
    EmployeeRole? role,
    Address? address,
  }) {
    return Employee(
      id: id ?? this.id,
      name: name ?? this.name,
      document: document ?? this.document,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      address: address ?? this.address,
    );
  }
}
