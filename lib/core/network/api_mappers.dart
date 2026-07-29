import '../../features/customers/models/vehicle.dart';
import '../../shared/address_lookup/models/address.dart';

/// Conversões compartilhadas entre os services de API: endereço e enums que
/// existem dos dois lados com nomes diferentes (camelCase aqui,
/// SCREAMING_SNAKE lá).
abstract final class ApiMappers {
  static const Map<VehicleType, String> _vehicleTypeToApi = {
    VehicleType.car: 'CAR',
    VehicleType.motorcycle: 'MOTORCYCLE',
    VehicleType.truck: 'TRUCK',
    VehicleType.utility: 'UTILITY',
    VehicleType.jetSki: 'JET_SKI',
    VehicleType.aircraft: 'AIRCRAFT',
  };

  static String vehicleTypeToApi(VehicleType type) => _vehicleTypeToApi[type]!;

  static VehicleType vehicleTypeFromApi(String? value) {
    return _vehicleTypeToApi.entries
        .firstWhere(
          (entry) => entry.value == value,
          orElse: () => const MapEntry(VehicleType.car, 'CAR'),
        )
        .key;
  }

  /// O backend chama `neighborhood` de `district` e `cep` de `zipCode`.
  /// Campos obrigatórios lá recebem um marcador quando vierem vazios daqui.
  static Map<String, dynamic> addressToApi(Address address) {
    return {
      'zipCode': address.cep.replaceAll(RegExp(r'\D'), ''),
      'street': address.street,
      'number': address.number.isEmpty ? 'S/N' : address.number,
      'complement': address.complement,
      'district': address.neighborhood,
      'city': address.city,
      'state': address.state,
    };
  }

  static Address addressFromApi(Map<String, dynamic>? json) {
    if (json == null) {
      return Address.empty;
    }

    return Address(
      cep: json['zipCode']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      complement: json['complement']?.toString() ?? '',
      neighborhood: json['district']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
    );
  }

  static Vehicle vehicleFromApi(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'].toString(),
      customerId: json['customerId'].toString(),
      type: vehicleTypeFromApi(json['type']?.toString()),
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      plate: json['plate']?.toString() ?? '',
      fipeCode: json['fipeCode']?.toString() ?? '',
      fipeValue: (json['fipeValue'] as num?)?.toDouble() ?? 0,
    );
  }

  static Map<String, dynamic> vehicleToApi(Vehicle vehicle) {
    return {
      'type': vehicleTypeToApi(vehicle.type),
      'brand': vehicle.brand,
      'model': vehicle.model,
      'year': vehicle.year,
      'plate': vehicle.plate,
      'fipeCode': vehicle.fipeCode.isEmpty ? null : vehicle.fipeCode,
      'fipeValue': vehicle.fipeValue,
    };
  }
}
