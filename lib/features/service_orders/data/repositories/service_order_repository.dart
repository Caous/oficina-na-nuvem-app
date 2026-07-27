import '../../models/service_order.dart';
import '../services/service_order_service.dart';

/// Ponto único de acesso a dados de ordens de serviço para a camada de
/// apresentação.
///
/// Depende apenas da interface [ServiceOrderService] (DIP), nunca de uma
/// implementação concreta.
class ServiceOrderRepository {
  final ServiceOrderService _service;

  ServiceOrderRepository({required ServiceOrderService service})
    : _service = service;

  Future<List<ServiceOrder>> fetchAll() => _service.fetchAll();

  Future<ServiceOrder> updateStatus(String id, ServiceOrderStatus status) {
    return _service.updateStatus(id, status);
  }

  Future<ServiceOrder> create(ServiceOrder order) => _service.create(order);

  /// Retorna as [limit] ordens mais recentes por data de abertura, para
  /// consumo do dashboard.
  Future<List<ServiceOrder>> fetchRecent({int limit = 2}) async {
    final orders = await _service.fetchAll();
    final sorted = List<ServiceOrder>.of(orders)
      ..sort((a, b) => b.openedAt.compareTo(a.openedAt));

    return sorted.take(limit).toList();
  }
}
