import '../../models/service_order.dart';
import 'service_order_service.dart';

/// Implementação em memória de [ServiceOrderService], usada enquanto a API
/// real não está disponível.
class MockServiceOrderService implements ServiceOrderService {
  static const _fetchDelay = Duration(milliseconds: 400);

  final List<ServiceOrder> _orders;

  /// Próximo número de sequência a ser atribuído, continuando a partir do
  /// maior número do seed (`#OS-1042`).
  int _nextSequence = 1043;

  MockServiceOrderService() : _orders = _seed();

  @override
  Future<List<ServiceOrder>> fetchAll() async {
    await Future.delayed(_fetchDelay);
    return List.unmodifiable(_orders);
  }

  @override
  Future<ServiceOrder> updateStatus(String id, ServiceOrderStatus status) async {
    await Future.delayed(_fetchDelay);

    final index = _orders.indexWhere((order) => order.id == id);

    if (index == -1) {
      throw StateError('Ordem de serviço "$id" não encontrada.');
    }

    final current = _orders[index];
    final updated = ServiceOrder(
      id: current.id,
      number: current.number,
      status: status,
      customerName: current.customerName,
      vehicleDescription: current.vehicleDescription,
      summary: current.summary,
      items: current.items,
      openedAt: current.openedAt,
      assignedEmployeeName: current.assignedEmployeeName,
    );

    _orders[index] = updated;
    return updated;
  }

  @override
  Future<ServiceOrder> create(ServiceOrder order) async {
    await Future.delayed(_fetchDelay);

    final sequence = _nextSequence++;
    final created = ServiceOrder(
      id: 'os-$sequence',
      number: '#OS-$sequence',
      status: order.status,
      customerName: order.customerName,
      vehicleDescription: order.vehicleDescription,
      summary: order.summary,
      items: order.items,
      openedAt: order.openedAt,
      assignedEmployeeName: order.assignedEmployeeName,
    );

    _orders.insert(0, created);
    return created;
  }

  static List<ServiceOrder> _seed() {
    final now = DateTime.now();

    DateTime daysAgoAt(int daysAgo, int hour, int minute) {
      final day = now.subtract(Duration(days: daysAgo));
      return DateTime(day.year, day.month, day.day, hour, minute);
    }

    return [
      ServiceOrder(
        id: 'os-1042',
        number: '#OS-1042',
        status: ServiceOrderStatus.inProgress,
        customerName: 'João Pereira',
        vehicleDescription: 'Honda Civic 2020 • ABC-1D23',
        summary: 'Troca de óleo + revisão de freios',
        items: const [
          ServiceOrderItem(serviceName: 'Troca de óleo e filtro', price: 189.90),
          ServiceOrderItem(serviceName: 'Pastilhas de freio', price: 320.00),
        ],
        openedAt: DateTime(now.year, now.month, now.day, 14, 20),
        assignedEmployeeName: 'Carlos Almeida',
      ),
      ServiceOrder(
        id: 'os-1041',
        number: '#OS-1041',
        status: ServiceOrderStatus.awaitingApproval,
        customerName: 'Maria Santos',
        vehicleDescription: 'Fiat Argo 2022 • XYZ-9F87',
        summary: 'Alinhamento e balanceamento',
        items: const [
          ServiceOrderItem(serviceName: 'Alinhamento e balanceamento', price: 150.00),
        ],
        openedAt: DateTime(now.year, now.month, now.day, 11, 5),
        assignedEmployeeName: 'Rafael Souza',
      ),
      ServiceOrder(
        id: 'os-1039',
        number: '#OS-1039',
        status: ServiceOrderStatus.testing,
        customerName: 'Pedro Costa',
        vehicleDescription: 'VW Gol 2018 • KLM-4E56',
        summary: 'Revisão do motor com diagnóstico',
        items: const [
          ServiceOrderItem(serviceName: 'Revisão do motor com diagnóstico', price: 450.00),
        ],
        openedAt: daysAgoAt(1, 16, 40),
        assignedEmployeeName: 'Carlos Almeida',
      ),
      ServiceOrder(
        id: 'os-1037',
        number: '#OS-1037',
        status: ServiceOrderStatus.approved,
        customerName: 'Ana Oliveira',
        vehicleDescription: 'Chevrolet Onix 2021 • QRS-7H21',
        summary: 'Pastilhas de freio dianteiras',
        items: const [
          ServiceOrderItem(serviceName: 'Pastilhas de freio dianteiras', price: 320.00),
        ],
        openedAt: daysAgoAt(1, 9, 15),
        assignedEmployeeName: 'José Lima',
      ),
      ServiceOrder(
        id: 'os-1035',
        number: '#OS-1035',
        status: ServiceOrderStatus.inProgress,
        customerName: 'Luiz Fernandes',
        vehicleDescription: 'Toyota Corolla 2019 • JKL-3B45',
        summary: 'Troca de correia dentada',
        items: const [
          ServiceOrderItem(serviceName: 'Correia dentada', price: 280.00),
          ServiceOrderItem(serviceName: 'Tensionador', price: 95.00),
        ],
        openedAt: daysAgoAt(2, 10, 30),
        assignedEmployeeName: 'Rafael Souza',
      ),
      ServiceOrder(
        id: 'os-1033',
        number: '#OS-1033',
        status: ServiceOrderStatus.awaitingApproval,
        customerName: 'Camila Rocha',
        vehicleDescription: 'Hyundai HB20 2023 • MNO-8G12',
        summary: 'Troca de bateria e revisão elétrica',
        items: const [
          ServiceOrderItem(serviceName: 'Bateria 60Ah', price: 420.00),
          ServiceOrderItem(serviceName: 'Revisão elétrica', price: 90.00),
        ],
        openedAt: daysAgoAt(3, 15, 0),
        assignedEmployeeName: 'José Lima',
      ),
      ServiceOrder(
        id: 'os-1031',
        number: '#OS-1031',
        status: ServiceOrderStatus.testing,
        customerName: 'Bruno Martins',
        vehicleDescription: 'Jeep Renegade 2020 • PQR-2C89',
        summary: 'Diagnóstico de suspensão',
        items: const [
          ServiceOrderItem(serviceName: 'Diagnóstico de suspensão', price: 180.00),
        ],
        openedAt: daysAgoAt(4, 8, 45),
        assignedEmployeeName: 'Carlos Almeida',
      ),
      ServiceOrder(
        id: 'os-1029',
        number: '#OS-1029',
        status: ServiceOrderStatus.approved,
        customerName: 'Fernanda Lima',
        vehicleDescription: 'Renault Kwid 2021 • STU-5D67',
        summary: 'Troca de pneus dianteiros',
        items: const [
          ServiceOrderItem(serviceName: 'Pneu dianteiro (par)', price: 560.00),
        ],
        openedAt: daysAgoAt(5, 13, 10),
        assignedEmployeeName: 'Rafael Souza',
      ),
    ];
  }
}
