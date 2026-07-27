import 'package:flutter/material.dart';

import '../../../../core/state/view_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_icon_button.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../customers/models/vehicle.dart';
import '../view_models/client_vehicles_view_model.dart';
import '../widgets/vehicle_type_visuals.dart';

/// Tela "Meus Veículos": lista, exclusão e cadastro de veículos do cliente.
class ClientVehiclesPage extends StatefulWidget {
  final ClientVehiclesViewModel viewModel;

  /// Abre o cadastro de um novo veículo; retorna `true` se algo foi criado.
  final Future<bool?> Function() onAddVehicle;

  const ClientVehiclesPage({
    super.key,
    required this.viewModel,
    required this.onAddVehicle,
  });

  @override
  State<ClientVehiclesPage> createState() => _ClientVehiclesPageState();
}

class _ClientVehiclesPageState extends State<ClientVehiclesPage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  Future<void> _handleAddVehicle() async {
    final created = await widget.onAddVehicle();

    if (created == true) {
      await widget.viewModel.load();
    }
  }

  Future<void> _handleRemove(Vehicle vehicle) async {
    final confirmed = await ConfirmDialog.askDeletion(
      context,
      title: 'Excluir veículo',
      message:
          'Tem certeza que deseja excluir ${vehicle.brand} ${vehicle.model}?',
    );

    if (!confirmed) {
      return;
    }

    await widget.viewModel.remove(vehicle.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentBlue,
        onPressed: _handleAddVehicle,
        child: const Icon(Icons.add, color: AppColors.bgWhite),
      ),
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final vehicles = widget.viewModel.state.dataOrNull ?? const [];

            return Column(
              children: [
                AppScreenHeader(
                  title: 'Meus Veículos',
                  subtitle: '${vehicles.length} veículos cadastrados',
                  showBackButton: false,
                ),
                Expanded(child: _buildBody(vehicles)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(List<Vehicle> vehicles) {
    return switch (widget.viewModel.state) {
      ViewStateLoading<List<Vehicle>>() => const Center(
        child: CircularProgressIndicator(),
      ),
      ViewStateFailure<List<Vehicle>>(:final message) => AppEmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Falha ao carregar',
        message: message,
        actionLabel: 'Tentar novamente',
        onAction: widget.viewModel.load,
      ),
      ViewStateSuccess<List<Vehicle>>() when vehicles.isEmpty => AppEmptyState(
        icon: Icons.directions_car_outlined,
        title: 'Nenhum veículo',
        message: 'Cadastre seu primeiro veículo para começar.',
        actionLabel: 'Cadastrar veículo',
        onAction: _handleAddVehicle,
      ),
      ViewStateSuccess<List<Vehicle>>() => RefreshIndicator(
        onRefresh: widget.viewModel.load,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.lg,
            AppSpacing.screenHorizontal,
            100,
          ),
          itemCount: vehicles.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            return _VehicleCard(
              vehicle: vehicles[index],
              onDelete: () => _handleRemove(vehicles[index]),
            );
          },
        ),
      ),
    };
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onDelete;

  const _VehicleCard({required this.vehicle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          AppIconBadge(
            icon: vehicleTypeIcon(vehicle.type),
            foreground: AppColors.accentBlue,
            background: AppColors.accentBlueLight,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${vehicle.brand} ${vehicle.model}',
                  style: AppTypography.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${vehicle.plate} • ${vehicle.year}',
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppBadge(
                  label: vehicle.type.label,
                  foreground: AppColors.accentBlue,
                  background: AppColors.accentBlueLight,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppIconActionButton.delete(onPressed: onDelete),
        ],
      ),
    );
  }
}
