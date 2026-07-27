import 'package:oficina_app/features/employees/data/services/employee_service.dart';
import 'package:oficina_app/features/employees/models/employee.dart';

/// Implementação em memória de [EmployeeService], usada enquanto não há
/// backend real. Simula latência de rede em cada operação.
class MockEmployeeService implements EmployeeService {
  static const _delay = Duration(milliseconds: 400);

  final List<Employee> _employees = [
    const Employee(
      id: '1',
      name: 'Carlos Almeida',
      document: '123.456.789-00',
      phone: '(11) 98888-1111',
      email: 'carlos@oficinadoze.com.br',
      role: EmployeeRole.chiefMechanic,
    ),
    const Employee(
      id: '2',
      name: 'Rafael Souza',
      document: '234.567.890-11',
      phone: '(11) 97777-2222',
      email: 'rafael@oficinadoze.com.br',
      role: EmployeeRole.mechanic,
    ),
    const Employee(
      id: '3',
      name: 'Marina Prado',
      document: '345.678.901-22',
      phone: '(11) 96666-3333',
      email: 'marina@oficinadoze.com.br',
      role: EmployeeRole.attendant,
    ),
    const Employee(
      id: '4',
      name: 'José Lima',
      document: '456.789.012-33',
      phone: '(11) 95555-4444',
      email: 'jose@oficinadoze.com.br',
      role: EmployeeRole.electrician,
    ),
  ];

  int _nextId = 5;

  @override
  Future<List<Employee>> fetchAll() async {
    await Future.delayed(_delay);

    return List.unmodifiable(_employees);
  }

  @override
  Future<Employee> create(Employee employee) async {
    await Future.delayed(_delay);

    final created = employee.copyWith(id: '${_nextId++}');
    _employees.add(created);

    return created;
  }

  @override
  Future<Employee> update(Employee employee) async {
    await Future.delayed(_delay);

    final index = _employees.indexWhere((e) => e.id == employee.id);

    if (index == -1) {
      throw StateError('Funcionário ${employee.id} não encontrado.');
    }

    _employees[index] = employee;

    return employee;
  }

  @override
  Future<void> delete(String id) async {
    await Future.delayed(_delay);

    final removed = _employees.any((e) => e.id == id);

    if (!removed) {
      throw StateError('Funcionário $id não encontrado.');
    }

    _employees.removeWhere((e) => e.id == id);
  }
}
