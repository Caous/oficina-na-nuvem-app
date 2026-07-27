import 'package:flutter/foundation.dart';

import '../../data/repositories/service_catalog_repository.dart';
import '../../models/service_category.dart';
import '../../models/workshop_service.dart';

/// Cadastro/edição de um serviço do catálogo.
///
/// Trata apenas do "cardápio" da oficina — nome, descrição, preço, desconto
/// máximo e categoria. Cliente e veículo pertencem à ordem de serviço, não ao
/// catálogo.
class ServiceFormViewModel extends ChangeNotifier {
  final ServiceCatalogRepository _repository;
  final WorkshopService? _initial;

  ServiceFormViewModel({
    required ServiceCatalogRepository repository,
    WorkshopService? initial,
  }) : _repository = repository,
       _initial = initial;

  List<ServiceCategory> _categories = const [];
  ServiceCategory? _selectedCategory;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  WorkshopService? get initial => _initial;
  bool get isEditing => _initial != null;

  List<ServiceCategory> get categories => _categories;
  ServiceCategory? get selectedCategory => _selectedCategory;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  /// Nenhuma categoria cadastrada ainda: a tela oferece criar a primeira.
  bool get hasNoCategories => !_isLoading && _categories.isEmpty;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _categories = await _repository.fetchCategories();
      _restoreCategoryOfEditedService();
    } catch (_) {
      _errorMessage = 'Não foi possível carregar as categorias.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _restoreCategoryOfEditedService() {
    final editedService = _initial;

    if (editedService == null) {
      return;
    }

    for (final category in _categories) {
      if (category.id == editedService.categoryId) {
        _selectedCategory = category;
        return;
      }
    }
  }

  void selectCategory(ServiceCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  /// Cria uma categoria sem sair do formulário e já a deixa selecionada.
  Future<bool> createCategory(String name) async {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      _errorMessage = 'Informe o nome da categoria.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _repository.createCategory(trimmed);
      _categories = [..._categories, created];
      _selectedCategory = created;
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível criar a categoria.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> save({
    required String name,
    required String description,
    required double price,
    required double maxDiscountPercent,
  }) async {
    final category = _selectedCategory;

    if (category == null) {
      _errorMessage = 'Selecione a categoria do serviço.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final service = WorkshopService(
        id: _initial?.id ?? '',
        categoryId: category.id,
        name: name.trim(),
        description: description.trim(),
        price: price,
        maxDiscountPercent: maxDiscountPercent,
      );

      if (isEditing) {
        await _repository.updateService(service);
      } else {
        await _repository.createService(service);
      }

      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível salvar o serviço.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> delete() async {
    final editedService = _initial;

    if (editedService == null) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteService(editedService.id);
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível excluir o serviço.';
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
