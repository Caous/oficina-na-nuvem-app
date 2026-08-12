import '../../../../core/network/api_client.dart';
import '../../models/service_order.dart';
import 'service_order_service.dart';

/// Ordens de serviço em `/service-orders`.
class ApiServiceOrderService implements ServiceOrderService {
  static const Map<ServiceOrderStatus, String> _statusToApi = {
    ServiceOrderStatus.awaitingApproval: 'AWAITING_APPROVAL',
    ServiceOrderStatus.approved: 'APPROVED',
    ServiceOrderStatus.inProgress: 'IN_PROGRESS',
    ServiceOrderStatus.testing: 'TESTING',
    ServiceOrderStatus.completed: 'COMPLETED',
    ServiceOrderStatus.cancelled: 'CANCELLED',
  };

  final ApiClient _api;

  ApiServiceOrderService({required ApiClient api}) : _api = api;

  @override
  Future<List<ServiceOrder>> fetchAll() async {
    final json = await _api.get('/service-orders') as List<dynamic>;

    return json
        .map((item) => orderFromApi(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<ServiceOrder> updateStatus(String id, ServiceOrderStatus status) async {
    final json = await _api.patch(
      '/service-orders/$id/status',
      body: {'status': _statusToApi[status]},
    ) as Map<String, dynamic>;

    return orderFromApi(json);
  }

  @override
  Future<ServiceOrder> create(ServiceOrder order) async {
    final json = await _api.post('/service-orders', body: {
      'customerId': int.parse(order.customerId),
      'vehicleId': int.parse(order.vehicleId),
      'serviceIds': order.items
          .map((item) => int.parse(item.serviceId))
          .toList(growable: false),
      'assignedEmployeeId': order.assignedEmployeeId == null
          ? null
          : int.parse(order.assignedEmployeeId!),
    }) as Map<String, dynamic>;

    return orderFromApi(json);
  }

  static ServiceOrder orderFromApi(Map<String, dynamic> json) {
    final apiStatus = json['status']?.toString();

    final status = _statusToApi.entries
        .firstWhere(
          (entry) => entry.value == apiStatus,
          orElse: () =>
              const MapEntry(ServiceOrderStatus.awaitingApproval, ''),
        )
        .key;

    final items = (json['items'] as List<dynamic>? ?? const [])
        .map(
          (item) => ServiceOrderItem(
            serviceId: item['serviceId']?.toString() ?? '',
            serviceName: item['serviceName']?.toString() ?? '',
            price: (item['price'] as num?)?.toDouble() ?? 0,
          ),
        )
        .toList(growable: false);

    return ServiceOrder(
      id: json['id'].toString(),
      number: json['number']?.toString() ?? '',
      status: status,
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      vehicleId: json['vehicleId']?.toString() ?? '',
      vehicleDescription: json['vehicleDescription']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      items: items,
      openedAt: DateTime.tryParse(json['openedAt']?.toString() ?? '') ??
          DateTime.now(),
      assignedEmployeeId: json['assignedEmployeeId']?.toString(),
      assignedEmployeeName: json['assignedEmployeeName']?.toString(),
    );
  }
}
