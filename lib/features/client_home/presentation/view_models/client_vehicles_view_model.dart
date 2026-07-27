import 'package:flutter/foundation.dart';

import '../../../../core/state/view_state.dart';
import '../../../customers/models/vehicle.dart';
import '../../data/repositories/client_garage_repository.dart';

/// Estado da tela "Meus Veículos" do cliente.
class ClientVehiclesViewModel extends ChangeNotifier {
  final ClientGarageRepository _repository;

  ClientVehiclesViewModel({required ClientGarageRepository repository})
    : _repository = repository;

  ViewState<List<Vehicle>> _state = const ViewStateLoading();

  ViewState<List<Vehicle>> get state => _state;

  Future<void> load() async {
    _state = const ViewStateLoading();
    notifyListeners();

    try {
      _state = ViewStateSuccess(await _repository.fetchMyVehicles());
    } catch (_) {
      _state = const ViewStateFailure(
        'Não foi possível carregar seus veículos.',
      );
    } finally {
      notifyListeners();
    }
  }

  /// Remove o veículo [id] e recarrega a lista. Retorna `true` em sucesso.
  Future<bool> remove(String id) async {
    try {
      await _repository.removeVehicle(id);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }
}
