import '../../../../core/network/api_client.dart';
import '../../../../core/utils/brl_formatter.dart';
import '../../../service_orders/data/services/api_service_order_service.dart';
import '../../models/dashboard_summary.dart';
import 'dashboard_service.dart';

/// Resumo da tela inicial da oficina, em `/dashboard/summary`.
///
/// O backend manda números crus; a formatação em Real e as letras dos dias
/// nascem aqui, porque são apresentação.
class ApiDashboardService implements DashboardService {
  /// Letra de cada dia da semana, indexada por `DateTime.weekday` (1 = seg).
  static const List<String> _weekdayLetters = [
    'S', 'T', 'Q', 'Q', 'S', 'S', 'D',
  ];

  final ApiClient _api;

  ApiDashboardService({required ApiClient api}) : _api = api;

  @override
  Future<DashboardSummary> fetchSummary() async {
    final json = await _api.get('/dashboard/summary') as Map<String, dynamic>;

    final metrics = json['metrics'] as Map<String, dynamic>;

    return DashboardSummary(
      workshopName: json['workshopName']?.toString() ?? '',
      metrics: [
        DashboardMetric(
          kind: DashboardMetricKind.openOrders,
          value: '${metrics['openOrders']}',
          label: 'OS abertas',
        ),
        DashboardMetric(
          kind: DashboardMetricKind.completedToday,
          value: '${metrics['completedToday']}',
          label: 'Concluídas hoje',
        ),
        DashboardMetric(
          kind: DashboardMetricKind.revenue,
          value: BrlFormatter.format(
            (metrics['monthlyRevenue'] as num).toDouble(),
          ),
          label: 'Faturamento mês',
        ),
        DashboardMetric(
          kind: DashboardMetricKind.averageTicket,
          value: BrlFormatter.format(
            (metrics['averageTicket'] as num).toDouble(),
          ),
          label: 'Ticket médio',
        ),
      ],
      weeklyServices: (json['weeklyServices'] as List<dynamic>)
          .map((item) => _dayFromApi(item as Map<String, dynamic>))
          .toList(growable: false),
      recentOrders: (json['recentOrders'] as List<dynamic>)
          .map(
            (item) => ApiServiceOrderService.orderFromApi(
              item as Map<String, dynamic>,
            ),
          )
          .toList(growable: false),
    );
  }

  WeeklyServicePoint _dayFromApi(Map<String, dynamic> json) {
    final date = DateTime.parse(json['date'] as String);

    return WeeklyServicePoint(
      dayLabel: _weekdayLetters[date.weekday - 1],
      count: (json['count'] as num).toInt(),
    );
  }
}
