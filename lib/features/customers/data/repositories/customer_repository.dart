import '../../models/customer.dart';
import '../../models/fipe_reference.dart';
import '../../models/vehicle.dart';
import '../services/customer_service.dart';
import '../services/fipe_service.dart';

/// Ponto de acesso a clientes, seus veículos e à consulta FIPE.
class CustomerRepository {
  final CustomerService _customerService;
  final VehicleService _vehicleService;
  final FipeService _fipeService;

  CustomerRepository({
    required CustomerService customerService,
    required VehicleService vehicleService,
    required FipeService fipeService,
  }) : _customerService = customerService,
       _vehicleService = vehicleService,
       _fipeService = fipeService;

  Future<List<Customer>> fetchCustomers() => _customerService.fetchCustomers();

  Future<List<Vehicle>> fetchVehiclesOf(String customerId) =>
      _vehicleService.fetchVehiclesOf(customerId);

  Future<Vehicle> createVehicle(Vehicle vehicle) =>
      _vehicleService.createVehicle(vehicle);

  Future<List<FipeBrand>> fetchBrands() => _fipeService.fetchBrands();

  Future<List<FipeModel>> fetchModelsOf(String brandCode) =>
      _fipeService.fetchModelsOf(brandCode);

  Future<List<FipeYear>> fetchYearsOf(String modelCode) =>
      _fipeService.fetchYearsOf(modelCode);

  Future<FipeQuote> fetchQuote({
    required String brandCode,
    required String modelCode,
    required String yearCode,
  }) {
    return _fipeService.fetchQuote(
      brandCode: brandCode,
      modelCode: modelCode,
      yearCode: yearCode,
    );
  }
}
