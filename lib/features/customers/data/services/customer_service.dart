import '../../models/customer.dart';
import '../../models/vehicle.dart';

/// Acesso aos clientes da oficina.
abstract class CustomerService {
  Future<List<Customer>> fetchCustomers();
}

/// Acesso aos veículos vinculados a clientes.
///
/// Separado de [CustomerService] para que consumidores que só precisam de
/// veículos não dependam de operações de cliente.
abstract class VehicleService {
  Future<List<Vehicle>> fetchVehiclesOf(String customerId);

  Future<Vehicle> createVehicle(Vehicle vehicle);
}
