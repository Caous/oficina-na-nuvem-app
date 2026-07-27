import 'package:oficina_app/features/service_catalog/data/services/service_catalog_service.dart';
import 'package:oficina_app/features/service_catalog/models/service_category.dart';
import 'package:oficina_app/features/service_catalog/models/workshop_service.dart';

/// Implementação em memória de [ServiceCategoryService] e
/// [WorkshopServiceService], usada enquanto não há backend real. Simula
/// latência de rede em cada operação.
class MockServiceCatalogService
    implements ServiceCategoryService, WorkshopServiceService {
  static const _delay = Duration(milliseconds: 400);

  final List<ServiceCategory> _categories = [
    const ServiceCategory(
      id: '1',
      name: 'Motor',
      style: ServiceCategoryStyle.engine,
    ),
    const ServiceCategory(
      id: '2',
      name: 'Freios',
      style: ServiceCategoryStyle.brakes,
    ),
    const ServiceCategory(
      id: '3',
      name: 'Suspensão',
      style: ServiceCategoryStyle.suspension,
    ),
    const ServiceCategory(
      id: '4',
      name: 'Elétrica',
      style: ServiceCategoryStyle.electrical,
    ),
    const ServiceCategory(
      id: '5',
      name: 'Óleo e Fluidos',
      style: ServiceCategoryStyle.fluids,
    ),
  ];

  final List<WorkshopService> _services = [
    const WorkshopService(
      id: '1',
      categoryId: '5',
      name: 'Troca de óleo e filtro',
      description:
          'Inclui óleo sintético 5W30, filtro original e checagem de fluidos.',
      price: 189.90,
      maxDiscountPercent: 10,
    ),
    const WorkshopService(
      id: '2',
      categoryId: '2',
      name: 'Pastilhas de freio',
      description: 'Substituição do par dianteiro.',
      price: 320.00,
      maxDiscountPercent: 5,
    ),
    const WorkshopService(
      id: '3',
      categoryId: '3',
      name: 'Alinhamento e balanceamento',
      description: 'Rodas aro 13 a 18.',
      price: 150.00,
      maxDiscountPercent: 15,
    ),
    const WorkshopService(
      id: '4',
      categoryId: '1',
      name: 'Revisão do motor',
      description: 'Checagem completa com diagnóstico eletrônico.',
      price: 450.00,
      maxDiscountPercent: 8,
    ),
    const WorkshopService(
      id: '5',
      categoryId: '4',
      name: 'Troca de bateria',
      description: 'Substituição da bateria com teste do sistema elétrico.',
      price: 280.00,
      maxDiscountPercent: 12,
    ),
    const WorkshopService(
      id: '6',
      categoryId: '3',
      name: 'Troca de amortecedores',
      description: 'Substituição do par dianteiro ou traseiro.',
      price: 540.00,
      maxDiscountPercent: 10,
    ),
  ];

  int _nextCategoryId = 6;
  int _nextServiceId = 7;

  @override
  Future<List<ServiceCategory>> fetchCategories() async {
    await Future.delayed(_delay);

    return List.unmodifiable(_categories);
  }

  @override
  Future<ServiceCategory> createCategory(String name) async {
    await Future.delayed(_delay);

    final created = ServiceCategory(id: '${_nextCategoryId++}', name: name);
    _categories.add(created);

    return created;
  }

  @override
  Future<ServiceCategory> updateCategory(ServiceCategory category) async {
    await Future.delayed(_delay);

    final index = _categories.indexWhere((c) => c.id == category.id);

    if (index == -1) {
      throw StateError('Categoria ${category.id} não encontrada.');
    }

    _categories[index] = category;

    return category;
  }

  @override
  Future<void> deleteCategory(String id) async {
    await Future.delayed(_delay);

    final exists = _categories.any((c) => c.id == id);

    if (!exists) {
      throw StateError('Categoria $id não encontrada.');
    }

    final hasServices = _services.any((s) => s.categoryId == id);

    if (hasServices) {
      throw StateError(
        'Não é possível excluir uma categoria que possui serviços vinculados.',
      );
    }

    _categories.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<WorkshopService>> fetchServices() async {
    await Future.delayed(_delay);

    return List.unmodifiable(_services);
  }

  @override
  Future<WorkshopService> createService(WorkshopService service) async {
    await Future.delayed(_delay);

    final created = service.copyWith(id: '${_nextServiceId++}');
    _services.add(created);

    return created;
  }

  @override
  Future<WorkshopService> updateService(WorkshopService service) async {
    await Future.delayed(_delay);

    final index = _services.indexWhere((s) => s.id == service.id);

    if (index == -1) {
      throw StateError('Serviço ${service.id} não encontrado.');
    }

    _services[index] = service;

    return service;
  }

  @override
  Future<void> deleteService(String id) async {
    await Future.delayed(_delay);

    final exists = _services.any((s) => s.id == id);

    if (!exists) {
      throw StateError('Serviço $id não encontrado.');
    }

    _services.removeWhere((s) => s.id == id);
  }
}
