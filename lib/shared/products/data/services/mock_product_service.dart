import '../../models/product.dart';
import 'product_service.dart';

/// Estoque em memória, compartilhado pela gestão da oficina e pelo
/// marketplace do cliente — o que a oficina publica aparece na loja.
class MockProductService implements ProductService {
  static const Duration _latency = Duration(milliseconds: 400);

  final List<Product> _products = [
    const Product(
      id: 'p1',
      name: 'Óleo Motor 5W30 Sintético 1L',
      description:
          'Óleo sintético de alto desempenho para motores flex e a gasolina. '
          'Intervalo de troca de até 10.000 km.',
      category: ProductCategory.oils,
      sku: '0012',
      price: 49.90,
      stockQuantity: 24,
      isPublished: true,
    ),
    const Product(
      id: 'p2',
      name: 'Filtro de Óleo Original Honda',
      description: 'Filtro original para linha Civic, Fit e HR-V.',
      category: ProductCategory.filters,
      sku: '0034',
      price: 29.90,
      stockQuantity: 11,
      isPublished: true,
    ),
    const Product(
      id: 'p3',
      name: 'Pneu Aro 15 185/65 R15',
      description: 'Pneu radial para uso urbano, alta durabilidade.',
      category: ProductCategory.tires,
      sku: '0078',
      price: 389.00,
      stockQuantity: 4,
    ),
    const Product(
      id: 'p4',
      name: 'Central Multimídia 7" CarPlay',
      description:
          'Central com tela de 7 polegadas, Apple CarPlay e Android Auto sem fio.',
      category: ProductCategory.sound,
      sku: '0091',
      price: 899.00,
      stockQuantity: 6,
      isPublished: true,
    ),
    const Product(
      id: 'p5',
      name: 'Pastilha de Freio Dianteira',
      description: 'Jogo de pastilhas cerâmicas, baixo ruído e pouca poeira.',
      category: ProductCategory.parts,
      sku: '0105',
      price: 189.90,
      stockQuantity: 9,
      isPublished: true,
    ),
    const Product(
      id: 'p6',
      name: 'Tapete de Borracha Universal',
      description: 'Jogo com 4 peças, recorte universal e bordas altas.',
      category: ProductCategory.accessories,
      sku: '0131',
      price: 129.90,
      stockQuantity: 15,
      isPublished: true,
    ),
    const Product(
      id: 'p7',
      name: 'Bateria 60Ah 18 meses',
      description: 'Bateria selada com 18 meses de garantia.',
      category: ProductCategory.parts,
      sku: '0142',
      price: 549.00,
      stockQuantity: 3,
    ),
    const Product(
      id: 'p8',
      name: 'Filtro de Ar Esportivo',
      description: 'Filtro lavável de fluxo livre, ganho de resposta.',
      category: ProductCategory.filters,
      sku: '0158',
      price: 219.90,
      stockQuantity: 0,
    ),
  ];

  int _nextId = 9;

  @override
  Future<List<Product>> fetchAll() async {
    await Future<void>.delayed(_latency);

    return List.unmodifiable(_products);
  }

  @override
  Future<Product> create(Product product) async {
    await Future<void>.delayed(_latency);

    final created = product.copyWith(id: 'p${_nextId++}');
    _products.insert(0, created);

    return created;
  }

  @override
  Future<Product> update(Product product) async {
    await Future<void>.delayed(_latency);

    return _replace(product.id, (_) => product);
  }

  @override
  Future<void> delete(String id) async {
    await Future<void>.delayed(_latency);

    final index = _indexOf(id);
    _products.removeAt(index);
  }

  @override
  Future<Product> adjustStock(String id, int delta) async {
    await Future<void>.delayed(_latency);

    return _replace(id, (current) {
      final updated = current.stockQuantity + delta;

      return current.copyWith(stockQuantity: updated < 0 ? 0 : updated);
    });
  }

  @override
  Future<Product> setPublished(String id, bool isPublished) async {
    await Future<void>.delayed(_latency);

    return _replace(id, (current) => current.copyWith(isPublished: isPublished));
  }

  Product _replace(String id, Product Function(Product current) transform) {
    final index = _indexOf(id);
    final updated = transform(_products[index]);

    _products[index] = updated;

    return updated;
  }

  int _indexOf(String id) {
    final index = _products.indexWhere((product) => product.id == id);

    if (index == -1) {
      throw StateError('Produto $id não encontrado.');
    }

    return index;
  }
}
