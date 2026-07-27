import 'package:http/http.dart' as http;

import '../../features/auth/data/repositories/account_registration_repository.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/data/services/mock_account_registration_service.dart';
import '../../features/auth/data/services/mock_auth_service.dart';
import '../../features/auth/presentation/view_models/account_registration_view_model.dart';
import '../../features/auth/presentation/view_models/login_view_model.dart';
import '../../features/customers/data/repositories/customer_repository.dart';
import '../../features/customers/data/services/mock_customer_service.dart';
import '../../features/customers/data/services/mock_fipe_service.dart';
import '../../features/client_home/data/repositories/client_garage_repository.dart';
import '../../features/client_home/data/services/mock_client_garage_service.dart';
import '../../features/client_home/presentation/view_models/client_home_view_model.dart';
import '../../features/client_home/presentation/view_models/client_vehicles_view_model.dart';
import '../../features/customers/models/customer.dart';
import '../../features/customers/presentation/view_models/vehicle_form_view_model.dart';
import '../../features/customers/presentation/view_models/vehicle_onboarding_view_model.dart';
import '../../features/dashboard/data/repositories/dashboard_repository.dart';
import '../../features/dashboard/data/services/mock_dashboard_service.dart';
import '../../features/dashboard/presentation/view_models/dashboard_view_model.dart';
import '../../features/employees/data/repositories/employee_repository.dart';
import '../../features/employees/data/services/mock_employee_service.dart';
import '../../features/employees/models/employee.dart';
import '../../features/employees/presentation/view_models/employee_form_view_model.dart';
import '../../features/employees/presentation/view_models/employees_view_model.dart';
import '../../features/service_catalog/data/repositories/service_catalog_repository.dart';
import '../../features/service_catalog/data/services/mock_service_catalog_service.dart';
import '../../features/service_catalog/models/workshop_service.dart';
import '../../features/service_catalog/presentation/view_models/service_categories_view_model.dart';
import '../../features/service_catalog/presentation/view_models/service_form_view_model.dart';
import '../../features/service_catalog/presentation/view_models/services_view_model.dart';
import '../../features/service_orders/data/repositories/service_order_repository.dart';
import '../../features/service_orders/data/services/mock_service_order_service.dart';
import '../../features/service_orders/presentation/view_models/service_order_form_view_model.dart';
import '../../features/service_orders/presentation/view_models/service_orders_view_model.dart';
import '../../shared/address_lookup/models/address.dart';
import '../../shared/address_lookup/presentation/address_form_controller.dart';
import '../../shared/address_lookup/repositories/cep_repository.dart';
import '../../shared/address_lookup/repositories/cep_repository_impl.dart';
import '../../shared/address_lookup/services/via_cep_service.dart';

/// Composition root da aplicação.
///
/// Concentra a montagem do grafo de dependências: só aqui as implementações
/// mock são citadas. Trocar um mock por um cliente HTTP é uma alteração
/// localizada neste arquivo.
///
/// View models de tela única são criados sob demanda pelos métodos `create*`,
/// para que cada abertura de formulário comece com estado limpo. Os de longa
/// duração (abas da navegação) são instanciados uma única vez.
class AppDependencies {
  final AuthRepository authRepository;
  final AccountRegistrationRepository accountRegistrationRepository;
  final CustomerRepository customerRepository;
  final DashboardRepository dashboardRepository;
  final EmployeeRepository employeeRepository;
  final ServiceCatalogRepository serviceCatalogRepository;
  final ServiceOrderRepository serviceOrderRepository;
  final CepRepository cepRepository;
  final ClientGarageRepository clientGarageRepository;

  final LoginViewModel loginViewModel;
  final AccountRegistrationViewModel accountRegistrationViewModel;
  final DashboardViewModel dashboardViewModel;
  final EmployeesViewModel employeesViewModel;
  final ServiceCategoriesViewModel serviceCategoriesViewModel;
  final ServicesViewModel servicesViewModel;
  final ServiceOrdersViewModel serviceOrdersViewModel;

  AppDependencies._({
    required this.authRepository,
    required this.accountRegistrationRepository,
    required this.customerRepository,
    required this.dashboardRepository,
    required this.employeeRepository,
    required this.serviceCatalogRepository,
    required this.serviceOrderRepository,
    required this.cepRepository,
    required this.clientGarageRepository,
    required this.loginViewModel,
    required this.accountRegistrationViewModel,
    required this.dashboardViewModel,
    required this.employeesViewModel,
    required this.serviceCategoriesViewModel,
    required this.servicesViewModel,
    required this.serviceOrdersViewModel,
  });

