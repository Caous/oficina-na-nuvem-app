/// Categoria de um produto do estoque/marketplace.
enum ProductCategory {
  oils('Óleos'),
  filters('Filtros'),
  tires('Pneus'),
  parts('Peças'),
  accessories('Acessórios'),
  sound('Som');

  final String label;

  const ProductCategory(this.label);
}

/// Produto do estoque da oficina, que pode ou não estar publicado no
/// marketplace do cliente.
///
/// É o mesmo registro nas duas pontas: a oficina controla preço, quantidade e
/// publicação; o cliente vê apenas os publicados e com estoque.
class Product {
  final String id;
  final String name;
  final String description;
  final ProductCategory category;
  final String sku;

  /// Preço de venda, em reais.
  final double price;

  /// Quantidade disponível em estoque.
  final int stockQuantity;

  /// Quando verdadeiro, aparece no marketplace do cliente.
  final bool isPublished;

  /// Oficina que anuncia o produto.
  final String sellerName;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.sku,
    required this.price,
    required this.stockQuantity,
    this.isPublished = false,
    this.sellerName = 'Oficina do Zé',
  });

  bool get isOutOfStock => stockQuantity <= 0;

  /// Só chega ao cliente o que está publicado e disponível.
  bool get isVisibleOnMarketplace => isPublished && !isOutOfStock;

  Product copyWith({
    String? id,
    String? name,
    String? description,
    ProductCategory? category,
    String? sku,
    double? price,
    int? stockQuantity,
    bool? isPublished,
    String? sellerName,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      sku: sku ?? this.sku,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isPublished: isPublished ?? this.isPublished,
      sellerName: sellerName ?? this.sellerName,
    );
  }
}

/// Critério de ordenação do marketplace.
enum ProductSort {
  lowestPrice('Menor preço'),
  highestPrice('Maior preço'),
  name('Nome A-Z');

  final String label;

  const ProductSort(this.label);
}
