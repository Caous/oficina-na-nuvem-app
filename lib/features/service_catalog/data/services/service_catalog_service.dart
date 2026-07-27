import 'package:oficina_app/features/service_catalog/models/service_category.dart';
import 'package:oficina_app/features/service_catalog/models/workshop_service.dart';

/// Contrato de acesso a dados de categorias de serviço.
///
/// O repositório depende desta abstração (DIP), nunca da implementação
/// concreta, permitindo trocar o mock por uma API real sem tocar em outras
/// camadas.
abstract class ServiceCategoryService {
  Future<List<ServiceCategory>> fetchCategories();

  Future<ServiceCategory> createCategory(String name);

  Future<ServiceCategory> updateCategory(ServiceCategory category);

  Future<void> deleteCategory(String id);
}

/// Contrato de acesso a dados de serviços do catálogo.
///
/// Separado de [ServiceCategoryService] (ISP): quem só precisa de serviços
/// não é forçado a depender de operações de categoria.
abstract class WorkshopServiceService {
  Future<List<WorkshopService>> fetchServices();

  Future<WorkshopService> createService(WorkshopService service);

  Future<WorkshopService> updateService(WorkshopService service);

  Future<void> deleteService(String id);
}
