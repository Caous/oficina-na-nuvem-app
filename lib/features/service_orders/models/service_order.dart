/// Situação de uma ordem de serviço.
///
/// Os rótulos acompanham os filtros da tela de ordens no design.
enum ServiceOrderStatus {
  inProgress('Em andamento'),
  awaitingApproval('Aguardando aprovação'),
  testing('Testes'),
  approved('Aprovada');

  final String label;

  const ServiceOrderStatus(this.label);
}

/// Item de serviço executado dentro de uma ordem.
class ServiceOrderItem {
  final String serviceName;
  final double price;

  const ServiceOrderItem({required this.serviceName, required this.price});
}

/// Ordem de serviço aberta para um cliente e veículo.
class ServiceOrder {
  final String id;
  final String number;
  final ServiceOrderStatus status;
  final String customerName;
  final String vehicleDescription;
  final String summary;
  final List<ServiceOrderItem> items;
  final DateTime openedAt;
  final String? assignedEmployeeName;

  const ServiceOrder({
    required this.id,
    required this.number,
    required this.status,
    required this.customerName,
    required this.vehicleDescription,
    required this.summary,
    required this.items,
    required this.openedAt,
    this.assignedEmployeeName,
  });

  /// Soma dos itens da ordem.
  double get total =>
      items.fold(0, (accumulated, item) => accumulated + item.price);
}
