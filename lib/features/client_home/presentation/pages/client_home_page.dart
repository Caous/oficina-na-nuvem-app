import 'package:flutter/material.dart';

import '../../../../core/state/view_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_icon_button.dart';
import '../../../customers/models/vehicle.dart';
import '../view_models/client_home_view_model.dart';
import '../widgets/vehicle_type_visuals.dart';

/// Tela inicial da área do cliente (tela "02 - Home" do design).
class ClientHomePage extends StatefulWidget {
  final ClientHomeViewModel viewModel;
  final VoidCallback onSeeVehicles;

  const ClientHomePage({
    super.key,
    required this.viewModel,
    required this.onSeeVehicles,
  });

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            return switch (widget.viewModel.state) {
              ViewStateLoading<List<Vehicle>>() => const Center(
                child: CircularProgressIndicator(),
              ),
              ViewStateFailure<List<Vehicle>>(:final message) =>
                AppEmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: 'Falha ao carregar',
                  message: message,
                  actionLabel: 'Tentar novamente',
                  onAction: widget.viewModel.load,
                ),
              ViewStateSuccess<List<Vehicle>>(:final data) => _buildContent(
                data,
              ),
            };
          },
        ),
      ),
    );
  }

  Widget _buildContent(List<Vehicle> vehicles) {
    return Column(
      children: [
        _Header(name: widget.viewModel.firstName),
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.viewModel.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xl,
                AppSpacing.xxl,
                100,
              ),
              children: [
                _MyVehiclesSection(
                  vehicles: vehicles,
                  onTapVehicle: widget.onSeeVehicles,
                ),
                const SizedBox(height: AppSpacing.xxl),
                _QuickActionsSection(),
                const SizedBox(height: AppSpacing.xxl),
                const _VehicleStatusSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final String name;

  const _Header({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgWhite,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.md,
        AppSpacing.xxl,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Olá, $name 👋',
                  style: AppTypography.screenTitle.copyWith(fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Bem-vindo de volta',
                  style: AppTypography.body,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const AppIconBadge(
            icon: Icons.person_outline,
            foreground: AppColors.accentBlue,
            background: AppColors.accentBlueLight,
            size: 44,
            radius: 22,
          ),
        ],
      ),
    );
  }
}

class _MyVehiclesSection extends StatelessWidget {
  final List<Vehicle> vehicles;
  final VoidCallback onTapVehicle;

  const _MyVehiclesSection({
    required this.vehicles,
    required this.onTapVehicle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'Meus Veículos',
                style: AppTypography.sectionTitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${vehicles.length} veículos',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (vehicles.isEmpty)
          AppEmptyState(
            icon: Icons.directions_car_outlined,
            title: 'Nenhum veículo',
            message: 'Cadastre seu primeiro veículo para começar.',
            actionLabel: 'Ver veículos',
            onAction: onTapVehicle,
          )
        else ...[
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: vehicles.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, index) {
                return _VehicleCard(
                  vehicle: vehicles[index],
                  onTap: onTapVehicle,
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: onTapVehicle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final (index, _) in vehicles.indexed) ...[
                  if (index > 0) const SizedBox(width: AppSpacing.xs),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == 0
                          ? AppColors.accentBlue
                          : AppColors.gray300,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;

  const _VehicleCard({required this.vehicle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppIconBadge(
              icon: vehicleTypeIcon(vehicle.type),
              foreground: AppColors.accentBlue,
              background: AppColors.accentBlueLight,
              size: 42,
            ),
            const SizedBox(width: AppSpacing.sm + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${vehicle.brand} ${vehicle.model}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    vehicle.plate,
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
          ],
        ),
      ),
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ações Rápidas', style: AppTypography.sectionTitle),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.event_outlined,
                foreground: AppColors.accentBlue,
                background: AppColors.accentBlueLight,
                label: 'Agendar',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.request_quote_outlined,
                foreground: AppColors.accentGreen,
                background: AppColors.accentGreenLight,
                label: 'Orçamentos',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.history,
                foreground: AppColors.accentPurple,
                background: AppColors.accentPurpleLight,
                label: 'Histórico',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final Color foreground;
  final Color background;
  final String label;

  const _QuickActionCard({
    required this.icon,
    required this.foreground,
    required this.background,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Em breve.')),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIconBadge(icon: icon, foreground: foreground, background: background),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleStatusSection extends StatelessWidget {
  const _VehicleStatusSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Status do Veículo', style: AppTypography.sectionTitle),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              const AppIconBadge(
                icon: Icons.check_circle_outline,
                foreground: AppColors.accentGreen,
                background: AppColors.accentGreenLight,
                size: 44,
                radius: 22,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Tudo em dia',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Nenhum serviço pendente para seus veículos',
                      style: AppTypography.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
