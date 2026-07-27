import 'package:oficina_app/shared/address_lookup/models/address.dart';

abstract interface class CepService {
  Future<Address?> findByCep(String cep);
}
