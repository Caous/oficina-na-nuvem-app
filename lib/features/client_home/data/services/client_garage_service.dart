import '../../../customers/models/vehicle.dart';

/// Acesso à garagem (veículos) do cliente autenticado.
abstract class ClientGarageService {
  Future<List<Vehicle>> fetchMyVehicles();

  Future<Vehicle> addVehicle(Vehicle vehicle);

  Future<void> removeVehicle(String id);
}
