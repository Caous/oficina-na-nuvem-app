import 'package:flutter/foundation.dart';
import 'package:oficina_app/core/state/view_state.dart';
import 'package:oficina_app/features/employees/data/repositories/employee_repository.dart';
import 'package:oficina_app/features/employees/models/employee.dart';

/// Estado e ações da listagem de funcionários.
class EmployeesViewModel extends ChangeNotifier {
  final EmployeeRepository _repository;

  EmployeesViewModel({required EmployeeRepository repository})
    : _repository = repository;

  ViewState<List<Employee>> _state = const ViewStateLoading();
  String _searchQuery = '';

  ViewState<List<Employee>> get state => _state;

  /// Funcionários filtrados pela busca atual, ou lista vazia enquanto não
  /// há dados de sucesso carregados.
  List<Employee> get visibleEmployees {
    final employees = _state.dataOrNull;

    if (employees == null) {
      return const [];
    }

    final normalized = _searchQuery.trim().toLowerCase();

    if (normalized.isEmpty) {
      return employees;
    }

    return employees
        .where(
          (employee) =>
              employee.name.toLowerCase().contains(normalized) ||
              employee.role.label.toLowerCase().contains(normalized) ||
              employee.phone.toLowerCase().contains(normalized),
        )
        .toList();
  }

  int get totalCount => _state.dataOrNull?.length ?? 0;

  Future<void> load() async {
    _state = const ViewStateLoading();
    notifyListeners();

    try {
      final employees = await _repository.fetchAll();
      _state = ViewStateSuccess(employees);
    } catch (_) {
      _state = const ViewStateFailure('Não foi possível carregar os funcionários.');
    } finally {
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<bool> delete(String id) async {
    try {
      await _repository.delete(id);
      await load();
      return true;
    } catch (_) {
      return false;
    }
  }
}
