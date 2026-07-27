import '../../models/dashboard_summary.dart';

/// Fonte dos dados consolidados da tela inicial da oficina.
abstract class DashboardService {
  Future<DashboardSummary> fetchSummary();
}
