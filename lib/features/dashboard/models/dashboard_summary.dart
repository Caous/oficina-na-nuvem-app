import '../../service_orders/models/service_order.dart';

/// Indicador exibido nos cartões superiores do dashboard.
class DashboardMetric {
  final DashboardMetricKind kind;
  final String value;
  final String label;

  const DashboardMetric({
    required this.kind,
    required this.value,
    required this.label,
  });
}

/// Tipo do indicador; define ícone e cor na camada de UI.
enum DashboardMetricKind { openOrders, completedToday, revenue, averageTicket }

/// Um dia na série semanal de serviços realizados.
class WeeklyServicePoint {
  final String dayLabel;
  final int count;

  const WeeklyServicePoint({required this.dayLabel, required this.count});
}

/// Dados consolidados da tela inicial da oficina.
class DashboardSummary {
  final String workshopName;
  final List<DashboardMetric> metrics;
  final List<WeeklyServicePoint> weeklyServices;
  final List<ServiceOrder> recentOrders;

  const DashboardSummary({
    required this.workshopName,
    required this.metrics,
    required this.weeklyServices,
    required this.recentOrders,
  });

  /// Total de serviços na semana, exibido ao lado do gráfico.
  int get weeklyTotal =>
      weeklyServices.fold(0, (accumulated, day) => accumulated + day.count);

  /// Maior valor da série, usado para escalar as barras.
  int get weeklyPeak => weeklyServices.isEmpty
      ? 0
      : weeklyServices
            .map((day) => day.count)
            .reduce((a, b) => a > b ? a : b);
}
