import 'package:flutter/foundation.dart';

import '../../../../core/state/view_state.dart';
import '../../../customers/models/vehicle.dart';
import '../../data/repositories/client_garage_repository.dart';

/// Estado da tela inicial do cliente.
class ClientHomeViewModel extends ChangeNotifier {
  final ClientGarageRepository _repository;
  final String userName;

  ClientHomeViewModel({
    required ClientGarageRepository repository,
    required this.userName,
  }) : _repository = repository;

  ViewState<List<Vehicle>> _state = const ViewStateLoading();

  ViewState<List<Vehicle>> get state => _state;

  /// Primeiro nome extraído de [userName], para a saudação do header.
  String get firstName => userName.trim().split(RegExp(r'\s+')).first;

  int get vehicleCount => _state.dataOrNull?.length ?? 0;

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
}
