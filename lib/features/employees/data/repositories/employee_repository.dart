import 'package:oficina_app/features/employees/data/services/employee_service.dart';
import 'package:oficina_app/features/employees/models/employee.dart';

/// Ponte entre os view models de funcionários e a fonte de dados.
class EmployeeRepository {
  final EmployeeService _service;

  EmployeeRepository({required EmployeeService service})
    : _service = service;

  Future<List<Employee>> fetchAll() => _service.fetchAll();

  Future<Employee> create(Employee employee) => _service.create(employee);

  Future<Employee> update(Employee employee) => _service.update(employee);

  Future<void> delete(String id) => _service.delete(id);
}
