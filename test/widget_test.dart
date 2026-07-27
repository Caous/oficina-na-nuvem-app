import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:oficina_app/features/auth/data/repositories/auth_repository.dart';
import 'package:oficina_app/features/auth/data/services/mock_auth_service.dart';
import 'package:oficina_app/features/auth/presentation/pages/login_page.dart';
import 'package:oficina_app/features/auth/presentation/view_models/login_view_model.dart';

LoginViewModel _buildViewModel() {
  return LoginViewModel(
    authRepository: AuthRepository(authService: MockAuthService()),
  );
}

void main() {
  testWidgets('Deve exibir a tela de login', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          viewModel: _buildViewModel(),
          onLoginSuccess: () {},
          onCreateAccount: () {},
        ),
      ),
    );

    expect(find.text('Oficina na Nuvem'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
  });

  testWidgets('Deve navegar ao tocar em Cadastre-se', (
    WidgetTester tester,
  ) async {
    var openedRegistration = false;

    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          viewModel: _buildViewModel(),
          onLoginSuccess: () {},
          onCreateAccount: () => openedRegistration = true,
        ),
      ),
    );

    await tester.ensureVisible(find.text('Cadastre-se'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cadastre-se'));
    await tester.pump();

    expect(openedRegistration, isTrue);
  });

  testWidgets('Deve avisar quando as credenciais são inválidas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginPage(
          viewModel: _buildViewModel(),
          onLoginSuccess: () {},
          onCreateAccount: () {},
        ),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'errado@email.com');
    await tester.enterText(find.byType(TextField).last, 'senhaerrada');

    await tester.tap(find.text('Entrar'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('E-mail ou senha inválidos.'), findsOneWidget);
  });
}
