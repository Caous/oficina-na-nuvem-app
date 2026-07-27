/// Endereço de um cliente, oficina ou funcionário.
///
/// [street], [neighborhood], [city] e [state] costumam vir da consulta de CEP;
/// [number] e [complement] são sempre preenchidos pela pessoa.
class Address {
  final String cep;
  final String street;
  final String number;
  final String complement;
  final String neighborhood;
  final String city;
  final String state;

  const Address({
    required this.cep,
    required this.street,
    required this.complement,
    required this.neighborhood,
    required this.city,
    required this.state,
    this.number = '',
  });

  static const Address empty = Address(
    cep: '',
    street: '',
    complement: '',
    neighborhood: '',
    city: '',
    state: '',
  );

  bool get isEmpty =>
      cep.isEmpty &&
      street.isEmpty &&
      number.isEmpty &&
      neighborhood.isEmpty &&
      city.isEmpty &&
      state.isEmpty;

  /// Linha única para exibição: "Rua X, 123 - Centro - São Paulo/SP".
  String get formatted {
    final streetPart = [
      if (street.isNotEmpty) street,
      if (number.isNotEmpty) number,
    ].join(', ');

    final cityPart = [
      if (city.isNotEmpty) city,
      if (state.isNotEmpty) state,
    ].join('/');

    return [
      if (streetPart.isNotEmpty) streetPart,
      if (neighborhood.isNotEmpty) neighborhood,
      if (cityPart.isNotEmpty) cityPart,
    ].join(' - ');
  }

  Address copyWith({
    String? cep,
    String? street,
    String? number,
    String? complement,
    String? neighborhood,
    String? city,
    String? state,
  }) {
    return Address(
      cep: cep ?? this.cep,
      street: street ?? this.street,
      number: number ?? this.number,
      complement: complement ?? this.complement,
      neighborhood: neighborhood ?? this.neighborhood,
      city: city ?? this.city,
      state: state ?? this.state,
    );
  }
}
