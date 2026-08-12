import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_mappers.dart';
import '../../models/employee.dart';
import 'employee_service.dart';

/// Equipe da oficina em `/employees`.
///
/// A tela não pede senha: o backend usa os dígitos do documento como senha
/// inicial do funcionário.
class ApiEmployeeService implements EmployeeService {
  static const Map<EmployeeRole, String> _roleToApi = {
    EmployeeRole.chiefMechanic: 'CHIEF_MECHANIC',
    EmployeeRole.mechanic: 'MECHANIC',
    EmployeeRole.electrician: 'ELECTRICIAN',
    EmployeeRole.attendant: 'ATTENDANT',
    EmployeeRole.manager: 'MANAGER',
  };

  final ApiClient _api;

  ApiEmployeeService({required ApiClient api}) : _api = api;

  @override
  Future<List<Employee>> fetchAll() async {
    final json = await _api.get('/employees') as List<dynamic>;

    return json
        .map((item) => _fromApi(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<Employee> create(Employee employee) async {
    final json = await _api.post('/employees', body: {
      'name': employee.name,
      'document': employee.document,
      'email': employee.email,
      'phone': employee.phone,
      'jobTitle': _roleToApi[employee.role],
      'address': employee.address.isEmpty
          ? null
          : ApiMappers.addressToApi(employee.address),
    }) as Map<String, dynamic>;

    return _fromApi(json);
  }

  @override
  Future<Employee> update(Employee employee) async {
    final json = await _api.put('/employees/${employee.id}', body: {
      'name': employee.name,
      'phone': employee.phone,
      'jobTitle': _roleToApi[employee.role],
      'address': employee.address.isEmpty
          ? null
          : ApiMappers.addressToApi(employee.address),
    }) as Map<String, dynamic>;

    return _fromApi(json);
  }

  @override
  Future<void> delete(String id) {
    return _api.delete('/employees/$id');
  }

  Employee _fromApi(Map<String, dynamic> json) {
    final apiRole = json['jobTitle']?.toString();

    final role = _roleToApi.entries
        .firstWhere(
          (entry) => entry.value == apiRole,
          orElse: () => const MapEntry(EmployeeRole.mechanic, 'MECHANIC'),
        )
        .key;

    return Employee(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? '',
      document: json['document']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: role,
      address: ApiMappers.addressFromApi(
        json['address'] as Map<String, dynamic>?,
      ),
    );
  }
}
