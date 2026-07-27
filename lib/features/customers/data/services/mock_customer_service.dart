import '../../models/customer.dart';
import '../../models/vehicle.dart';
import 'customer_service.dart';

/// Clientes e veículos em memória.
///
/// O cliente `c2` nasce sem veículos de propósito: é o caminho que leva ao
/// cadastro via FIPE na tela de novo serviço.
class MockCustomerService implements CustomerService, VehicleService {
  static const Duration _latency = Duration(milliseconds: 400);

  final List<Customer> _customers = [
    const Customer(
      id: 'c1',
      name: 'João Pereira',
      document: '123.456.789-00',
      phone: '(11) 98888-1111',
      email: 'joao.pereira@email.com',
    ),
    const Customer(
      id: 'c2',
      name: 'Maria Santos',
      document: '234.567.890-11',
      phone: '(11) 97777-2222',
      email: 'maria.santos@email.com',
    ),
    const Customer(
      id: 'c3',
      name: 'Pedro Costa',
      document: '345.678.901-22',
      phone: '(11) 96666-3333',
      email: 'pedro.costa@email.com',
    ),
    const Customer(
      id: 'c4',
      name: 'Ana Oliveira',
      document: '456.789.012-33',
      phone: '(11) 95555-4444',
      email: 'ana.oliveira@email.com',
    ),
  ];

  final List<Vehicle> _vehicles = [
    const Vehicle(
      id: 'v1',
      customerId: 'c1',
      brand: 'Honda',
      model: 'Civic 2.0 EXL 16V',
      year: '2020 Gasolina',
      plate: 'ABC-1D23',
      fipeCode: '014057-8',
      fipeValue: 102350,
    ),
    const Vehicle(
      id: 'v2',
      customerId: 'c3',
      brand: 'Volkswagen',
      model: 'Gol 1.0 MPI',
      year: '2018 Flex',
      plate: 'KLM-4E56',
      fipeCode: '005312-1',
      fipeValue: 42800,
    ),
    const Vehicle(
      id: 'v3',
      customerId: 'c4',
      brand: 'Chevrolet',
      model: 'Onix 1.0 LT',
      year: '2021 Flex',
      plate: 'QRS-7H21',
      fipeCode: '004521-6',
      fipeValue: 68900,
    ),
  ];

  int _nextVehicleId = 4;

  @override
  Future<List<Customer>> fetchCustomers() async {
    await Future<void>.delayed(_latency);

    return List.unmodifiable(_customers);
  }

  @override
  Future<List<Vehicle>> fetchVehiclesOf(String customerId) async {
    await Future<void>.delayed(_latency);

    return _vehicles
        .where((vehicle) => vehicle.customerId == customerId)
        .toList(growable: false);
  }

  @override
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    await Future<void>.delayed(_latency);

    final hasCustomer = _customers.any(
      (customer) => customer.id == vehicle.customerId,
    );

    if (!hasCustomer) {
      throw StateError('Cliente ${vehicle.customerId} não encontrado.');
    }

    final created = Vehicle(
      id: 'v${_nextVehicleId++}',
      customerId: vehicle.customerId,
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
}
