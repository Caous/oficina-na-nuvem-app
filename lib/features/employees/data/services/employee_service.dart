import 'package:oficina_app/features/employees/models/employee.dart';

/// Contrato de acesso a dados de funcionários.
///
/// O repositório depende desta abstração (DIP), nunca da implementação
/// concreta, permitindo trocar o mock por uma API real sem tocar em outras
/// camadas.
abstract class EmployeeService {
  Future<List<Employee>> fetchAll();

  Future<Employee> create(Employee employee);

  Future<Employee> update(Employee employee);

  Future<void> delete(String id);
}
