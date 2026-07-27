import 'package:flutter/material.dart';

import 'core/di/app_dependencies.dart';
import 'core/navigation/workshop_shell.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/models/user.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/registration_flow_page.dart';
import 'features/client_home/presentation/pages/client_shell.dart';
import 'features/customers/presentation/pages/vehicle_onboarding_page.dart';

void main() {
  runApp(OficinaApp(dependencies: AppDependencies.bootstrap()));
}

class OficinaApp extends StatelessWidget {
  final AppDependencies dependencies;

  const OficinaApp({super.key, required this.dependencies});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oficina na Nuvem',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: AppEntryPoint(dependencies: dependencies),
    );
  }
}

/// Raiz da navegação: login, cadastro e as duas áreas logadas.
///
/// O papel da conta decide o destino: cliente vai para a home do cliente
/// (design 02) e oficina para o dashboard (design 11). Cliente recém
/// cadastrado passa antes pelo cadastro de veículos (design 19).
class AppEntryPoint extends StatelessWidget {
  final AppDependencies dependencies;

  const AppEntryPoint({super.key, required this.dependencies});

  /// Substitui toda a pilha pela área do papel informado, impedindo o retorno
  /// às telas de autenticação pelo botão voltar.
  void _enterArea(BuildContext context, User user) {
    final Widget area = switch (user.role) {
      UserRole.workshop => WorkshopShell(dependencies: dependencies),
      UserRole.client => _buildClientShell(user),
    };

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => area),
      (route) => false,
    );
  }

  Widget _buildClientShell(User user) {
    return Builder(
      builder: (shellContext) => ClientShell(
        homeViewModel: dependencies.createClientHomeViewModel(
          userName: user.name,
        ),
        vehiclesViewModel: dependencies.createClientVehiclesViewModel(),
        onAddVehicle: () => _openVehicleOnboarding(shellContext),
        email: user.email,
        onLogout: () => _logout(shellContext),
      ),
    );
  }

  Future<bool?> _openVehicleOnboarding(BuildContext context) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => VehicleOnboardingPage(
          viewModel: dependencies.createVehicleOnboardingViewModel(),
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => AppEntryPoint(dependencies: dependencies),
      ),
      (route) => false,
    );
  }

  void _onLoginSuccess(BuildContext context) {
    final user = dependencies.loginViewModel.userLogin;

    if (user == null) {
      return;
    }

    _enterArea(context, user);
  }

  /// Cadastro concluído: oficina entra direto; cliente cadastra os veículos
  /// primeiro (fluxo "cadastro → veículos → home do cliente").
  Future<void> _openRegistration(BuildContext context) async {
    final registered = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => RegistrationFlowPage(
          viewModel: dependencies.accountRegistrationViewModel,
          addressControllerFactory: dependencies.createAddressFormController,
        ),
      ),
    );

    final user = dependencies.accountRegistrationViewModel.registeredUser;

    if (registered != true || user == null || !context.mounted) {
      return;
    }

    if (user.role == UserRole.client) {
      await _openVehicleOnboarding(context);
    }

    if (context.mounted) {
      _enterArea(context, user);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoginPage(
      viewModel: dependencies.loginViewModel,
      onLoginSuccess: () => _onLoginSuccess(context),
      onCreateAccount: () => _openRegistration(context),
    );
  }
}
