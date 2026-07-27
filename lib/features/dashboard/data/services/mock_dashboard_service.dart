import '../../../service_orders/data/repositories/service_order_repository.dart';
import '../../models/dashboard_summary.dart';
import 'dashboard_service.dart';

/// Resumo do dashboard montado a partir dos indicadores mockados e das ordens
/// reais do repositório, para que as duas telas nunca divirjam.
class MockDashboardService implements DashboardService {
  final ServiceOrderRepository _serviceOrderRepository;

  MockDashboardService({
    required ServiceOrderRepository serviceOrderRepository,
  }) : _serviceOrderRepository = serviceOrderRepository;

  @override
  Future<DashboardSummary> fetchSummary() async {
    final recentOrders = await _serviceOrderRepository.fetchRecent(limit: 2);

    return DashboardSummary(
      workshopName: 'Oficina do Zé',
      metrics: const [
        DashboardMetric(
          kind: DashboardMetricKind.openOrders,
          value: '12',
          label: 'OS abertas',
        ),
        DashboardMetric(
          kind: DashboardMetricKind.completedToday,
          value: '5',
          label: 'Concluídas hoje',
        ),
        DashboardMetric(
          kind: DashboardMetricKind.revenue,
          value: 'R\$ 24,5K',
          label: 'Faturamento mês',
        ),
        DashboardMetric(
          kind: DashboardMetricKind.averageTicket,
          value: 'R\$ 380',
          label: 'Ticket médio',
        ),
      ],
      weeklyServices: const [
        WeeklyServicePoint(dayLabel: 'S', count: 3),
        WeeklyServicePoint(dayLabel: 'T', count: 5),
        WeeklyServicePoint(dayLabel: 'Q', count: 4),
        WeeklyServicePoint(dayLabel: 'Q', count: 7),
        WeeklyServicePoint(dayLabel: 'S', count: 6),
        WeeklyServicePoint(dayLabel: 'S', count: 8),
        WeeklyServicePoint(dayLabel: 'D', count: 2),
      ],
      recentOrders: recentOrders,
    );
  }
}
