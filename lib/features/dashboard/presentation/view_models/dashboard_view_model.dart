import 'package:flutter/foundation.dart';

import '../../../../core/state/view_state.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../models/dashboard_summary.dart';

/// Estado da tela inicial da oficina.
class DashboardViewModel extends ChangeNotifier {
  final DashboardRepository _repository;

  DashboardViewModel({required DashboardRepository repository})
    : _repository = repository;

  ViewState<DashboardSummary> _state = const ViewStateLoading();

  ViewState<DashboardSummary> get state => _state;

  Future<void> load() async {
    _state = const ViewStateLoading();
    notifyListeners();

    try {
      _state = ViewStateSuccess(await _repository.fetchSummary());
    } catch (_) {
      _state = const ViewStateFailure(
        'Não foi possível carregar o resumo da oficina.',
      );
    } finally {
      notifyListeners();
    }
  }
}
