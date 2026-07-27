import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/brl_formatter.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_filter_chip.dart';
import '../../../../core/widgets/app_icon_button.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../models/service_order.dart';
import '../widgets/service_order_status_visuals.dart';

/// Detalhe de uma ordem de serviço: status atual (com troca), cliente,
/// veículo, itens e ações de aprovação/cancelamento.
class ServiceOrderDetailPage extends StatefulWidget {
  final ServiceOrder order;
  final Future<bool> Function(ServiceOrderStatus status) onChangeStatus;

  const ServiceOrderDetailPage({
    super.key,
    required this.order,
    required this.onChangeStatus,
  });

  @override
  State<ServiceOrderDetailPage> createState() => _ServiceOrderDetailPageState();
}

class _ServiceOrderDetailPageState extends State<ServiceOrderDetailPage> {
  late ServiceOrder _order;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _changeStatus(ServiceOrderStatus status) async {
    if (status == _order.status || _isUpdating) {
      return;
    }

    setState(() => _isUpdating = true);

    final success = await widget.onChangeStatus(status);

    if (!mounted) {
      return;
    }

    setState(() {
      _isUpdating = false;
      if (success) {
        _order = ServiceOrder(
          id: _order.id,
          number: _order.number,
          status: status,
          customerName: _order.customerName,
          vehicleDescription: _order.vehicleDescription,
          summary: _order.summary,
          items: _order.items,
          openedAt: _order.openedAt,
          assignedEmployeeName: _order.assignedEmployeeName,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Status atualizado para "${status.label}".'
              : 'Não foi possível atualizar o status. Tente novamente.',
        ),
      ),
    );
  }

  void _cancelOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cancelamento de ordem ainda não disponível.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            AppScreenHeader(
              title: _order.number,
              subtitle: 'Aberta em ${_formatFullDate(_order.openedAt)}',
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenHorizontal,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildCustomerCard(),
                    const SizedBox(height: AppSpacing.lg),
                    _buildItemsCard(),
                    if (_order.assignedEmployeeName != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _buildEmployeeCard(_order.assignedEmployeeName!),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    AppPrimaryButton(
                      label: 'Aprovar ordem',
                      icon: Icons.check,
                      isLoading: _isUpdating,
                      onPressed: _order.status == ServiceOrderStatus.approved
                          ? null
                          : () => _changeStatus(ServiceOrderStatus.approved),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppDestructiveButton(
                      label: 'Cancelar ordem',
                      icon: Icons.close,
                      onPressed: _cancelOrder,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Status atual', style: AppTypography.groupTitle),
          const SizedBox(height: AppSpacing.md),
          AppBadge(
            label: _order.status.label,
            showDot: true,
            foreground: ServiceOrderStatusVisuals.foregroundOf(_order.status),
            background: ServiceOrderStatusVisuals.backgroundOf(_order.status),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Alterar status', style: AppTypography.fieldLabel),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final status in ServiceOrderStatus.values)
                AppFilterChip(
                  label: status.label,
                  isSelected: status == _order.status,
                  onSelected: () => _changeStatus(status),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIconBadge(
                icon: Icons.person_outline,
                foreground: AppColors.accentBlue,
                background: AppColors.accentBlueLight,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  _order.customerName,
                  style: AppTypography.cardTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.directions_car_outlined,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  _order.vehicleDescription,
                  style: AppTypography.body,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsCard() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Itens da ordem', style: AppTypography.groupTitle),
          const SizedBox(height: AppSpacing.md),
          for (final item in _order.items) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.serviceName,
                      style: AppTypography.body,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(BrlFormatter.format(item.price), style: AppTypography.fieldValue),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text('Total', style: AppTypography.groupTitle),
              const Spacer(),
              Text(BrlFormatter.format(_order.total), style: AppTypography.price),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(String employeeName) {
    return AppCard(
      child: Row(
        children: [
          const AppIconBadge(
            icon: Icons.engineering_outlined,
            foreground: AppColors.accentPurple,
            background: AppColors.accentPurpleLight,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Responsável', style: AppTypography.fieldLabel),
                const SizedBox(height: 2),
                Text(
                  employeeName,
                  style: AppTypography.cardTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatFullDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day/$month/${date.year} às $hour:$minute';
}
