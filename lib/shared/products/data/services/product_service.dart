import '../../models/product.dart';

/// Acesso aos produtos do estoque da oficina.
abstract class ProductService {
  Future<List<Product>> fetchAll();

  Future<Product> create(Product product);

  Future<Product> update(Product product);

  Future<void> delete(String id);

  /// Soma [delta] ao estoque (negativo dá baixa). Nunca deixa o saldo negativo.
  Future<Product> adjustStock(String id, int delta);

  /// Publica ou remove o produto do marketplace do cliente.
  Future<Product> setPublished(String id, bool isPublished);
}
