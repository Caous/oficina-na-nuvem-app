import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oficina_app/main.dart';

import 'package:oficina_app/core/di/app_dependencies.dart';
import 'package:oficina_app/core/navigation/workshop_shell.dart';
import 'package:oficina_app/core/theme/app_theme.dart';
import 'package:oficina_app/core/widgets/shop_bottom_nav.dart';
import 'package:oficina_app/features/auth/presentation/pages/registration_flow_page.dart';
import 'package:oficina_app/features/customers/models/customer.dart';
import 'package:oficina_app/features/customers/models/vehicle.dart';
import 'package:oficina_app/features/customers/presentation/pages/vehicle_form_page.dart';
import 'package:oficina_app/features/customers/presentation/pages/vehicle_onboarding_page.dart';
import 'package:oficina_app/features/employees/presentation/pages/employee_form_page.dart';
import 'package:oficina_app/features/service_catalog/presentation/pages/service_categories_page.dart';
import 'package:oficina_app/features/service_catalog/presentation/pages/service_form_page.dart';
import 'package:oficina_app/features/service_orders/presentation/pages/service_order_form_page.dart';

/// Renderiza [child] em um app completo, com tema e tamanho de tela de celular.
Future<void> _pumpScreen(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(402 * 3, 874 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(theme: AppTheme.build(), home: child));
  await _settle(tester);
}

