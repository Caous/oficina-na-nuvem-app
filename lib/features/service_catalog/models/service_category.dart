/// Categoria que agrupa serviços do catálogo da oficina.
class ServiceCategory {
  final String id;
  final String name;

  /// Chave visual da categoria; mapeada para ícone e cor na camada de UI,
  /// mantendo o modelo livre de dependências do Flutter.
  final ServiceCategoryStyle style;

  const ServiceCategory({
    required this.id,
    required this.name,
    this.style = ServiceCategoryStyle.generic,
  });

  ServiceCategory copyWith({
    String? id,
    String? name,
    ServiceCategoryStyle? style,
  }) {
    return ServiceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      style: style ?? this.style,
    );
  }
}

/// Identidade visual de uma categoria.
enum ServiceCategoryStyle {
  engine,
  brakes,
  suspension,
  electrical,
  fluids,
  generic,
}
