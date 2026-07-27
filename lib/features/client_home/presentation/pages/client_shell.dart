import 'package:flutter/material.dart';

import '../view_models/client_home_view_model.dart';
import '../view_models/client_vehicles_view_model.dart';
import '../widgets/client_bottom_nav.dart';
import 'client_home_page.dart';
import 'client_profile_page.dart';
import 'client_sos_page.dart';
import 'client_vehicles_page.dart';

/// Contêiner das áreas do cliente, com a navegação inferior do design.
///
/// Concentra as transições entre abas para que as páginas permaneçam
/// desacopladas de rotas e do grafo de dependências.
class ClientShell extends StatefulWidget {
  final ClientHomeViewModel homeViewModel;
  final ClientVehiclesViewModel vehiclesViewModel;

  /// Abre o cadastro de um novo veículo; retorna `true` se algo foi criado.
  final Future<bool?> Function() onAddVehicle;

  /// E-mail exibido na aba de perfil.
  final String email;

  /// Encerra a sessão do cliente.
  final VoidCallback onLogout;

  const ClientShell({
    super.key,
    required this.homeViewModel,
    required this.vehiclesViewModel,
    required this.onAddVehicle,
    required this.email,
    required this.onLogout,
  });

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  ClientTab _currentTab = ClientTab.home;

  void _selectTab(ClientTab tab) {
    if (tab == _currentTab) {
      return;
    }

    setState(() => _currentTab = tab);
  }

  void _goToVehicles() => _selectTab(ClientTab.vehicles);

  Widget _buildCurrentPage() {
    return switch (_currentTab) {
      ClientTab.home => ClientHomePage(
        viewModel: widget.homeViewModel,
        onSeeVehicles: _goToVehicles,
      ),
      ClientTab.vehicles => ClientVehiclesPage(
        viewModel: widget.vehiclesViewModel,
        onAddVehicle: widget.onAddVehicle,
      ),
      ClientTab.sos => const ClientSosPage(),
      ClientTab.profile => ClientProfilePage(
        userName: widget.homeViewModel.userName,
        email: widget.email,
        onLogout: widget.onLogout,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentPage(),
      bottomNavigationBar: ClientBottomNav(
        current: _currentTab,
        onTabSelected: _selectTab,
      ),
    );
  }
}
