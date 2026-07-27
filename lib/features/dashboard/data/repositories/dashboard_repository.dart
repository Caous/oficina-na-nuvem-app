import '../../models/dashboard_summary.dart';
import '../services/dashboard_service.dart';

/// Acesso ao resumo exibido na tela inicial da oficina.
class DashboardRepository {
  final DashboardService _service;

  DashboardRepository({required DashboardService service})
    : _service = service;

  Future<DashboardSummary> fetchSummary() => _service.fetchSummary();
}
