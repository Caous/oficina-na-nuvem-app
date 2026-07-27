import 'package:flutter/material.dart';

import '../../../../core/state/view_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/brl_formatter.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_filter_chip.dart';
import '../../../../core/widgets/app_screen_header.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../models/service_order.dart';
import '../view_models/service_orders_view_model.dart';
import '../widgets/service_order_status_visuals.dart';
import 'service_order_detail_page.dart';

/// Tela 17 do design — listagem de ordens de serviço com filtros por status
/// e busca.
class ServiceOrdersPage extends StatefulWidget {
  final ServiceOrdersViewModel viewModel;

  /// Abre o formulário de nova ordem de serviço e retorna `true` quando uma
  /// ordem foi criada, para que a listagem seja recarregada.
  final Future<bool?> Function() onOpenOrderForm;

  const ServiceOrdersPage({
    super.key,
    required this.viewModel,
    required this.onOpenOrderForm,
  });

  @override
  State<ServiceOrdersPage> createState() => _ServiceOrdersPageState();
}

class _ServiceOrdersPageState extends State<ServiceOrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;

  static const _statusOrder = [
    ServiceOrderStatus.inProgress,
    ServiceOrderStatus.testing,
    ServiceOrderStatus.awaitingApproval,
    ServiceOrderStatus.approved,
  ];

  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _isSearchVisible = !_isSearchVisible);

    if (!_isSearchVisible) {
      _searchController.clear();
      widget.viewModel.search('');
    }
  }

  Future<void> _openOrderForm() async {
    final created = await widget.onOpenOrderForm();

    if (created == true) {
      widget.viewModel.load();
    }
  }

  Future<void> _openDetail(ServiceOrder order) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ServiceOrderDetailPage(
          order: order,
          onChangeStatus: (status) => widget.viewModel.changeStatus(order.id, status),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accentBlue,
        onPressed: _openOrderForm,
        child: const Icon(Icons.add, color: AppColors.bgWhite),
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final state = widget.viewModel.state;
            final total = widget.viewModel.totalCount;

            return Column(
              children: [
                AppScreenHeader(
                  title: 'Ordens de Serviço',
                  subtitle: '$total ordens ativas',
                  showBackButton: false,
                  actions: [
                    AppHeaderAction(
                      icon: Icons.search,
                      tooltip: 'Buscar',
                      onPressed: _toggleSearch,
                    ),
                  ],
                ),
                if (_isSearchVisible)
                  Container(
                    width: double.infinity,
                    color: AppColors.bgWhite,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screenHorizontal,
                      0,
                      AppSpacing.screenHorizontal,
                      AppSpacing.md,
                    ),
                    child: AppSearchField(
                      hint: 'Buscar por número, cliente ou veículo',
                      controller: _searchController,
                      onChanged: widget.viewModel.search,
                    ),
                  ),
                _buildFilterChips(),
                Expanded(child: _buildBody(state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: AppColors.bgWhite,
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
        child: Row(
          children: [
            AppFilterChip(
              label: 'Todas',
              isSelected: widget.viewModel.statusFilter == null,
              count: '${widget.viewModel.totalCount}',
              onSelected: () => widget.viewModel.filterByStatus(null),
            ),
            for (final status in _statusOrder) ...[
              const SizedBox(width: AppSpacing.sm),
              AppFilterChip(
                label: status.label,
                isSelected: widget.viewModel.statusFilter == status,
                count: '${widget.viewModel.countOf(status)}',
                onSelected: () => widget.viewModel.filterByStatus(status),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ViewState<List<ServiceOrder>> state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accentBlue));
    }

    if (state is ViewStateFailure<List<ServiceOrder>>) {
      return AppEmptyState(
        icon: Icons.error_outline,
        title: 'Algo deu errado',
        message: state.message,
        actionLabel: 'Tentar novamente',
        onAction: widget.viewModel.load,
      );
    }

    final orders = widget.viewModel.visibleOrders;

    if (orders.isEmpty) {
      final hasActiveFilter =
          widget.viewModel.statusFilter != null || widget.viewModel.searchQuery.isNotEmpty;

      return AppEmptyState(
        icon: Icons.assignment_outlined,
        title: hasActiveFilter ? 'Nenhuma ordem encontrada' : 'Nenhuma ordem de serviço',
        message: hasActiveFilter
            ? 'Ajuste os filtros ou o termo de busca para ver outras ordens.'
            : 'Quando uma ordem de serviço for aberta, ela aparecerá aqui.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _ServiceOrderCard(
        order: orders[index],
        onTap: () => _openDetail(orders[index]),
      ),
    );
  }
}

class _ServiceOrderCard extends StatelessWidget {
  final ServiceOrder order;
  final VoidCallback onTap;

  const _ServiceOrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.number,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              AppBadge(
                label: order.status.label,
                showDot: true,
                foreground: ServiceOrderStatusVisuals.foregroundOf(order.status),
                background: ServiceOrderStatusVisuals.backgroundOf(order.status),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppColors.textMuted),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  order.customerName,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  order.vehicleDescription,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            order.summary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  BrlFormatter.format(order.total),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(_formatOpenedAt(order.openedAt), style: AppTypography.caption),
              const SizedBox(width: AppSpacing.md),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Abrir',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentBlue,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: AppColors.accentBlue),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Formata a data de abertura como 'Hoje, 14:20', 'Ontem, 16:40' ou
/// '23/07, 09:15', sem depender de pacotes externos de internacionalização.
String _formatOpenedAt(DateTime openedAt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final openedDay = DateTime(openedAt.year, openedAt.month, openedAt.day);
  final difference = today.difference(openedDay).inDays;

  final time =
      '${openedAt.hour.toString().padLeft(2, '0')}:${openedAt.minute.toString().padLeft(2, '0')}';

  if (difference == 0) {
    return 'Hoje, $time';
  }

  if (difference == 1) {
    return 'Ontem, $time';
  }

  final day = openedAt.day.toString().padLeft(2, '0');
  final month = openedAt.month.toString().padLeft(2, '0');
  return '$day/$month, $time';
}
