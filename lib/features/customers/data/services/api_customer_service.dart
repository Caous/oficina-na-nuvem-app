import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_mappers.dart';
import '../../models/customer.dart';
import '../../models/vehicle.dart';
import 'customer_service.dart';

/// Clientes vistos do balcão da oficina: só os já vinculados a ela. O veículo
/// criado aqui vai para a garagem do próprio cliente.
class ApiCustomerService implements CustomerService, VehicleService {
  final ApiClient _api;

  ApiCustomerService({required ApiClient api}) : _api = api;

  @override
  Future<List<Customer>> fetchCustomers() async {
    final json = await _api.get('/customers') as List<dynamic>;

    return json
        .map((item) => _customerFromApi(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<List<Vehicle>> fetchVehiclesOf(String customerId) async {
    final json = await _api.get('/customers/$customerId/vehicles') as List<dynamic>;

    return json
        .map((item) => ApiMappers.vehicleFromApi(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    final json = await _api.post(
      '/customers/${vehicle.customerId}/vehicles',
      body: ApiMappers.vehicleToApi(vehicle),
    ) as Map<String, dynamic>;

    return ApiMappers.vehicleFromApi(json);
  }

  Customer _customerFromApi(Map<String, dynamic> json) {
    return Customer(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      document: json['document']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}
