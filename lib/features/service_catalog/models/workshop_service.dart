/// Serviço do catálogo da oficina, vinculado a uma categoria.
class WorkshopService {
  final String id;
  final String categoryId;
  final String name;
  final String description;

  /// Preço cheio do serviço, em reais.
  final double price;

  /// Desconto máximo permitido, de 0 a 100.
  final double maxDiscountPercent;

  const WorkshopService({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.maxDiscountPercent,
  });

  /// Menor valor que pode ser cobrado aplicando o desconto máximo.
  double get minimumPrice => price * (1 - maxDiscountPercent / 100);

  WorkshopService copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    double? maxDiscountPercent,
  }) {
    return WorkshopService(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      maxDiscountPercent: maxDiscountPercent ?? this.maxDiscountPercent,
    );
  }
}
