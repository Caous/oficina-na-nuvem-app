import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oficina_app/core/di/app_dependencies.dart';
import 'package:oficina_app/core/theme/app_colors.dart';
import 'package:oficina_app/core/theme/app_theme.dart';
import 'package:oficina_app/features/auth/presentation/pages/registration_flow_page.dart';
import 'package:oficina_app/features/employees/presentation/pages/employee_form_page.dart';

Future<void> _pumpScreen(WidgetTester tester, Widget child) async {
  tester.view.physicalSize = const Size(402 * 3, 1400 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(theme: AppTheme.build(), home: child));
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

/// Cor efetivamente aplicada ao texto da mensagem de erro.
Color? _colorOfText(WidgetTester tester, String text) {
  return tester.widget<Text>(find.text(text)).style?.color;
}

void main() {
  late AppDependencies dependencies;

  setUp(() {
    dependencies = AppDependencies.bootstrap();
  });

  group('máscaras', () {
    testWidgets('CPF é formatado enquanto o usuário digita', (tester) async {
      await _pumpScreen(
        tester,
        EmployeeFormPage(
          viewModel: dependencies.createEmployeeFormViewModel(null),
          addressController: dependencies.createAddressFormController(),
        ),
      );

      await tester.enterText(find.byType(TextField).at(1), '52998224725');
      await tester.pumpAndSettle();

      expect(find.text('529.982.247-25'), findsOneWidget);
    });

    testWidgets('telefone alterna entre formato fixo e celular', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        EmployeeFormPage(
          viewModel: dependencies.createEmployeeFormViewModel(null),
          addressController: dependencies.createAddressFormController(),
        ),
      );

      final phoneField = find.byType(TextField).at(2);

      await tester.enterText(phoneField, '1133334444');
      await tester.pumpAndSettle();
      expect(find.text('(11) 3333-4444'), findsOneWidget);

      await tester.enterText(phoneField, '11988881111');
      await tester.pumpAndSettle();
      expect(find.text('(11) 98888-1111'), findsOneWidget);
    });

    testWidgets('CNPJ aceita letras e fica em caixa alta', (tester) async {
      await _pumpScreen(
        tester,
        RegistrationFlowPage(
          viewModel: dependencies.accountRegistrationViewModel,
          addressControllerFactory: dependencies.createAddressFormController,
        ),
      );

      await tester.tap(find.text('Oficina'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(1), '12abc34d5e6f21');
      await tester.pumpAndSettle();

      expect(find.text('12.ABC.34D/5E6F-21'), findsOneWidget);
    });
  });

  group('mensagens de erro', () {
    testWidgets('CPF inválido pede conferência em vermelho', (tester) async {
      await _pumpScreen(
        tester,
        EmployeeFormPage(
          viewModel: dependencies.createEmployeeFormViewModel(null),
          addressController: dependencies.createAddressFormController(),
        ),
      );

      await tester.enterText(find.byType(TextField).at(1), '11111111111');
      await tester.pumpAndSettle();

      const message = 'Informe um CPF válido.';
      expect(find.text(message), findsOneWidget);
      expect(_colorOfText(tester, message), AppColors.accentRed);
    });

    testWidgets('e-mail inválido pede conferência em vermelho', (tester) async {
      await _pumpScreen(
        tester,
        EmployeeFormPage(
          viewModel: dependencies.createEmployeeFormViewModel(null),
          addressController: dependencies.createAddressFormController(),
        ),
      );

      await tester.enterText(find.byType(TextField).at(3), 'gustavo@email');
      await tester.pumpAndSettle();

      const message = 'E-mail inválido. Confira o endereço.';
      expect(find.text(message), findsOneWidget);
      expect(_colorOfText(tester, message), AppColors.accentRed);
    });

    testWidgets('telefone com DDD inexistente é recusado', (tester) async {
      await _pumpScreen(
        tester,
        EmployeeFormPage(
          viewModel: dependencies.createEmployeeFormViewModel(null),
          addressController: dependencies.createAddressFormController(),
        ),
      );

      await tester.enterText(find.byType(TextField).at(2), '10988887777');
      await tester.pumpAndSettle();

      expect(find.text('DDD inválido. Confira o número.'), findsOneWidget);
    });

    testWidgets('CNPJ inválido pede conferência', (tester) async {
      await _pumpScreen(
        tester,
        RegistrationFlowPage(
          viewModel: dependencies.accountRegistrationViewModel,
          addressControllerFactory: dependencies.createAddressFormController,
        ),
      );

      await tester.tap(find.text('Oficina'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).at(1), '11222333000199');
      await tester.pumpAndSettle();

      expect(find.text('CNPJ inválido. Confira os dados.'), findsOneWidget);
    });

    testWidgets('erro some quando o dado é corrigido', (tester) async {
      await _pumpScreen(
        tester,
        EmployeeFormPage(
          viewModel: dependencies.createEmployeeFormViewModel(null),
          addressController: dependencies.createAddressFormController(),
        ),
      );

      final cpfField = find.byType(TextField).at(1);

      await tester.enterText(cpfField, '11111111111');
      await tester.pumpAndSettle();
      expect(find.text('Informe um CPF válido.'), findsOneWidget);

      await tester.enterText(cpfField, '52998224725');
      await tester.pumpAndSettle();
      expect(find.text('Informe um CPF válido.'), findsNothing);
    });
  });

  testWidgets('formulário não salva com CPF inválido', (tester) async {
    await _pumpScreen(
      tester,
      EmployeeFormPage(
        viewModel: dependencies.createEmployeeFormViewModel(null),
        addressController: dependencies.createAddressFormController(),
      ),
    );

    await tester.enterText(find.byType(TextField).at(0), 'Gustavo Caous');
    await tester.enterText(find.byType(TextField).at(1), '11111111111');
    await tester.enterText(find.byType(TextField).at(2), '11988881111');
    await tester.enterText(find.byType(TextField).at(3), 'gustavo@email.com');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salvar Funcionário'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // Continua no formulário, com o erro visível.
    expect(find.text('Novo Funcionário'), findsOneWidget);
    expect(find.text('Informe um CPF válido.'), findsOneWidget);
  });
}
