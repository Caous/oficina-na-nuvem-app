import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:oficina_app/core/network/api_client.dart';
import 'package:oficina_app/core/network/auth_session.dart';
import 'package:oficina_app/features/auth/data/services/api_auth_service.dart';
import 'package:oficina_app/features/auth/models/user.dart';
import 'package:oficina_app/features/client_home/data/services/api_client_garage_service.dart';
import 'package:oficina_app/features/customers/data/services/api_customer_service.dart';
import 'package:oficina_app/features/customers/data/services/api_fipe_service.dart';
import 'package:oficina_app/features/dashboard/data/services/api_dashboard_service.dart';
import 'package:oficina_app/features/employees/data/services/api_employee_service.dart';
import 'package:oficina_app/features/service_catalog/data/services/api_service_catalog_service.dart';
import 'package:oficina_app/features/service_orders/data/services/api_service_order_service.dart';
import 'package:oficina_app/shared/products/data/services/api_product_service.dart';

/// Exercita os services de API contra um backend de verdade.
///
/// Fica fora de `test/` de propósito: `flutter test` roda só o que está lá, e
/// estes aqui precisam da API no ar. Para rodá-los, aponte o endereço:
///
/// ```
/// flutter test test_integration \
///   --dart-define=API_BASE_URL=http://localhost:8081/api
/// ```
///
/// Provam o que os testes de widget não alcançam: cabeçalhos, JSON e a
/// tradução entre os nomes dos dois lados.
void main() {
  const ownerEmail = 'contato@oficinadoze.com';
  const customerEmail = 'joao@email.com';
  const password = 'secret123';

  late ApiClient api;
  late AuthSession session;

  setUp(() {
    session = AuthSession();
    api = ApiClient(httpClient: http.Client(), session: session);
  });

  Future<void> signInAs(String email) async {
    final user = await ApiAuthService(api: api).loginAsync(
      email: email,
      password: password,
    );

    expect(user, isNotNull, reason: 'login de $email falhou');
  }

  group('área da oficina', () {
    setUp(() => signInAs(ownerEmail));

    test('login devolve papel de oficina e guarda o token', () async {
      expect(session.isAuthenticated, isTrue);

      final user = await ApiAuthService(api: api).loginAsync(
        email: ownerEmail,
        password: password,
      );

      expect(user!.role, UserRole.workshop);
      expect(user.email, ownerEmail);
    });

    test('dashboard traz nome, métricas e sete dias na série', () async {
      final summary = await ApiDashboardService(api: api).fetchSummary();

      expect(summary.workshopName, isNotEmpty);
      expect(summary.metrics, hasLength(4));
      expect(summary.weeklyServices, hasLength(7));
      expect(summary.metrics.first.value, isNotEmpty);
    });

    test('funcionários chegam com cargo traduzido', () async {
      final employees = await ApiEmployeeService(api: api).fetchAll();

      expect(employees, isNotEmpty);
      expect(employees.first.name, isNotEmpty);
      expect(employees.first.role.label, isNotEmpty);
    });

    test('catálogo devolve categorias e serviços com desconto', () async {
      final catalog = ApiServiceCatalogService(api: api);

      final categories = await catalog.fetchCategories();
      final services = await catalog.fetchServices();

      expect(categories, isNotEmpty);
      expect(services, isNotEmpty);
      expect(services.first.price, greaterThan(0));
      expect(services.first.minimumPrice, lessThanOrEqualTo(services.first.price));
    });

    test('ordens de serviço trazem itens e total somado', () async {
      final orders = await ApiServiceOrderService(api: api).fetchAll();

      expect(orders, isNotEmpty);
      expect(orders.first.number, isNotEmpty);
      expect(orders.first.items, isNotEmpty);
      expect(orders.first.total, greaterThan(0));
    });

    test('estoque privado responde à oficina', () async {
      final products = await ApiProductService(api: api).fetchAll();

      expect(products, isNotEmpty);
      expect(products.first.sku, isNotEmpty);
    });

    test('clientes vinculados e seus veículos', () async {
      final customers = ApiCustomerService(api: api);

      final list = await customers.fetchCustomers();
      expect(list, isNotEmpty);

      final vehicles = await customers.fetchVehiclesOf(list.first.id);
      expect(vehicles, isNotEmpty);
      expect(vehicles.first.plate, isNotEmpty);
    });
  });

  group('área do cliente', () {
    setUp(() => signInAs(customerEmail));

    test('login devolve papel de cliente', () async {
      final user = await ApiAuthService(api: api).loginAsync(
        email: customerEmail,
        password: password,
      );

      expect(user!.role, UserRole.client);
    });

    test('garagem traz os veículos do próprio cliente', () async {
      final vehicles = await ApiClientGarageService(api: api).fetchMyVehicles();

      expect(vehicles, isNotEmpty);
      expect(vehicles.first.fullName, isNotEmpty);
    });

    test('marketplace mostra publicados com vendedor', () async {
      final products = await ApiProductService(api: api).fetchPublished();

      expect(products, isNotEmpty);
      expect(products.first.sellerName, isNotEmpty);
      expect(products.first.isVisibleOnMarketplace, isTrue);
    });

    test('cliente não alcança o estoque privado', () async {
      expect(
        () => ApiProductService(api: api).fetchAll(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('FIPE', () {
    setUp(() => signInAs(customerEmail));

    test('marca → modelo → ano → cotação', () async {
      final fipe = ApiFipeService(api: api);

      final brands = await fipe.fetchBrands();
      expect(brands, isNotEmpty);

      final fiat = brands.firstWhere((brand) => brand.name == 'Fiat');
      final models = await fipe.fetchModelsOf(fiat.code);
      expect(models, isNotEmpty);

      final years = await fipe.fetchYearsOf(models.first.code);
      expect(years, isNotEmpty);

      final quote = await fipe.fetchQuote(
        brandCode: fiat.code,
        modelCode: models.first.code,
        yearCode: years.first.code,
      );

      expect(quote.value, greaterThan(0));
      expect(quote.fipeCode, isNotEmpty);
    }, timeout: const Timeout(Duration(seconds: 90)));
  });
}
