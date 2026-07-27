import 'package:oficina_app/features/service_catalog/data/services/service_catalog_service.dart';
import 'package:oficina_app/features/service_catalog/models/service_category.dart';
import 'package:oficina_app/features/service_catalog/models/workshop_service.dart';

/// Ponte entre os view models do catálogo de serviços e as fontes de dados.
class ServiceCatalogRepository {
  final ServiceCategoryService _categoryService;
  final WorkshopServiceService _serviceService;

  ServiceCatalogRepository({
    required ServiceCategoryService categoryService,
    required WorkshopServiceService serviceService,
  }) : _categoryService = categoryService,
       _serviceService = serviceService;

  Future<List<ServiceCategory>> fetchCategories() =>
      _categoryService.fetchCategories();

  Future<ServiceCategory> createCategory(String name) =>
      _categoryService.createCategory(name);

  Future<ServiceCategory> updateCategory(ServiceCategory category) =>
      _categoryService.updateCategory(category);

  Future<void> deleteCategory(String id) =>
      _categoryService.deleteCategory(id);

  Future<List<WorkshopService>> fetchServices() =>
      _serviceService.fetchServices();

  Future<WorkshopService> createService(WorkshopService service) =>
      _serviceService.createService(service);

  Future<WorkshopService> updateService(WorkshopService service) =>
      _serviceService.updateService(service);

  Future<void> deleteService(String id) => _serviceService.deleteService(id);

  /// Conta quantos serviços estão vinculados à categoria informada.
  Future<int> countServicesInCategory(String categoryId) async {
    final services = await _serviceService.fetchServices();

    return services.where((s) => s.categoryId == categoryId).length;
  }
}
