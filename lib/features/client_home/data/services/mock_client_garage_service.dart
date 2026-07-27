import '../../../customers/models/vehicle.dart';
import 'client_garage_service.dart';

/// Garagem do cliente em memória, semeada com os veículos do design.
class MockClientGarageService implements ClientGarageService {
  static const Duration _latency = Duration(milliseconds: 400);

  final List<Vehicle> _vehicles = [
    const Vehicle(
      id: 'g1',
      customerId: 'me',
      type: VehicleType.car,
      brand: 'Honda',
      model: 'Civic 2.0 EXL 16V',
      year: '2020 Gasolina',
      plate: 'ABC-1D23',
      fipeCode: '014057-8',
      fipeValue: 102350,
    ),
    const Vehicle(
      id: 'g2',
      customerId: 'me',
      type: VehicleType.motorcycle,
      brand: 'Honda',
      model: 'CB 500F',
      year: '2022 Flex',
      plate: 'XYZ-9M87',
      fipeCode: '811024-3',
      fipeValue: 38900,
    ),
  ];

  int _nextId = 3;

  @override
  Future<List<Vehicle>> fetchMyVehicles() async {
    await Future<void>.delayed(_latency);

    return List.unmodifiable(_vehicles);
  }

  @override
  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    await Future<void>.delayed(_latency);

    final created = Vehicle(
      id: 'g${_nextId++}',
      customerId: vehicle.customerId,
      type: vehicle.type,
      brand: vehicle.brand,
      model: vehicle.model,
      year: vehicle.year,
      plate: vehicle.plate,
      fipeCode: vehicle.fipeCode,
      fipeValue: vehicle.fipeValue,
    );

    _vehicles.add(created);

    return created;
  }

  @override
  Future<void> removeVehicle(String id) async {
    await Future<void>.delayed(_latency);

    final hasVehicle = _vehicles.any((vehicle) => vehicle.id == id);

    if (!hasVehicle) {
      throw StateError('Veículo $id não encontrado.');
    }

    _vehicles.removeWhere((vehicle) => vehicle.id == id);
  }
}
