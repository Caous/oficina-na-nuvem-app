import 'package:flutter/foundation.dart';
import 'package:oficina_app/features/employees/data/repositories/employee_repository.dart';
import 'package:oficina_app/features/employees/models/employee.dart';
import 'package:oficina_app/shared/address_lookup/models/address.dart';

/// Estado e ações do formulário de criação/edição de funcionário.
class EmployeeFormViewModel extends ChangeNotifier {
  final EmployeeRepository _repository;
  final Employee? initial;

  EmployeeFormViewModel({
    required EmployeeRepository repository,
    this.initial,
  }) : _repository = repository;

  bool get isEditing => initial != null;

  bool _isSaving = false;
  String? _errorMessage;
  EmployeeRole? _selectedRole;

  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  EmployeeRole? get selectedRole => _selectedRole ?? initial?.role;

  void selectRole(EmployeeRole role) {
    _selectedRole = role;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> save({
    required String name,
    required String document,
    required String phone,
    required String email,
    Address address = Address.empty,
  }) async {
    final role = selectedRole;

    if (role == null) {
      _errorMessage = 'Selecione o cargo do funcionário.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentInitial = initial;

      if (currentInitial == null) {
        await _repository.create(
          Employee(
            id: '',
            name: name,
            document: document,
            phone: phone,
            email: email,
            role: role,
            address: address,
          ),
        );
      } else {
        await _repository.update(
          currentInitial.copyWith(
            name: name,
            document: document,
            phone: phone,
            email: email,
            role: role,
            address: address,
          ),
        );
      }

      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível salvar o funcionário.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> delete() async {
    final currentInitial = initial;

    if (currentInitial == null) {
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.delete(currentInitial.id);
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível excluir o funcionário.';
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