/// Renderiza o aplicativo completo, a partir do `main`.
Future<void> _pumpApp(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(402 * 3, 874 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(app);
  await _settle(tester);
}

/// Avança o tempo o suficiente para os serviços mock resolverem.
///
/// `pumpAndSettle` sozinho não basta: sem animação pendente ele retorna antes
/// dos `Future.delayed` dos mocks completarem. A janela cobre o mock mais
/// lento — a autenticação, que leva 3 segundos.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

void main() {
  late AppDependencies dependencies;

  setUp(() {
    dependencies = AppDependencies.mocked();
  });

  testWidgets('dashboard renderiza indicadores e ordens recentes', (
    tester,
  ) async {
    await _pumpScreen(tester, WorkshopShell(dependencies: dependencies));

    expect(find.text('Oficina do Zé'), findsOneWidget);
    expect(find.text('OS abertas'), findsOneWidget);
    expect(find.text('Serviços na semana'), findsOneWidget);
    expect(find.text('Ordens recentes'), findsOneWidget);
  });

  testWidgets('navegação inferior alterna entre as quatro abas', (
    tester,
  ) async {
    await _pumpScreen(tester, WorkshopShell(dependencies: dependencies));

    for (final tab in ShopTab.values) {
      await tester.tap(find.text(tab.label));
      await _settle(tester);
    }

    expect(find.text('Funcionários'), findsOneWidget);
  });

  testWidgets('lista de ordens exibe filtros de status', (tester) async {
    await _pumpScreen(tester, WorkshopShell(dependencies: dependencies));

    await tester.tap(find.text(ShopTab.orders.label));
    await _settle(tester);

    expect(find.text('Ordens de Serviço'), findsOneWidget);
    expect(find.text('Em andamento'), findsWidgets);
    expect(find.text('Aguardando aprovação'), findsWidgets);
  });

  testWidgets('botão de nova ordem abre o formulário de ordem, não o de serviço', (
    tester,
  ) async {
    await _pumpScreen(tester, WorkshopShell(dependencies: dependencies));

    await tester.tap(find.text(ShopTab.orders.label));
    await _settle(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await _settle(tester);

    expect(find.text('Nova Ordem de Serviço'), findsOneWidget);
    expect(find.text('Novo Serviço'), findsNothing);
  });

  testWidgets('catálogo de serviços exibe preço e desconto máximo', (
    tester,
  ) async {
    await _pumpScreen(tester, WorkshopShell(dependencies: dependencies));

    await tester.tap(find.text(ShopTab.services.label));
    await _settle(tester);

    expect(find.text('Serviços'), findsWidgets);
    expect(find.text('Troca de óleo e filtro'), findsOneWidget);
    expect(find.text('R\$ 189,90'), findsOneWidget);
  });

  testWidgets('categorias de serviço listam a contagem de serviços', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      ServiceCategoriesPage(
        viewModel: dependencies.serviceCategoriesViewModel,
      ),
    );

    expect(find.text('Categorias de Serviço'), findsOneWidget);
    expect(find.text('Nova categoria'), findsOneWidget);
    expect(find.text('Motor'), findsOneWidget);
  });

  testWidgets('formulário de funcionário renderiza todos os campos', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      EmployeeFormPage(
        viewModel: dependencies.createEmployeeFormViewModel(null),
        addressController: dependencies.createAddressFormController(),
      ),
    );

    expect(find.text('Novo Funcionário'), findsOneWidget);
    expect(find.text('Nome completo'), findsOneWidget);
    expect(find.text('CPF'), findsOneWidget);
    expect(find.text('Cargo'), findsOneWidget);
  });

  testWidgets('cadastro de serviço trata só do catálogo, sem cliente', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      ServiceFormPage(
        viewModel: dependencies.createServiceFormViewModel(null),
      ),
    );

    expect(find.text('Categoria do serviço'), findsOneWidget);
    expect(find.text('Nome do serviço'), findsOneWidget);
    expect(find.text('Valor (R\$)'), findsOneWidget);
    expect(find.text('Desconto máx.'), findsOneWidget);

    // Cliente e veículo pertencem à ordem de serviço, não ao catálogo.
    expect(find.text('Cliente'), findsNothing);
    expect(find.text('Veículo do cliente'), findsNothing);
  });

  testWidgets('cadastro de serviço permite criar categoria na hora', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      ServiceFormPage(
        viewModel: dependencies.createServiceFormViewModel(null),
      ),
    );

    await tester.tap(find.text('Nova categoria'));
    await _settle(tester);

    await tester.enterText(find.byType(TextField).last, 'Ar-condicionado');
    await tester.tap(find.text('Criar'));
    await _settle(tester);

    // A categoria criada já fica selecionada no campo.
    expect(find.text('Ar-condicionado'), findsOneWidget);
  });

  testWidgets('nova ordem de serviço reúne cliente, veículo e serviços', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      ServiceOrderFormPage(
        viewModel: dependencies.createServiceOrderFormViewModel(),
        onRegisterVehicle: (_) async => null,
      ),
    );

    expect(find.text('Nova Ordem de Serviço'), findsOneWidget);
    expect(find.text('Cliente'), findsOneWidget);
    expect(find.text('Adicionar serviço'), findsOneWidget);
  });

  testWidgets('cliente sem veículo recebe o convite de cadastro FIPE', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      ServiceOrderFormPage(
        viewModel: dependencies.createServiceOrderFormViewModel(),
        onRegisterVehicle: (_) async => null,
      ),
    );

    await tester.tap(find.text('Selecione ou busque o cliente'));
    await _settle(tester);

    // Maria Santos é o cliente semeado sem veículos.
    await tester.tap(find.text('Maria Santos').last);
    await _settle(tester);

    expect(find.text('Nenhum veículo'), findsOneWidget);
    expect(find.text('Cadastre via Tabela FIPE'), findsOneWidget);
  });

  testWidgets('cadastro de veículo consulta a FIPE em cascata', (tester) async {
    const customer = Customer(
      id: 'c2',
      name: 'Maria Santos',
      document: '234.567.890-11',
      phone: '(11) 97777-2222',
      email: 'maria.santos@email.com',
    );

    await _pumpScreen(
      tester,
      VehicleFormPage(
        viewModel: dependencies.createVehicleFormViewModel(customer),
      ),
    );

    expect(find.text('Cadastrar Veículo'), findsOneWidget);
    expect(find.text('Cliente: Maria Santos'), findsOneWidget);

    await tester.tap(find.text('Selecione ou digite a marca'));
    await _settle(tester);

    await tester.enterText(find.byType(TextField).last, 'Hon');
    await _settle(tester);

    await tester.tap(find.text('Honda').last);
    await _settle(tester);

    expect(find.text('Honda'), findsOneWidget);
    expect(find.text('Selecione ou digite o modelo'), findsOneWidget);
  });

  testWidgets(
    'fluxo completo: cliente sem veículo cadastra pela FIPE e volta selecionado',
    (tester) async {
      final orderFormViewModel = dependencies
          .createServiceOrderFormViewModel();

      await _pumpScreen(
        tester,
        Builder(
          builder: (context) => ServiceOrderFormPage(
            viewModel: orderFormViewModel,
            onRegisterVehicle: (customer) {
              return Navigator.of(context).push<Vehicle>(
                MaterialPageRoute<Vehicle>(
                  builder: (_) => VehicleFormPage(
                    viewModel: dependencies.createVehicleFormViewModel(
                      customer,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Selecione ou busque o cliente'));
      await _settle(tester);
      await tester.tap(find.text('Maria Santos').last);
      await _settle(tester);

      expect(find.text('Nenhum veículo'), findsOneWidget);

      await tester.tap(find.text('Cadastrar'));
      await _settle(tester);

      expect(find.text('Cadastrar Veículo'), findsOneWidget);

      await tester.tap(find.text('Selecione ou digite a marca'));
      await _settle(tester);
      // A lista de marcas é longa: filtrar por digitação é o caminho previsto.
      await tester.enterText(find.byType(TextField).last, 'Honda');
      await _settle(tester);
      await tester.tap(find.text('Honda').last);
      await _settle(tester);

      await tester.tap(find.text('Selecione ou digite o modelo'));
      await _settle(tester);
      await tester.tap(find.text('Civic 2.0 EXL 16V').last);
      await _settle(tester);

      await tester.tap(find.text('Selecione').first);
      await _settle(tester);
      await tester.tap(find.text('2020 Gasolina').last);
      await _settle(tester);

      // A cotação FIPE precisa chegar antes de o salvamento ser liberado.
      expect(find.text('Valor de referência FIPE'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'XYZ1A23');
      await _settle(tester);

      await tester.tap(find.text('Salvar Veículo'));
      await _settle(tester);

      // De volta à ordem de serviço, com o veículo novo já selecionado.
      expect(find.text('Nova Ordem de Serviço'), findsOneWidget);
      expect(find.textContaining('XYZ-1A23'), findsOneWidget);
    },
  );

  testWidgets('login leva ao dashboard novo, não à tela antiga', (
    tester,
  ) async {
    await _pumpApp(tester, OficinaApp(dependencies: dependencies));

    // A tela de entrada é o login do design, não a antiga.
    expect(find.text('Oficina na Nuvem'), findsOneWidget);
    expect(find.text('Cadastre-se'), findsOneWidget);

    await tester.enterText(
      find.byType(TextField).first,
      'ti@oficinanuvem.com.br',
    );
    await tester.enterText(find.byType(TextField).last, 'oficina123');
    await _settle(tester);

    await tester.tap(find.text('Entrar'));
    await _settle(tester);

    expect(find.text('Oficina do Zé'), findsOneWidget);
    expect(find.text('OS abertas'), findsOneWidget);
    expect(find.text('Login realizado com sucesso!'), findsNothing);
  });

  testWidgets('login de cliente leva à home do cliente, não ao dashboard', (
    tester,
  ) async {
    await _pumpApp(tester, OficinaApp(dependencies: dependencies));

    await tester.enterText(find.byType(TextField).first, 'cliente@email.com');
    await tester.enterText(find.byType(TextField).last, 'cliente123');
    await _settle(tester);

    await tester.tap(find.text('Entrar'));
    await _settle(tester);

    // Home do cliente (design 02): saudação e veículos da garagem.
    expect(find.text('Olá, João 👋'), findsOneWidget);
    expect(find.text('Meus Veículos'), findsOneWidget);
    expect(find.text('Ações Rápidas'), findsOneWidget);
    // Nada da área da oficina.
    expect(find.text('Oficina do Zé'), findsNothing);
    expect(find.text('OS abertas'), findsNothing);
  });

  testWidgets('cadastro de cliente passa pelos veículos e chega à home', (
    tester,
  ) async {
    await _pumpApp(tester, OficinaApp(dependencies: dependencies));

    await tester.tap(find.text('Cadastre-se'));
    await _settle(tester);

    expect(find.text('Criar Conta'), findsWidgets);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Gustavo Caous');
    // CPF válido: a validação de dígito verificador agora bloqueia o envio.
    await tester.enterText(fields.at(1), '529.982.247-25');
    await tester.enterText(fields.at(2), 'gustavo@email.com');
    await tester.enterText(fields.at(3), '(11) 98888-1111');

    // O ambiente de teste bloqueia HTTP: a busca do CEP falha após as
    // tentativas e o formulário libera o preenchimento manual do endereço.
    await tester.enterText(fields.at(4), '01310-100');
    await _settle(tester);

    expect(
      find.textContaining('Não foi possível buscar o CEP'),
      findsOneWidget,
    );

    await tester.enterText(fields.at(5), 'Avenida Paulista');
    await tester.enterText(fields.at(6), '1000');
    await tester.enterText(fields.at(8), 'Bela Vista');
    await tester.enterText(fields.at(9), 'São Paulo');
    await tester.enterText(fields.at(10), 'SP');
    await tester.enterText(fields.at(11), 'senha123');
    await _settle(tester);

    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await _settle(tester);

    await tester.ensureVisible(find.text('Criar Conta').last);

    await tester.tap(find.text('Criar Conta').last);
    await _settle(tester);

    // Passo 2: cadastro de veículos (design 19).
    expect(find.text('Passo 2 de 2'), findsOneWidget);
    expect(find.text('Cadastre os veículos que você possui'), findsOneWidget);
    expect(find.text('Jet Ski'), findsOneWidget);
    expect(find.text('Aeronave'), findsOneWidget);

    await tester.tap(find.text('Pular por enquanto'));
    await _settle(tester);

    // Destino final: home do cliente com o primeiro nome do cadastro.
    expect(find.text('Olá, Gustavo 👋'), findsOneWidget);
    expect(find.text('Meus Veículos'), findsOneWidget);
    expect(find.text('Oficina do Zé'), findsNothing);
  });

  testWidgets('onboarding aceita jet ski com preenchimento manual', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      VehicleOnboardingPage(
        viewModel: dependencies.createVehicleOnboardingViewModel(),
      ),
    );

    // Jet ski fica fora da FIPE: marca/modelo/ano viram campos de texto.
    await tester.tap(find.text('Jet Ski'));
    await _settle(tester);

    expect(find.text('Selecione ou digite a marca'), findsNothing);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Sea-Doo');
    await tester.enterText(fields.at(1), 'GTI 130');
    await tester.enterText(fields.at(2), '2023');
    await tester.enterText(fields.at(3), 'BRA1234');
    await _settle(tester);

    await tester.tap(find.text('Adicionar veículo'));
    await _settle(tester);

    expect(find.text('Veículos adicionados'), findsOneWidget);
    expect(find.text('Sea-Doo GTI 130'), findsOneWidget);
    expect(find.textContaining('Jet Ski •'), findsOneWidget);
  });

  testWidgets('cadastro alterna entre conta de cliente e de oficina', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      RegistrationFlowPage(
        viewModel: dependencies.accountRegistrationViewModel,
        addressControllerFactory: dependencies.createAddressFormController,
      ),
    );

    expect(find.text('Nome completo'), findsOneWidget);

    await tester.tap(find.text('Oficina'));
    await _settle(tester);

    expect(find.text('Nome da oficina'), findsOneWidget);
    expect(find.text('CNPJ'), findsOneWidget);
  });
}
