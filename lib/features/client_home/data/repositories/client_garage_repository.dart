import '../../../customers/models/vehicle.dart';
import '../services/client_garage_service.dart';

/// Ponto de acesso à garagem do cliente autenticado.
class ClientGarageRepository {
  final ClientGarageService _service;

  ClientGarageRepository({required ClientGarageService service})
    : _service = service;

  Future<List<Vehicle>> fetchMyVehicles() => _service.fetchMyVehicles();

  Future<Vehicle> addVehicle(Vehicle vehicle) => _service.addVehicle(vehicle);

  Future<void> removeVehicle(String id) => _service.removeVehicle(id);
}
