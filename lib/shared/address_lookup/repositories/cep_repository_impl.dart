import 'package:oficina_app/core/resilience/retry_policy.dart';
import 'package:oficina_app/shared/address_lookup/models/address.dart';
import 'package:oficina_app/shared/address_lookup/repositories/cep_repository.dart';
import 'package:oficina_app/shared/address_lookup/services/cep_service.dart';

/// Consulta de CEP protegida por política de repetição.
///
/// Uma instabilidade momentânea da rede não deve empurrar a pessoa direto para
/// o preenchimento manual: a política tenta de novo antes de desistir.
class CepRepositoryImpl implements CepRepository {
  final CepService _service;
  final RetryPolicy _retryPolicy;

  CepRepositoryImpl({
    required CepService service,
    RetryPolicy retryPolicy = const RetryPolicy(),
  }) : _service = service,
       _retryPolicy = retryPolicy;

  @override
  Future<Address?> findByCep(String cep) {
    return _retryPolicy.execute(() => _service.findByCep(cep));
  }
}
