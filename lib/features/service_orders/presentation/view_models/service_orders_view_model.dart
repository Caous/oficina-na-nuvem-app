import 'package:flutter/foundation.dart';

import '../../../../core/state/view_state.dart';
import '../../data/repositories/service_order_repository.dart';
import '../../models/service_order.dart';

/// Estado e regras de apresentação da lista de ordens de serviço.
///
/// Mantém o filtro de status e o texto de busca aplicados sobre os dados
/// carregados, expondo apenas getters — a página não decide regra de
/// negócio, só reage ao estado.
class ServiceOrdersViewModel extends ChangeNotifier {
  final ServiceOrderRepository _repository;

  ViewState<List<ServiceOrder>> _state = const ViewStateLoading();
  ServiceOrderStatus? _statusFilter;
  String _searchQuery = '';

  ServiceOrdersViewModel({required ServiceOrderRepository repository})
    : _repository = repository;

  ViewState<List<ServiceOrder>> get state => _state;

  ServiceOrderStatus? get statusFilter => _statusFilter;

  String get searchQuery => _searchQuery;

  List<ServiceOrder> get _allOrders => _state.dataOrNull ?? const [];

  int get totalCount => _allOrders.length;

  List<ServiceOrder> get visibleOrders {
    final query = _searchQuery.trim().toLowerCase();

    return _allOrders.where((order) {
      final matchesStatus = _statusFilter == null || order.status == _statusFilter;

      if (!matchesStatus) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      return order.number.toLowerCase().contains(query) ||
          order.customerName.toLowerCase().contains(query) ||
          order.vehicleDescription.toLowerCase().contains(query);
    }).toList();
  }

  int countOf(ServiceOrderStatus status) {
    return _allOrders.where((order) => order.status == status).length;
  }

  Future<void> load() async {
    _state = const ViewStateLoading();
    notifyListeners();

    try {
      final orders = await _repository.fetchAll();
      _state = ViewStateSuccess(orders);
    } catch (error) {
      _state = ViewStateFailure(
        'Não foi possível carregar as ordens de serviço. Tente novamente.',
      );
    }

    notifyListeners();
  }

  void filterByStatus(ServiceOrderStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> changeStatus(String id, ServiceOrderStatus status) async {
    try {
      final updated = await _repository.updateStatus(id, status);
      final orders = _allOrders
          .map((order) => order.id == updated.id ? updated : order)
          .toList();

      _state = ViewStateSuccess(orders);
      notifyListeners();
      return true;
    } catch (error) {
      return false;
    }
  }
}
