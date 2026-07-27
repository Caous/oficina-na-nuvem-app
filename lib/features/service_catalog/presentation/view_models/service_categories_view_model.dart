import 'package:flutter/foundation.dart';
import 'package:oficina_app/core/state/view_state.dart';
import 'package:oficina_app/features/service_catalog/data/repositories/service_catalog_repository.dart';
import 'package:oficina_app/features/service_catalog/models/service_category.dart';

/// Estado e ações da listagem de categorias de serviço.
class ServiceCategoriesViewModel extends ChangeNotifier {
  final ServiceCatalogRepository _repository;

  ServiceCategoriesViewModel({required ServiceCatalogRepository repository})
    : _repository = repository;

  ViewState<List<ServiceCategory>> _state = const ViewStateLoading();
  Map<String, int> _serviceCountByCategory = const {};
  bool _isSaving = false;
  String? _errorMessage;

  ViewState<List<ServiceCategory>> get state => _state;

  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  int get totalCount => _state.dataOrNull?.length ?? 0;

  /// Quantidade de serviços vinculados à categoria, ou zero se desconhecida.
  int serviceCountFor(String categoryId) =>
      _serviceCountByCategory[categoryId] ?? 0;

  Future<void> load() async {
    _state = const ViewStateLoading();
    notifyListeners();

    try {
      final categories = await _repository.fetchCategories();
      final services = await _repository.fetchServices();

      final counts = <String, int>{};
      for (final service in services) {
        counts[service.categoryId] = (counts[service.categoryId] ?? 0) + 1;
      }

      _serviceCountByCategory = counts;
      _state = ViewStateSuccess(categories);
    } catch (_) {
      _state = const ViewStateFailure(
        'Não foi possível carregar as categorias.',
      );
    } finally {
      notifyListeners();
    }
  }

  Future<bool> create(String name) async {
    final trimmed = name.trim();

    if (trimmed.isEmpty) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.createCategory(trimmed);
      await load();
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível criar a categoria.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> rename(ServiceCategory category, String newName) async {
    final trimmed = newName.trim();

    if (trimmed.isEmpty) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateCategory(category.copyWith(name: trimmed));
      await load();
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível renomear a categoria.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> delete(String id) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteCategory(id);
      await load();
      return true;
    } on StateError catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Não foi possível excluir a categoria.';
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
