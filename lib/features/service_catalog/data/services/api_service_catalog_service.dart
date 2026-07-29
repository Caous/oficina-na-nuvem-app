import '../../../../core/network/api_client.dart';
import '../../models/service_category.dart';
import '../../models/workshop_service.dart';
import 'service_catalog_service.dart';

/// Catálogo da oficina: categorias em `/service-categories`, serviços em
/// `/services`.
class ApiServiceCatalogService
    implements ServiceCategoryService, WorkshopServiceService {
  final ApiClient _api;

  ApiServiceCatalogService({required ApiClient api}) : _api = api;

  @override
  Future<List<ServiceCategory>> fetchCategories() async {
    final json = await _api.get('/service-categories') as List<dynamic>;

    return json
        .map((item) => _categoryFromApi(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<ServiceCategory> createCategory(String name) async {
    final json = await _api.post(
      '/service-categories',
      body: {'name': name},
    ) as Map<String, dynamic>;

    return _categoryFromApi(json);
  }

  @override
  Future<ServiceCategory> updateCategory(ServiceCategory category) async {
    final json = await _api.put('/service-categories/${category.id}', body: {
      'name': category.name,
      'style': category.style.name.toUpperCase(),
    }) as Map<String, dynamic>;

    return _categoryFromApi(json);
  }

  @override
  Future<void> deleteCategory(String id) {
    return _api.delete('/service-categories/$id');
  }

  @override
  Future<List<WorkshopService>> fetchServices() async {
    final json = await _api.get('/services') as List<dynamic>;

    return json
        .map((item) => _serviceFromApi(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<WorkshopService> createService(WorkshopService service) async {
    final json = await _api.post(
      '/services',
      body: _serviceToApi(service),
    ) as Map<String, dynamic>;

    return _serviceFromApi(json);
  }

  @override
  Future<WorkshopService> updateService(WorkshopService service) async {
    final json = await _api.put(
      '/services/${service.id}',
      body: _serviceToApi(service),
    ) as Map<String, dynamic>;

    return _serviceFromApi(json);
  }

  @override
  Future<void> deleteService(String id) {
    return _api.delete('/services/$id');
  }

  ServiceCategory _categoryFromApi(Map<String, dynamic> json) {
    final apiStyle = json['style']?.toString().toLowerCase();

    final style = ServiceCategoryStyle.values.firstWhere(
      (candidate) => candidate.name.toLowerCase() == apiStyle,
      orElse: () => ServiceCategoryStyle.generic,
    );

    return ServiceCategory(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      style: style,
    );
  }

  Map<String, dynamic> _serviceToApi(WorkshopService service) {
    return {
      'categoryId': int.parse(service.categoryId),
      'name': service.name,
      'description': service.description,
      'price': service.price,
      'maxDiscountPercent': service.maxDiscountPercent,
    };
  }

  WorkshopService _serviceFromApi(Map<String, dynamic> json) {
    return WorkshopService(
      id: json['id'].toString(),
      categoryId: json['categoryId'].toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num).toDouble(),
      maxDiscountPercent: (json['maxDiscountPercent'] as num).toDouble(),
    );
  }
}