  /// Monta o grafo completo com as implementações mock.
  factory AppDependencies.bootstrap() {
    final customerService = MockCustomerService();
    final catalogService = MockServiceCatalogService();

    final cepRepository = CepRepositoryImpl(
      service: ViaCepService(client: http.Client()),
    );

    final clientGarageRepository = ClientGarageRepository(
      service: MockClientGarageService(),
    );

    final authRepository = AuthRepository(authService: MockAuthService());

    final accountRegistrationRepository = AccountRegistrationRepository(
      service: MockAccountRegistrationService(),
    );

    final customerRepository = CustomerRepository(
      customerService: customerService,
      vehicleService: customerService,
      fipeService: MockFipeService(),
    );

    final serviceOrderRepository = ServiceOrderRepository(
      service: MockServiceOrderService(),
    );

    final dashboardRepository = DashboardRepository(
      service: MockDashboardService(
        serviceOrderRepository: serviceOrderRepository,
      ),
    );

    final employeeRepository = EmployeeRepository(
      service: MockEmployeeService(),
    );

    final serviceCatalogRepository = ServiceCatalogRepository(
      categoryService: catalogService,
      serviceService: catalogService,
    );

    return AppDependencies._(
      authRepository: authRepository,
      accountRegistrationRepository: accountRegistrationRepository,
      customerRepository: customerRepository,
      dashboardRepository: dashboardRepository,
      employeeRepository: employeeRepository,
      serviceCatalogRepository: serviceCatalogRepository,
      serviceOrderRepository: serviceOrderRepository,
      cepRepository: cepRepository,
      clientGarageRepository: clientGarageRepository,
      loginViewModel: LoginViewModel(authRepository: authRepository),
      accountRegistrationViewModel: AccountRegistrationViewModel(
        repository: accountRegistrationRepository,
      ),
      dashboardViewModel: DashboardViewModel(repository: dashboardRepository),
      employeesViewModel: EmployeesViewModel(repository: employeeRepository),
      serviceCategoriesViewModel: ServiceCategoriesViewModel(
        repository: serviceCatalogRepository,
      ),
      servicesViewModel: ServicesViewModel(
        repository: serviceCatalogRepository,
      ),
      serviceOrdersViewModel: ServiceOrdersViewModel(
        repository: serviceOrderRepository,
      ),
    );
  }

  EmployeeFormViewModel createEmployeeFormViewModel(Employee? employee) {
    return EmployeeFormViewModel(
      repository: employeeRepository,
      initial: employee,
    );
  }

  ServiceFormViewModel createServiceFormViewModel(WorkshopService? service) {
    return ServiceFormViewModel(
      repository: serviceCatalogRepository,
      initial: service,
    );
  }

  ClientHomeViewModel createClientHomeViewModel({required String userName}) {
    return ClientHomeViewModel(
      repository: clientGarageRepository,
      userName: userName,
    );
  }

  ClientVehiclesViewModel createClientVehiclesViewModel() {
    return ClientVehiclesViewModel(repository: clientGarageRepository);
  }

  VehicleOnboardingViewModel createVehicleOnboardingViewModel() {
    return VehicleOnboardingViewModel(
      fipeRepository: customerRepository,
      garageRepository: clientGarageRepository,
    );
  }

  /// Cada formulário recebe seu próprio controlador de endereço, para que o
  /// estado da consulta não vaze entre telas.
  AddressFormController createAddressFormController({Address? initial}) {
    return AddressFormController(repository: cepRepository, initial: initial);
  }

  ServiceOrderFormViewModel createServiceOrderFormViewModel() {
    return ServiceOrderFormViewModel(
      orderRepository: serviceOrderRepository,
      customerRepository: customerRepository,
      catalogRepository: serviceCatalogRepository,
      employeeRepository: employeeRepository,
    );
  }

  VehicleFormViewModel createVehicleFormViewModel(Customer customer) {
    return VehicleFormViewModel(
      repository: customerRepository,
      customerId: customer.id,
      customerName: customer.name,
    );
  }
}
