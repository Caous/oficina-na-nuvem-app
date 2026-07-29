import 'package:flutter/foundation.dart';

import '../../../customers/data/repositories/customer_repository.dart';
import '../../../customers/models/customer.dart';
import '../../../customers/models/vehicle.dart';
import '../../../employees/data/repositories/employee_repository.dart';
import '../../../employees/models/employee.dart';
import '../../../service_catalog/data/repositories/service_catalog_repository.dart';
import '../../../service_catalog/models/workshop_service.dart';
import '../../data/repositories/service_order_repository.dart';
import '../../models/service_order.dart';

/// Abertura de uma nova ordem de serviço: escolha de cliente, veículo,
/// serviços do catálogo e mecânico responsável.
///
/// Trocar o cliente sempre limpa o veículo selecionado e recarrega a lista
/// de veículos daquele cliente, evitando exibir uma combinação inconsistente.
class ServiceOrderFormViewModel extends ChangeNotifier {
  final ServiceOrderRepository _orderRepository;
  final CustomerRepository _customerRepository;
  final ServiceCatalogRepository _catalogRepository;
  final EmployeeRepository _employeeRepository;

  ServiceOrderFormViewModel({
    required ServiceOrderRepository orderRepository,
    required CustomerRepository customerRepository,
    required ServiceCatalogRepository catalogRepository,
    required EmployeeRepository employeeRepository,
  }) : _orderRepository = orderRepository,
       _customerRepository = customerRepository,
       _catalogRepository = catalogRepository,
       _employeeRepository = employeeRepository;

  List<Customer> _customers = const [];
  List<WorkshopService> _availableServices = const [];
  List<Employee> _employees = const [];
  List<Vehicle> _customerVehicles = const [];

  Customer? _selectedCustomer;
  Vehicle? _selectedVehicle;
  Employee? _selectedEmployee;
  List<WorkshopService> _selectedServices = [];

  bool _isLoading = false;
  bool _isLoadingVehicles = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<Customer> get customers => _customers;
  List<WorkshopService> get availableServices => _availableServices;
  List<Employee> get employees => _employees;
  List<Vehicle> get customerVehicles => _customerVehicles;

  Customer? get selectedCustomer => _selectedCustomer;
  Vehicle? get selectedVehicle => _selectedVehicle;
  Employee? get selectedEmployee => _selectedEmployee;
  List<WorkshopService> get selectedServices => _selectedServices;

  bool get isLoading => _isLoading;
  bool get isLoadingVehicles => _isLoadingVehicles;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  /// Indica que o cliente escolhido ainda não tem veículo cadastrado.
  bool get needsVehicle =>
      _selectedCustomer != null && !_isLoadingVehicles && _customerVehicles.isEmpty;

  /// Soma dos preços dos serviços já adicionados à ordem.
  double get total =>
      _selectedServices.fold(0, (accumulated, service) => accumulated + service.price);

  bool get canSubmit =>
      _selectedCustomer != null &&
      _selectedVehicle != null &&
      _selectedServices.isNotEmpty &&
      !_isSaving;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _customerRepository.fetchCustomers(),
        _catalogRepository.fetchServices(),
        _employeeRepository.fetchAll(),
      ]);

      _customers = results[0] as List<Customer>;
      _availableServices = results[1] as List<WorkshopService>;
      _employees = results[2] as List<Employee>;
    } catch (_) {
      _errorMessage = 'Não foi possível carregar os dados do formulário.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCustomer(Customer customer) async {
    _selectedCustomer = customer;
    _selectedVehicle = null;
    _customerVehicles = const [];
    _isLoadingVehicles = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final vehicles = await _customerRepository.fetchVehiclesOf(customer.id);
      _customerVehicles = vehicles;

      if (vehicles.length == 1) {
        _selectedVehicle = vehicles.first;
      }
    } catch (_) {
      _errorMessage = 'Não foi possível carregar os veículos do cliente.';
    } finally {
      _isLoadingVehicles = false;
      notifyListeners();
    }
  }

  void selectVehicle(Vehicle vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  /// Adiciona um veículo recém-cadastrado pela Tabela FIPE e já o seleciona.
  void attachCreatedVehicle(Vehicle vehicle) {
    _customerVehicles = [..._customerVehicles, vehicle];
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  void selectEmployee(Employee employee) {
    _selectedEmployee = employee;
    notifyListeners();
  }

  void addService(WorkshopService service) {
    final alreadyAdded = _selectedServices.any((s) => s.id == service.id);

    if (alreadyAdded) {
      return;
    }

    _selectedServices = [..._selectedServices, service];
    notifyListeners();
  }

  void removeService(String serviceId) {
    _selectedServices =
        _selectedServices.where((service) => service.id != serviceId).toList();
    notifyListeners();
  }

  /// Monta e envia a nova ordem de serviço. Retorna a ordem criada, ou
  /// `null` em caso de falha.
  Future<ServiceOrder?> submit() async {
    final customer = _selectedCustomer;
    final vehicle = _selectedVehicle;

    if (customer == null || vehicle == null || _selectedServices.isEmpty) {
      _errorMessage = 'Selecione cliente, veículo e ao menos um serviço.';
      notifyListeners();
      return null;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = ServiceOrder(
        id: '',
        number: '',
        status: ServiceOrderStatus.awaitingApproval,
        customerId: customer.id,
        customerName: customer.name,
        vehicleId: vehicle.id,
        vehicleDescription: vehicle.shortDescription,
        summary: _selectedServices.map((service) => service.name).join(' + '),
        items: _selectedServices
            .map(
              (service) => ServiceOrderItem(
                serviceId: service.id,
                serviceName: service.name,
                price: service.price,
              ),
            )
            .toList(),
        openedAt: DateTime.now(),
        assignedEmployeeId: _selectedEmployee?.id,
        assignedEmployeeName: _selectedEmployee?.name,
      );

      return await _orderRepository.create(order);
    } catch (_) {
      _errorMessage = 'Não foi possível abrir a ordem de serviço.';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
