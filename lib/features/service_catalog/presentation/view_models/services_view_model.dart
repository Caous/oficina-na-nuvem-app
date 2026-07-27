import 'package:flutter/foundation.dart';
import 'package:oficina_app/core/state/view_state.dart';
import 'package:oficina_app/features/service_catalog/data/repositories/service_catalog_repository.dart';
import 'package:oficina_app/features/service_catalog/models/service_category.dart';
import 'package:oficina_app/features/service_catalog/models/workshop_service.dart';

/// Estado e ações da listagem de serviços do catálogo.
class ServicesViewModel extends ChangeNotifier {
  final ServiceCatalogRepository _repository;

  ServicesViewModel({required ServiceCatalogRepository repository})
    : _repository = repository;

  ViewState<List<WorkshopService>> _state = const ViewStateLoading();
  List<ServiceCategory> _categories = const [];
  String? _selectedCategoryId;

  ViewState<List<WorkshopService>> get state => _state;

  List<ServiceCategory> get categories => _categories;

  /// `null` significa que o filtro "Todos" está selecionado.
  String? get selectedCategoryId => _selectedCategoryId;

  int get totalCount => _state.dataOrNull?.length ?? 0;

  /// Serviços após aplicar o filtro de categoria selecionado.
  List<WorkshopService> get visibleServices {
    final services = _state.dataOrNull;

    if (services == null) {
      return const [];
    }

    final categoryId = _selectedCategoryId;

    if (categoryId == null) {
      return services;
    }

    return services.where((s) => s.categoryId == categoryId).toList();
  }

  String categoryNameOf(String categoryId) {
    for (final category in _categories) {
      if (category.id == categoryId) {
        return category.name;
      }
    }

    return '—';
  }

  Future<void> load() async {
    _state = const ViewStateLoading();
    notifyListeners();

    try {
      final categories = await _repository.fetchCategories();
      final services = await _repository.fetchServices();

      _categories = categories;
      _state = ViewStateSuccess(services);
    } catch (_) {
      _state = const ViewStateFailure('Não foi possível carregar os serviços.');
    } finally {
      notifyListeners();
    }
  }

  void filterByCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  Future<bool> delete(String id) async {
    try {
      await _repository.deleteService(id);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }
}
