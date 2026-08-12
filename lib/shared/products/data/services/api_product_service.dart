import '../../../../core/network/api_client.dart';
import '../../models/product.dart';
import 'product_service.dart';

/// Produtos contra o backend: o estoque privado da oficina em `/products` e a
/// vitrine do cliente em `/marketplace/products`.
class ApiProductService implements ProductService {
  static const Map<ProductCategory, String> _categoryToApi = {
    ProductCategory.oils: 'OILS',
    ProductCategory.filters: 'FILTERS',
    ProductCategory.tires: 'TIRES',
    ProductCategory.parts: 'PARTS',
    ProductCategory.accessories: 'ACCESSORIES',
    ProductCategory.sound: 'SOUND',
  };

  final ApiClient _api;

  ApiProductService({required ApiClient api}) : _api = api;

  @override
  Future<List<Product>> fetchAll() async {
    final json = await _api.get('/products') as List<dynamic>;

    return json
        .map((item) => _fromApi(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<List<Product>> fetchPublished() async {
    final json = await _api.get('/marketplace/products') as List<dynamic>;

    return json
        .map((item) => _fromMarketplaceApi(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Product> create(Product product) async {
    final json = await _api.post(
      '/products',
      body: _toApi(product),
    ) as Map<String, dynamic>;

    return _fromApi(json);
  }

  @override
  Future<Product> update(Product product) async {
    final json = await _api.put(
      '/products/${product.id}',
      body: _toApi(product),
    ) as Map<String, dynamic>;

    return _fromApi(json);
  }

  @override
  Future<void> delete(String id) {
    return _api.delete('/products/$id');
  }

  @override
  Future<Product> adjustStock(String id, int delta) async {
    final json = await _api.patch(
      '/products/$id/stock',
      body: {'delta': delta},
    ) as Map<String, dynamic>;

    return _fromApi(json);
  }

  @override
  Future<Product> setPublished(String id, bool isPublished) async {
    final json = await _api.patch(
      '/products/$id/publish',
      body: {'published': isPublished},
    ) as Map<String, dynamic>;

    return _fromApi(json);
  }

  Map<String, dynamic> _toApi(Product product) {
    return {
      'name': product.name,
      'description': product.description,
      'category': _categoryToApi[product.category],
      'sku': product.sku,
      'price': product.price,
      'stockQuantity': product.stockQuantity,
      'published': product.isPublished,
    };
  }

  Product _fromApi(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: _categoryFromApi(json['category']?.toString()),
      sku: json['sku']?.toString() ?? '',
      price: (json['price'] as num).toDouble(),
      stockQuantity: (json['stockQuantity'] as num).toInt(),
      isPublished: json['published'] == true,
    );
  }

  /// A vitrine não manda o flag de publicação (implícito) e traz o vendedor.
  Product _fromMarketplaceApi(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: _categoryFromApi(json['category']?.toString()),
      sku: json['sku']?.toString() ?? '',
      price: (json['price'] as num).toDouble(),
      stockQuantity: (json['stockQuantity'] as num).toInt(),
      isPublished: true,
      sellerName: json['sellerName']?.toString() ?? '',
    );
  }

  ProductCategory _categoryFromApi(String? value) {
    return _categoryToApi.entries
        .firstWhere(
          (entry) => entry.value == value,
          orElse: () => const MapEntry(ProductCategory.parts, 'PARTS'),
        )
        .key;
  }
}
