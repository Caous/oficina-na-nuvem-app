import 'package:flutter/foundation.dart';

import '../../../../core/state/view_state.dart';
import '../../../../shared/products/data/repositories/product_repository.dart';
import '../../../../shared/products/models/product.dart';

/// Estoque da oficina: quantidade, preço e publicação no marketplace.
class InventoryViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  InventoryViewModel({required ProductRepository repository})
    : _repository = repository;

  ViewState<List<Product>> _state = const ViewStateLoading();
  String _searchQuery = '';
  String? _errorMessage;

  ViewState<List<Product>> get state => _state;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;

  List<Product> get _allProducts => _state.dataOrNull ?? const [];

  int get totalCount => _allProducts.length;

  int get publishedCount =>
      _allProducts.where((product) => product.isPublished).length;

  List<Product> get visibleProducts {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _allProducts;
    }

    return _allProducts
        .where(
          (product) =>
              product.name.toLowerCase().contains(query) ||
              product.sku.toLowerCase().contains(query) ||
              product.category.label.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  Future<void> load() async {
    _state = const ViewStateLoading();
    notifyListeners();

    try {
      _state = ViewStateSuccess(await _repository.fetchAll());
    } catch (_) {
      _state = const ViewStateFailure('Não foi possível carregar o estoque.');
    } finally {
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Dá entrada ou baixa no estoque sem recarregar a lista inteira.
  Future<bool> adjustStock(String id, int delta) async {
    return _applyChange(() => _repository.adjustStock(id, delta));
  }

  Future<bool> setPublished(String id, bool isPublished) async {
    return _applyChange(() => _repository.setPublished(id, isPublished));
  }

  Future<bool> delete(String id) async {
    _errorMessage = null;

    try {
      await _repository.delete(id);
      await load();
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível excluir o produto.';
      notifyListeners();
      return false;
    }
  }

  /// Substitui em memória o item devolvido pelo repositório, mantendo a
  /// posição na lista — recarregar tudo faria a linha "pular" a cada toque.
  Future<bool> _applyChange(Future<Product> Function() change) async {
    _errorMessage = null;

    try {
      final updated = await change();
      final current = [..._allProducts];
      final index = current.indexWhere((product) => product.id == updated.id);

      if (index == -1) {
        await load();
        return true;
      }

      current[index] = updated;
      _state = ViewStateSuccess(current);
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível atualizar o produto.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
