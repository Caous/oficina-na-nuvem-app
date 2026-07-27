/// Cliente da oficina.
class Customer {
  final String id;
  final String name;
  final String document;
  final String phone;
  final String email;

  const Customer({
    required this.id,
    required this.name,
    required this.document,
    required this.phone,
    required this.email,
  });
}
