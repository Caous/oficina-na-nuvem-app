import '../../models/service_order.dart';

/// Contrato de acesso a dados de ordens de serviço.
///
/// O repositório depende apenas desta interface (DIP), nunca de uma
/// implementação concreta — permite trocar o mock por uma API real sem
/// tocar nas camadas superiores.
abstract class ServiceOrderService {
  Future<List<ServiceOrder>> fetchAll();

  Future<ServiceOrder> updateStatus(String id, ServiceOrderStatus status);

  Future<ServiceOrder> create(ServiceOrder order);
}
