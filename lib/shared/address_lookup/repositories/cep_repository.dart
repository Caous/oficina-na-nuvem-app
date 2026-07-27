import 'package:oficina_app/shared/address_lookup/models/address.dart';

/// Consulta de endereço a partir do CEP.
abstract interface class CepRepository {
  /// Retorna o endereço do CEP, ou `null` quando o CEP não existe.
  ///
  /// Lança em caso de falha de comunicação — cabe ao chamador oferecer o
  /// preenchimento manual.
  Future<Address?> findByCep(String cep);
}
