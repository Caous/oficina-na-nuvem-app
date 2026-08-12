import 'package:http/http.dart' as http;

import '../../features/auth/data/repositories/account_registration_repository.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/data/services/api_account_registration_service.dart';
import '../../features/auth/data/services/api_auth_service.dart';
import '../../features/auth/presentation/view_models/account_registration_view_model.dart';
import '../../features/auth/presentation/view_models/login_view_model.dart';
import '../../features/customers/data/repositories/customer_repository.dart';
import '../../features/customers/data/services/api_customer_service.dart';
import '../../features/customers/data/services/api_fipe_service.dart';
import '../../features/client_home/data/repositories/client_garage_repository.dart';
import '../../features/client_home/data/services/api_client_garage_service.dart';
import '../../features/client_home/presentation/view_models/client_home_view_model.dart';
import '../../features/client_home/presentation/view_models/client_vehicles_view_model.dart';
import '../../features/customers/models/customer.dart';
import '../../features/customers/presentation/view_models/vehicle_form_view_model.dart';
import '../../features/customers/presentation/view_models/vehicle_onboarding_view_model.dart';
import '../../features/dashboard/data/repositories/dashboard_repository.dart';
import '../../features/dashboard/data/services/api_dashboard_service.dart';
import '../../features/dashboard/presentation/view_models/dashboard_view_model.dart';
import '../../features/employees/data/repositories/employee_repository.dart';
import '../../features/employees/data/services/api_employee_service.dart';
import '../../features/employees/models/employee.dart';
import '../../features/auth/data/services/mock_account_registration_service.dart';
import '../../features/auth/data/services/mock_auth_service.dart';
import '../../features/client_home/data/services/mock_client_garage_service.dart';
import '../../features/customers/data/services/mock_customer_service.dart';
import '../../features/customers/data/services/mock_fipe_service.dart';
import '../../features/dashboard/data/services/mock_dashboard_service.dart';
import '../../features/employees/data/services/mock_employee_service.dart';
import '../../features/marketplace/data/services/api_marketplace_order_service.dart';
import '../../features/marketplace/data/services/marketplace_order_service.dart';
import '../../features/marketplace/data/services/mock_marketplace_order_service.dart';
import '../../features/service_catalog/data/services/mock_service_catalog_service.dart';
import '../../features/service_orders/data/services/mock_service_order_service.dart';
import '../../shared/products/data/services/mock_product_service.dart';
import '../../features/employees/presentation/view_models/employee_form_view_model.dart';
import '../../features/employees/presentation/view_models/employees_view_model.dart';
import '../../features/inventory/presentation/view_models/inventory_view_model.dart';
import '../../features/inventory/presentation/view_models/product_form_view_model.dart';
import '../../features/marketplace/presentation/view_models/marketplace_view_model.dart';
import '../../features/service_catalog/data/repositories/service_catalog_repository.dart';
import '../../features/service_catalog/data/services/api_service_catalog_service.dart';
import '../../features/service_catalog/models/workshop_service.dart';
import '../../features/service_catalog/presentation/view_models/service_categories_view_model.dart';
import '../../features/service_catalog/presentation/view_models/service_form_view_model.dart';
import '../../features/service_catalog/presentation/view_models/services_view_model.dart';
import '../../features/service_orders/data/repositories/service_order_repository.dart';
import '../../features/service_orders/data/services/api_service_order_service.dart';
import '../../features/service_orders/presentation/view_models/service_order_form_view_model.dart';
import '../../features/service_orders/presentation/view_models/service_orders_view_model.dart';
import '../../shared/address_lookup/models/address.dart';
import '../../shared/address_lookup/presentation/address_form_controller.dart';
import '../../shared/address_lookup/repositories/cep_repository.dart';
import '../../shared/address_lookup/repositories/cep_repository_impl.dart';
import '../../shared/address_lookup/services/via_cep_service.dart';
import '../../shared/products/data/repositories/product_repository.dart';
import '../../shared/products/data/services/api_product_service.dart';
import '../../shared/products/models/product.dart';
import '../network/api_client.dart';
import '../network/auth_session.dart';

/// Composition root da aplicação.
///
/// Concentra a montagem do grafo de dependências: só aqui as implementações
/// concretas (HTTP) são citadas. Voltar aos mocks é uma alteração localizada
/// neste arquivo.
///
/// View models de tela única são criados sob demanda pelos métodos `create*`,
/// para que cada abertura de formulário comece com estado limpo. Os de longa
/// duração (abas da navegação) são instanciados uma única vez.
class AppDependencies {
  final AuthSession authSession;
  final MarketplaceOrderService marketplaceOrderService;
  final AuthRepository authRepository;
  final AccountRegistrationRepository accountRegistrationRepository;
  final CustomerRepository customerRepository;
  final DashboardRepository dashboardRepository;
  final EmployeeRepository employeeRepository;
  final ServiceCatalogRepository serviceCatalogRepository;
  final ServiceOrderRepository serviceOrderRepository;
  final CepRepository cepRepository;
  final ClientGarageRepository clientGarageRepository;
  final ProductRepository productRepository;

