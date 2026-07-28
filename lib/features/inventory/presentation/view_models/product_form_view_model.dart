import 'package:flutter/foundation.dart';

import '../../../../shared/products/data/repositories/product_repository.dart';
import '../../../../shared/products/models/product.dart';

/// Cadastro e edição de um produto do estoque.
class ProductFormViewModel extends ChangeNotifier {
  final ProductRepository _repository;
  final Product? _initial;

  ProductFormViewModel({
    required ProductRepository repository,
    Product? initial,
  }) : _repository = repository,
       _initial = initial;

  late ProductCategory _selectedCategory =
      _initial?.category ?? ProductCategory.oils;
  late bool _isPublished = _initial?.isPublished ?? false;

  bool _isSaving = false;
  String? _errorMessage;

  Product? get initial => _initial;
  bool get isEditing => _initial != null;

  ProductCategory get selectedCategory => _selectedCategory;
  bool get isPublished => _isPublished;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  void selectCategory(ProductCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setPublished(bool value) {
    _isPublished = value;
    notifyListeners();
  }

  Future<bool> save({
    required String name,
    required String description,
    required String sku,
    required double price,
    required int stockQuantity,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final product = Product(
        id: _initial?.id ?? '',
        name: name.trim(),
        description: description.trim(),
        category: _selectedCategory,
        sku: sku.trim(),
        price: price,
        stockQuantity: stockQuantity,
        isPublished: _isPublished,
      );

      if (isEditing) {
        await _repository.update(product);
      } else {
        await _repository.create(product);
      }

      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível salvar o produto.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> delete() async {
    final product = _initial;

    if (product == null) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.delete(product.id);
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível excluir o produto.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
