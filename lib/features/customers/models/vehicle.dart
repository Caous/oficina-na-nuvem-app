/// Tipo de veículo que um cliente pode cadastrar.
enum VehicleType {
  car('Carro'),
  motorcycle('Moto'),
  truck('Caminhão'),
  utility('Utilitário'),
  jetSki('Jet Ski'),
  aircraft('Aeronave');

  final String label;

  const VehicleType(this.label);

  /// Tipos cobertos pela Tabela FIPE; os demais são preenchidos manualmente.
  bool get supportsFipe => switch (this) {
    VehicleType.car ||
    VehicleType.motorcycle ||
    VehicleType.truck ||
    VehicleType.utility => true,
    VehicleType.jetSki || VehicleType.aircraft => false,
  };
}

/// Veículo de um cliente, com os dados de referência da Tabela FIPE quando o
/// tipo é coberto por ela.
class Vehicle {
  final String id;
  final String customerId;
  final VehicleType type;
  final String brand;
  final String model;
  final String year;
  final String plate;

  /// Código FIPE do modelo (ex.: `014057-8`); vazio para tipos fora da FIPE.
  final String fipeCode;

  /// Valor de referência FIPE, em reais; zero para tipos fora da FIPE.
  final double fipeValue;

  const Vehicle({
    required this.id,
    required this.customerId,
    required this.brand,
    required this.model,
    required this.year,
    required this.plate,
    required this.fipeCode,
    required this.fipeValue,
    this.type = VehicleType.car,
  });

  /// Descrição completa: "Honda Civic 2.0 EXL 16V 2020".
  String get fullName => '$brand $model $year';

  /// Descrição curta para linhas de lista: "Honda Civic 2.0 EXL 16V • ABC-1D23".
  String get shortDescription => '$brand $model • $plate';
}
