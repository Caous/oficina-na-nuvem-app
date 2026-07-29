import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_mappers.dart';
import '../../../customers/models/vehicle.dart';
import 'client_garage_service.dart';

/// Garagem do cliente autenticado, em `/me/vehicles`.
class ApiClientGarageService implements ClientGarageService {
  final ApiClient _api;

  ApiClientGarageService({required ApiClient api}) : _api = api;

  @override
  Future<List<Vehicle>> fetchMyVehicles() async {
    final json = await _api.get('/me/vehicles') as List<dynamic>;

    return json
        .map((item) => ApiMappers.vehicleFromApi(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    final json = await _api.post(
      '/me/vehicles',
      body: ApiMappers.vehicleToApi(vehicle),
    ) as Map<String, dynamic>;

    return ApiMappers.vehicleFromApi(json);
  }

  @override
  Future<void> removeVehicle(String id) {
    return _api.delete('/me/vehicles/$id');
  }
}
