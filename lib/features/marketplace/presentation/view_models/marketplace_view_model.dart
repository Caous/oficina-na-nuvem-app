import 'package:flutter/foundation.dart';

import '../../../../core/state/view_state.dart';
import '../../../../shared/products/data/repositories/product_repository.dart';
import '../../../../shared/products/models/product.dart';
import '../../models/cart_item.dart';

/// Marketplace visto pelo cliente: peças e acessórios publicados pelas
/// oficinas, filtráveis por categoria e busca, com um carrinho local simples.
class MarketplaceViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  MarketplaceViewModel({required ProductRepository repository})
    : _repository = repository;

  ViewState<List<Product>> _state = const ViewStateLoading();
  String _searchQuery = '';
  ProductCategory? _selectedCategory;
  ProductSort _sort = ProductSort.lowestPrice;
  final List<CartItem> _cart = [];

  ViewState<List<Product>> get state => _state;
  String get searchQuery => _searchQuery;
  ProductCategory? get selectedCategory => _selectedCategory;
  ProductSort get sort => _sort;

  List<CartItem> get cartItems => List.unmodifiable(_cart);

  /// Total de unidades no carrinho (soma das quantidades).
  int get cartCount =>
      _cart.fold(0, (accumulated, item) => accumulated + item.quantity);

  double get cartSubtotal =>
      _cart.fold(0, (accumulated, item) => accumulated + item.lineTotal);

  List<Product> get _allProducts => _state.dataOrNull ?? const [];

  /// Total de produtos carregados, sem considerar filtro ou busca.
  int get totalCount => _allProducts.length;

  /// Produtos após filtro de categoria, busca e ordenação, nesta ordem.
  List<Product> get visibleProducts {
    final query = _searchQuery.trim().toLowerCase();

    var products = _allProducts;

    if (_selectedCategory != null) {
      products = products
          .where((product) => product.category == _selectedCategory)
          .toList(growable: false);
    }

    if (query.isNotEmpty) {
      products = products
          .where(
            (product) =>
                product.name.toLowerCase().contains(query) ||
                product.category.label.toLowerCase().contains(query),
          )
          .toList(growable: false);
    }

    final sorted = [...products];

    switch (_sort) {
      case ProductSort.lowestPrice:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.highestPrice:
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.name:
        sorted.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
    }

    return sorted;
  }

  Future<void> load() async {
    _state = const ViewStateLoading();
    notifyListeners();

    try {
      _state = ViewStateSuccess(await _repository.fetchPublished());
    } catch (_) {
      _state = const ViewStateFailure(
        'Não foi possível carregar o marketplace.',
      );
    } finally {
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void filterByCategory(ProductCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void changeSort(ProductSort sort) {
    _sort = sort;
    notifyListeners();
  }

  /// Adiciona unidades ao carrinho, agrupando por produto e respeitando o
  /// estoque disponível como teto.
  void addToCart(Product product, {int quantity = 1}) {
    if (quantity <= 0) {
      return;
    }

    final index = _cart.indexWhere((item) => item.product.id == product.id);
    final current = index == -1 ? 0 : _cart[index].quantity;
    final total = current + quantity;
    final capped = total > product.stockQuantity
        ? product.stockQuantity
        : total;

    if (capped <= 0) {
      return;
    }

    final item = CartItem(product: product, quantity: capped);

    if (index == -1) {
      _cart.add(item);
    } else {
      _cart[index] = item;
    }

    notifyListeners();
  }

  /// Soma [delta] à quantidade do item; abaixo de 1 o item permanece — a
  /// remoção é uma ação explícita ([removeFromCart]).
  void changeQuantity(String productId, int delta) {
    final index = _cart.indexWhere((item) => item.product.id == productId);

    if (index == -1) {
      return;
    }

    final item = _cart[index];
    final updated = (item.quantity + delta)
        .clamp(1, item.product.stockQuantity);

    if (updated == item.quantity) {
      return;
    }

    _cart[index] = item.copyWith(quantity: updated);
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}
