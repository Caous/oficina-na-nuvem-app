/// Situação de uma ordem de serviço.
///
/// Os quatro primeiros acompanham os filtros da tela de ordens no design;
/// [completed] e [cancelled] encerram a ordem e alimentam o dashboard.
enum ServiceOrderStatus {
  inProgress('Em andamento'),
  awaitingApproval('Aguardando aprovação'),
  testing('Testes'),
  approved('Aprovada'),
  completed('Concluída'),
  cancelled('Cancelada');

  final String label;

  const ServiceOrderStatus(this.label);
}

/// Item de serviço executado dentro de uma ordem.
class ServiceOrderItem {
  final String serviceName;
  final double price;

  /// Serviço do catálogo que originou o item; vazio em dados antigos.
  final String serviceId;

  const ServiceOrderItem({
    required this.serviceName,
    required this.price,
    this.serviceId = '',
  });
}

/// Ordem de serviço aberta para um cliente e veículo.
///
/// Os campos de exibição ([customerName], [vehicleDescription]) convivem com
/// os identificadores que a API precisa para abrir a ordem; quem monta uma
/// ordem nova preenche os dois grupos.
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

  final String customerId;
  final String vehicleId;
  final String? assignedEmployeeId;

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
    this.customerId = '',
    this.vehicleId = '',
    this.assignedEmployeeId,
  });

  /// Soma dos itens da ordem.
  double get total =>
      items.fold(0, (accumulated, item) => accumulated + item.price);
}
