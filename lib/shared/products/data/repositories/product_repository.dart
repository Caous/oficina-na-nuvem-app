import '../../models/product.dart';
import '../services/product_service.dart';

/// Ponto único de acesso aos produtos, usado pela gestão de estoque da oficina
/// e pelo marketplace do cliente.
class ProductRepository {
  final ProductService _service;

  ProductRepository({required ProductService service}) : _service = service;

  Future<List<Product>> fetchAll() => _service.fetchAll();

  /// Apenas o que o cliente pode ver: publicado e com estoque.
  Future<List<Product>> fetchPublished() => _service.fetchPublished();

  Future<Product> create(Product product) => _service.create(product);

  Future<Product> update(Product product) => _service.update(product);

  Future<void> delete(String id) => _service.delete(id);

  Future<Product> adjustStock(String id, int delta) =>
      _service.adjustStock(id, delta);

  Future<Product> setPublished(String id, bool isPublished) =>
      _service.setPublished(id, isPublished);
}
