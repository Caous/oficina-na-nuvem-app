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
import '../../../service_orders/models/service_order.dart';
import '../../../service_orders/presentation/widgets/service_order_status_visuals.dart';
import '../../models/dashboard_summary.dart';
import '../view_models/dashboard_view_model.dart';

/// Tela inicial da oficina com indicadores, gráfico semanal e ordens recentes
/// (tela 11 do design).
class DashboardPage extends StatefulWidget {
  final DashboardViewModel viewModel;
  final VoidCallback onSeeAllOrders;
  final ValueChanged<ServiceOrder> onOpenOrder;

  const DashboardPage({
    super.key,
    required this.viewModel,
    required this.onSeeAllOrders,
    required this.onOpenOrder,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
              ViewStateLoading<DashboardSummary>() => const Center(
                child: CircularProgressIndicator(),
              ),
              ViewStateFailure<DashboardSummary>(:final message) =>
                AppEmptyState(
                  icon: Icons.cloud_off_outlined,
                  title: 'Falha ao carregar',
                  message: message,
                  actionLabel: 'Tentar novamente',
                  onAction: widget.viewModel.load,
                ),
              ViewStateSuccess<DashboardSummary>(:final data) => _buildContent(
                data,
              ),
            };
          },
        ),
      ),
    );
  }

  Widget _buildContent(DashboardSummary summary) {
    return Column(
      children: [
        AppScreenHeader(
          title: summary.workshopName,
          subtitle: 'Resumo de hoje',
          showBackButton: false,
          actions: [
            AppHeaderAction(
              icon: Icons.notifications_none,
              tooltip: 'Notificações',
              onPressed: () {},
            ),
          ],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.viewModel.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenHorizontal,
                AppSpacing.lg,
                AppSpacing.screenHorizontal,
                AppSpacing.xxl,
              ),
              children: [
                _MetricGrid(metrics: summary.metrics),
                const SizedBox(height: AppSpacing.xl),
                _WeeklyChart(summary: summary),
                const SizedBox(height: AppSpacing.xl),
                _RecentOrdersSection(
                  orders: summary.recentOrders,
                  onSeeAll: widget.onSeeAllOrders,
                  onOpenOrder: widget.onOpenOrder,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Grade 2x2 de indicadores.
class _MetricGrid extends StatelessWidget {
  final List<DashboardMetric> metrics;

  const _MetricGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (var index = 0; index < metrics.length; index += 2) {
      final rowMetrics = metrics.skip(index).take(2).toList();

      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (position, metric) in rowMetrics.indexed) ...[
                if (position > 0) const SizedBox(width: AppSpacing.md),
                Expanded(child: _MetricCard(metric: metric)),
              ],
              if (rowMetrics.length == 1) ...[
                const SizedBox(width: AppSpacing.md),
                const Expanded(child: SizedBox.shrink()),
              ],
            ],
          ),
        ),
      );

      if (index + 2 < metrics.length) {
        rows.add(const SizedBox(height: AppSpacing.md));
      }
    }

    return Column(children: rows);
  }
}

class _MetricCard extends StatelessWidget {
  final DashboardMetric metric;

  const _MetricCard({required this.metric});

  ({IconData icon, Color foreground, Color background}) get _visuals {
    return switch (metric.kind) {
      DashboardMetricKind.openOrders => (
        icon: Icons.assignment_outlined,
        foreground: AppColors.accentBlue,
        background: AppColors.accentBlueLight,
      ),
      DashboardMetricKind.completedToday => (
        icon: Icons.check_circle_outline,
        foreground: AppColors.accentGreen,
        background: AppColors.accentGreenLight,
      ),
      DashboardMetricKind.revenue => (
        icon: Icons.account_balance_wallet_outlined,
        foreground: AppColors.accentPurple,
        background: AppColors.accentPurpleLight,
      ),
      DashboardMetricKind.averageTicket => (
        icon: Icons.show_chart,
        foreground: AppColors.accentAmber,
        background: AppColors.accentAmberLight,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final visuals = _visuals;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIconBadge(
            icon: visuals.icon,
            foreground: visuals.foreground,
            background: visuals.background,
            size: 36,
            radius: 18,
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(metric.value, style: AppTypography.metricValue),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            metric.label,
            style: AppTypography.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Gráfico de barras dos serviços realizados na semana.
class _WeeklyChart extends StatelessWidget {
  final DashboardSummary summary;

  static const double _chartHeight = 96;

  const _WeeklyChart({required this.summary});

  @override
  Widget build(BuildContext context) {
    final peak = summary.weeklyPeak;
    final busiestIndex = _busiestDayIndex();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Serviços na semana',
                  style: AppTypography.groupTitle,
                ),
              ),
              Text(
                '${summary.weeklyTotal} no total',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: _chartHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final (index, point) in summary.weeklyServices.indexed) ...[
                  if (index > 0) const SizedBox(width: AppSpacing.sm + 2),
                  Expanded(
                    child: _ChartBar(
                      point: point,
                      peak: peak,
                      isHighlighted: index == busiestIndex,
                      maxBarHeight: _chartHeight - 22,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _busiestDayIndex() {
    var busiest = 0;

    for (final (index, point) in summary.weeklyServices.indexed) {
      if (point.count > summary.weeklyServices[busiest].count) {
        busiest = index;
      }
    }

    return busiest;
  }
}

class _ChartBar extends StatelessWidget {
  final WeeklyServicePoint point;
  final int peak;
  final bool isHighlighted;
  final double maxBarHeight;

  const _ChartBar({
    required this.point,
    required this.peak,
    required this.isHighlighted,
    required this.maxBarHeight,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = peak == 0 ? 0.0 : point.count / peak;
    final barHeight = (maxBarHeight * ratio).clamp(6.0, maxBarHeight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: isHighlighted
                ? AppColors.accentBlue
                : AppColors.accentBlueLight,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        Text(
          point.dayLabel,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _RecentOrdersSection extends StatelessWidget {
  final List<ServiceOrder> orders;
  final VoidCallback onSeeAll;
  final ValueChanged<ServiceOrder> onOpenOrder;

  const _RecentOrdersSection({
    required this.orders,
    required this.onSeeAll,
    required this.onOpenOrder,
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
                'Ordens recentes',
                style: AppTypography.sectionTitle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            InkWell(
              onTap: onSeeAll,
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.xs),
                child: Text(
                  'Ver todas',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        for (final (index, order) in orders.indexed) ...[
          if (index > 0) const SizedBox(height: AppSpacing.md),
          AppCard(
            onTap: () => onOpenOrder(order),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.number,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${order.vehicleDescription} • ${order.summary}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AppBadge(
                  label: order.status.label,
                  foreground: ServiceOrderStatusVisuals.foregroundOf(
                    order.status,
                  ),
                  background: ServiceOrderStatusVisuals.backgroundOf(
                    order.status,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
