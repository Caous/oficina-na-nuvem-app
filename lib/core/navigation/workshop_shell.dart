import 'package:flutter/material.dart';

import '../../features/customers/models/customer.dart';
import '../../features/customers/models/vehicle.dart';
import '../../features/customers/presentation/pages/vehicle_form_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/employees/presentation/pages/employees_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/inventory/presentation/pages/product_form_page.dart';
import '../../features/service_catalog/models/workshop_service.dart';
import '../../features/service_catalog/presentation/pages/service_categories_page.dart';
import '../../features/service_catalog/presentation/pages/service_form_page.dart';
import '../../features/service_catalog/presentation/pages/services_page.dart';
import '../../features/service_orders/models/service_order.dart';
import '../../shared/products/models/product.dart';
import '../../features/service_orders/presentation/pages/service_order_detail_page.dart';
import '../../features/service_orders/presentation/pages/service_order_form_page.dart';
import '../../features/service_orders/presentation/pages/service_orders_page.dart';
import '../di/app_dependencies.dart';
import '../widgets/shop_bottom_nav.dart';

/// Contêiner das áreas da oficina, com a navegação inferior do design.
///
/// Concentra as transições entre telas para que as páginas permaneçam
/// desacopladas de rotas e do grafo de dependências.
class WorkshopShell extends StatefulWidget {
  final AppDependencies dependencies;

  const WorkshopShell({super.key, required this.dependencies});

  @override
  State<WorkshopShell> createState() => _WorkshopShellState();
}

class _WorkshopShellState extends State<WorkshopShell> {
  ShopTab _currentTab = ShopTab.dashboard;

  AppDependencies get _dependencies => widget.dependencies;

  void _selectTab(ShopTab tab) {
    if (tab == _currentTab) {
      return;
    }

    setState(() => _currentTab = tab);
  }

  Future<void> _openOrderDetail(ServiceOrder order) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ServiceOrderDetailPage(
          order: order,
          onChangeStatus: (status) async {
            final changed = await _dependencies.serviceOrdersViewModel
                .changeStatus(order.id, status);

            if (changed) {
              await _dependencies.dashboardViewModel.load();
            }

            return changed;
          },
        ),
      ),
    );
  }

  Future<void> _openCategories() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ServiceCategoriesPage(
          viewModel: _dependencies.serviceCategoriesViewModel,
        ),
      ),
    );

    await _dependencies.servicesViewModel.load();
  }

  /// Abre a criação de ordem de serviço e atualiza o dashboard se ela nascer.
  Future<bool?> _openServiceOrderForm() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ServiceOrderFormPage(
          viewModel: _dependencies.createServiceOrderFormViewModel(),
          onRegisterVehicle: _openVehicleForm,
        ),
      ),
    );

    if (created == true) {
      await _dependencies.dashboardViewModel.load();
    }

    return created;
  }

  Future<bool?> _openProductForm(Product? product) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ProductFormPage(
          viewModel: _dependencies.createProductFormViewModel(product),
        ),
      ),
    );
  }

  Future<bool?> _openServiceForm(WorkshopService? service) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ServiceFormPage(
          viewModel: _dependencies.createServiceFormViewModel(service),
        ),
      ),
    );
  }

  Future<Vehicle?> _openVehicleForm(Customer customer) {
    return Navigator.of(context).push<Vehicle>(
      MaterialPageRoute<Vehicle>(
        builder: (_) => VehicleFormPage(
          viewModel: _dependencies.createVehicleFormViewModel(customer),
        ),
      ),
    );
  }

  Widget _buildCurrentPage() {
    return switch (_currentTab) {
      ShopTab.dashboard => DashboardPage(
        viewModel: _dependencies.dashboardViewModel,
        onSeeAllOrders: () => _selectTab(ShopTab.orders),
        onOpenOrder: _openOrderDetail,
      ),
      ShopTab.orders => ServiceOrdersPage(
        viewModel: _dependencies.serviceOrdersViewModel,
        onOpenOrderForm: _openServiceOrderForm,
      ),
      ShopTab.services => ServicesPage(
        viewModel: _dependencies.servicesViewModel,
        onOpenCategories: _openCategories,
        onOpenServiceForm: _openServiceForm,
      ),
      ShopTab.inventory => InventoryPage(
        viewModel: _dependencies.inventoryViewModel,
        onOpenProductForm: _openProductForm,
      ),
      ShopTab.team => EmployeesPage(
        viewModel: _dependencies.employeesViewModel,
        formViewModelBuilder: _dependencies.createEmployeeFormViewModel,
        addressControllerFactory: _dependencies.createAddressFormController,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentPage(),
      bottomNavigationBar: ShopBottomNav(
        current: _currentTab,
        onTabSelected: _selectTab,
      ),
    );
  }
}
