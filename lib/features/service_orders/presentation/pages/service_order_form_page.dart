import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/brl_formatter.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_icon_button.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/app_select_field.dart';
import '../../../customers/models/customer.dart';
import '../../../customers/models/vehicle.dart';
import '../../../employees/models/employee.dart';
import '../../../service_catalog/models/workshop_service.dart';
import '../view_models/service_order_form_view_model.dart';

/// Tela de abertura de uma nova ordem de serviço: cliente e veículo,
/// serviços do catálogo e mecânico responsável.
class ServiceOrderFormPage extends StatefulWidget {
  final ServiceOrderFormViewModel viewModel;

  /// Abre o cadastro de veículo pela FIPE para o cliente informado.
  final Future<Vehicle?> Function(Customer customer) onRegisterVehicle;

  const ServiceOrderFormPage({
    super.key,
    required this.viewModel,
    required this.onRegisterVehicle,
  });

  @override
  State<ServiceOrderFormPage> createState() => _ServiceOrderFormPageState();
}

class _ServiceOrderFormPageState extends State<ServiceOrderFormPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  Future<void> _registerVehicle(Customer customer) async {
    final vehicle = await widget.onRegisterVehicle(customer);

    if (vehicle != null) {
      widget.viewModel.attachCreatedVehicle(vehicle);
    }
  }

  Future<void> _submit() async {
    final order = await widget.viewModel.submit();

    if (!mounted) {
      return;
    }

    if (order != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ordem ${order.number} aberta.')),
      );
      Navigator.of(context).pop(true);
      return;
    }

    final message = widget.viewModel.errorMessage;
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      body: SafeArea(
        child: Column(
          children: [
            const AppScreenHeader(title: 'Nova Ordem de Serviço'),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, _) {
                  if (widget.viewModel.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.accentBlue),
                    );
                  }

                  return _buildForm(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final viewModel = widget.viewModel;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenHorizontal,
        vertical: AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cliente e veículo', style: AppTypography.groupTitle),
          const SizedBox(height: AppSpacing.md),
          AppSelectField<Customer>(
            label: 'Cliente',
            placeholder: 'Selecione ou busque o cliente',
            icon: Icons.person_outline,
            selectedLabel: viewModel.selectedCustomer?.name,
            options: [
              for (final customer in viewModel.customers)
                SelectOption(
                  value: customer,
                  label: customer.name,
                  description: customer.phone,
                ),
            ],
            onSelected: (customer) => viewModel.selectCustomer(customer),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildVehicleField(viewModel),
          const SizedBox(height: AppSpacing.xxl),
          const Text('Serviços', style: AppTypography.groupTitle),
          const SizedBox(height: AppSpacing.md),
          AppSelectField<WorkshopService>(
            label: 'Adicionar serviço',
            placeholder: 'Buscar no catálogo',
            icon: Icons.build_outlined,
            options: [
              for (final service in viewModel.availableServices)
                if (!viewModel.selectedServices.any((s) => s.id == service.id))
                  SelectOption(
                    value: service,
                    label: service.name,
                    description: BrlFormatter.format(service.price),
                  ),
            ],
            onSelected: (service) => viewModel.addService(service),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildSelectedServices(viewModel),
          const SizedBox(height: AppSpacing.lg),
          _buildTotalCard(viewModel),
          const SizedBox(height: AppSpacing.xxl),
          const Text('Responsável (opcional)', style: AppTypography.groupTitle),
          const SizedBox(height: AppSpacing.md),
          AppSelectField<Employee>(
            label: 'Mecânico responsável',
            placeholder: 'Selecione o responsável',
            icon: Icons.engineering_outlined,
            selectedLabel: viewModel.selectedEmployee?.name,
            options: [
              for (final employee in viewModel.employees)
                SelectOption(
                  value: employee,
                  label: employee.name,
                  description: employee.role.label,
                ),
            ],
            onSelected: (employee) => viewModel.selectEmployee(employee),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppPrimaryButton(
            label: 'Abrir Ordem de Serviço',
            icon: Icons.check,
            isLoading: viewModel.isSaving,
            onPressed: viewModel.canSubmit ? _submit : null,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildVehicleField(ServiceOrderFormViewModel viewModel) {
    final customer = viewModel.selectedCustomer;

    if (customer == null) {
      return _buildVehicleInfoCard(
        icon: Icons.info_outline,
        text: 'Selecione o cliente para ver os veículos.',
      );
    }

    if (viewModel.isLoadingVehicles) {
      return const AppCard(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: CircularProgressIndicator(
              color: AppColors.accentBlue,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (viewModel.needsVehicle) {
      return AppCard(
        backgroundColor: AppColors.accentBlueLight,
        borderColor: AppColors.accentBlue,
        child: Row(
          children: [
            const AppIconBadge(
              icon: Icons.directions_car_outlined,
              foreground: AppColors.accentBlue,
              background: AppColors.bgWhite,
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Nenhum veículo', style: AppTypography.cardTitle),
                  SizedBox(height: 2),
                  Text('Cadastre via Tabela FIPE', style: AppTypography.bodySmall),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            FilledButton.icon(
              onPressed: () => _registerVehicle(customer),
              style: FilledButton.styleFrom(backgroundColor: AppColors.accentBlue),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Cadastrar'),
            ),
          ],
        ),
      );
    }

    return AppSelectField<Vehicle>(
      label: 'Veículo',
      placeholder: 'Selecione o veículo',
      icon: Icons.directions_car_outlined,
      selectedLabel: viewModel.selectedVehicle?.shortDescription,
      options: [
        for (final vehicle in viewModel.customerVehicles)
          SelectOption(
            value: vehicle,
            label: vehicle.shortDescription,
            description: vehicle.year,
          ),
      ],
      onSelected: (vehicle) => viewModel.selectVehicle(vehicle),
    );
  }

  Widget _buildVehicleInfoCard({required IconData icon, required String text}) {
    return AppCard(
      backgroundColor: AppColors.bgCard,
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedServices(ServiceOrderFormViewModel viewModel) {
    final services = viewModel.selectedServices;

    if (services.isEmpty) {
      return const Text(
        'Nenhum serviço adicionado ainda.',
        style: AppTypography.bodySmall,
      );
    }

    return Column(
      children: [
        for (final service in services) ...[
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    service.name,
                    style: AppTypography.cardTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(BrlFormatter.format(service.price), style: AppTypography.price),
                const SizedBox(width: AppSpacing.sm),
                AppIconActionButton.delete(
                  onPressed: () => viewModel.removeService(service.id),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }

  Widget _buildTotalCard(ServiceOrderFormViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text('Total da ordem', style: AppTypography.bodySmall),
          ),
          Text(
            BrlFormatter.format(viewModel.total),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.accentBlueDark,
            ),
          ),
        ],
      ),
    );
  }
}