  final LoginViewModel loginViewModel;
  final AccountRegistrationViewModel accountRegistrationViewModel;
  final DashboardViewModel dashboardViewModel;
  final EmployeesViewModel employeesViewModel;
  final ServiceCategoriesViewModel serviceCategoriesViewModel;
  final ServicesViewModel servicesViewModel;
  final ServiceOrdersViewModel serviceOrdersViewModel;
  final InventoryViewModel inventoryViewModel;

  AppDependencies._({
    required this.authSession,
    required this.marketplaceOrderService,
    required this.authRepository,
    required this.accountRegistrationRepository,
    required this.customerRepository,
    required this.dashboardRepository,
    required this.employeeRepository,
    required this.serviceCatalogRepository,
    required this.serviceOrderRepository,
    required this.cepRepository,
    required this.clientGarageRepository,
    required this.productRepository,
    required this.loginViewModel,
    required this.accountRegistrationViewModel,
    required this.dashboardViewModel,
    required this.employeesViewModel,
    required this.serviceCategoriesViewModel,
    required this.servicesViewModel,
    required this.serviceOrdersViewModel,
    required this.inventoryViewModel,
  });

  /// Monta o grafo completo contra o backend real.
  factory AppDependencies.bootstrap() {
    final httpClient = http.Client();
    final authSession = AuthSession();

    final api = ApiClient(httpClient: httpClient, session: authSession);

    final customerService = ApiCustomerService(api: api);
    final catalogService = ApiServiceCatalogService(api: api);
    final marketplaceOrderService = ApiMarketplaceOrderService(api: api);

    final cepRepository = CepRepositoryImpl(
      service: ViaCepService(client: httpClient),
    );

    final productRepository = ProductRepository(
      service: ApiProductService(api: api),
    );

    final clientGarageRepository = ClientGarageRepository(
      service: ApiClientGarageService(api: api),
    );

    final authRepository = AuthRepository(
      authService: ApiAuthService(api: api),
    );

    final accountRegistrationRepository = AccountRegistrationRepository(
      service: ApiAccountRegistrationService(api: api),
    );

    final customerRepository = CustomerRepository(
      customerService: customerService,
      vehicleService: customerService,
      fipeService: ApiFipeService(api: api),
    );

    final serviceOrderRepository = ServiceOrderRepository(
      service: ApiServiceOrderService(api: api),
    );

    final dashboardRepository = DashboardRepository(
      service: ApiDashboardService(api: api),
    );

    final employeeRepository = EmployeeRepository(
      service: ApiEmployeeService(api: api),
    );

    final serviceCatalogRepository = ServiceCatalogRepository(
      categoryService: catalogService,
      serviceService: catalogService,
    );

    return AppDependencies._(
      authSession: authSession,
      marketplaceOrderService: marketplaceOrderService,
      authRepository: authRepository,
      accountRegistrationRepository: accountRegistrationRepository,
      customerRepository: customerRepository,
      dashboardRepository: dashboardRepository,
      employeeRepository: employeeRepository,
      serviceCatalogRepository: serviceCatalogRepository,
      serviceOrderRepository: serviceOrderRepository,
      cepRepository: cepRepository,
      clientGarageRepository: clientGarageRepository,
      productRepository: productRepository,
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
      inventoryViewModel: InventoryViewModel(repository: productRepository),
    );
  }

  /// Monta o grafo inteiro sobre os mocks em memória — o modo dos testes de
  /// widget, que exercitam a interface sem rede.
  factory AppDependencies.mocked() {
    final customerService = MockCustomerService();
    final catalogService = MockServiceCatalogService();

    final cepRepository = CepRepositoryImpl(
      service: ViaCepService(client: http.Client()),
    );

    final productRepository = ProductRepository(service: MockProductService());

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
      authSession: AuthSession(),
      marketplaceOrderService: MockMarketplaceOrderService(),
      authRepository: authRepository,
      accountRegistrationRepository: accountRegistrationRepository,
      customerRepository: customerRepository,
      dashboardRepository: dashboardRepository,
      employeeRepository: employeeRepository,
      serviceCatalogRepository: serviceCatalogRepository,
      serviceOrderRepository: serviceOrderRepository,
      cepRepository: cepRepository,
      clientGarageRepository: clientGarageRepository,
      productRepository: productRepository,
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
      inventoryViewModel: InventoryViewModel(repository: productRepository),
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

  ProductFormViewModel createProductFormViewModel(Product? product) {
    return ProductFormViewModel(
      repository: productRepository,
      initial: product,
    );
  }

  MarketplaceViewModel createMarketplaceViewModel() {
    return MarketplaceViewModel(
      repository: productRepository,
      orderService: marketplaceOrderService,
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
