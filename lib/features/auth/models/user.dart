/// Papel da conta: define qual área do aplicativo o usuário acessa.
enum UserRole {
  /// Cliente da oficina — vê a home do cliente (veículos, socorro, perfil).
  client,

  /// Dono/equipe da oficina — vê o dashboard e a gestão da oficina.
  workshop,
}

class User {
  final String id;
  final String name;
  final String? userName;
  final String email;
  final UserRole role;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.userName,
    this.role = UserRole.client,
  });
}
