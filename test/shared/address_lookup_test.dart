import 'package:flutter_test/flutter_test.dart';

import 'package:oficina_app/core/resilience/retry_policy.dart';
import 'package:oficina_app/shared/address_lookup/models/address.dart';
import 'package:oficina_app/shared/address_lookup/presentation/address_form_controller.dart';
import 'package:oficina_app/shared/address_lookup/repositories/cep_repository.dart';
import 'package:oficina_app/shared/address_lookup/repositories/cep_repository_impl.dart';
import 'package:oficina_app/shared/address_lookup/services/cep_service.dart';

/// Serviço de CEP controlável: falha as primeiras [failuresBeforeSuccess]
/// chamadas e conta quantas tentativas recebeu.
class _ScriptedCepService implements CepService {
  final int failuresBeforeSuccess;
  final Address? result;

  int callCount = 0;

  _ScriptedCepService({required this.failuresBeforeSuccess, this.result});

  @override
  Future<Address?> findByCep(String cep) async {
    callCount++;

    if (callCount <= failuresBeforeSuccess) {
      throw Exception('falha simulada #$callCount');
    }

    return result;
  }
}

const _sampleAddress = Address(
  cep: '01310-100',
  street: 'Avenida Paulista',
  complement: '',
  neighborhood: 'Bela Vista',
  city: 'São Paulo',
  state: 'SP',
);

RetryPolicy _fastPolicy() => const RetryPolicy(
  maxAttempts: 3,
  initialDelay: Duration(milliseconds: 1),
  attemptTimeout: null,
);

void main() {
  group('RetryPolicy', () {
    test('tenta 3 vezes antes de desistir', () async {
      var attempts = 0;

      await expectLater(
        _fastPolicy().execute(() async {
          attempts++;
          throw Exception('sempre falha');
        }),
        throwsException,
      );

      expect(attempts, 3);
    });

    test('para de tentar assim que a operação dá certo', () async {
      var attempts = 0;

      final result = await _fastPolicy().execute(() async {
        attempts++;

        if (attempts < 2) {
          throw Exception('falha uma vez');
        }

        return 'ok';
      });

      expect(result, 'ok');
      expect(attempts, 2);
    });

    test('não repete quando retryWhen recusa o erro', () async {
      var attempts = 0;

      final policy = RetryPolicy(
        maxAttempts: 3,
        initialDelay: const Duration(milliseconds: 1),
        attemptTimeout: null,
        retryWhen: (error) => false,
      );

      await expectLater(
        policy.execute(() async {
          attempts++;
          throw Exception('definitiva');
        }),
        throwsException,
      );

      expect(attempts, 1);
    });
  });

  group('CepRepositoryImpl', () {
    test('sucesso na terceira tentativa retorna o endereço', () async {
      final service = _ScriptedCepService(
        failuresBeforeSuccess: 2,
        result: _sampleAddress,
      );

      final repository = CepRepositoryImpl(
        service: service,
        retryPolicy: _fastPolicy(),
      );

      final found = await repository.findByCep('01310100');

      expect(found?.street, 'Avenida Paulista');
      expect(service.callCount, 3);
    });

    test('falha nas 3 tentativas propaga o erro', () async {
      final service = _ScriptedCepService(failuresBeforeSuccess: 99);

      final repository = CepRepositoryImpl(
        service: service,
        retryPolicy: _fastPolicy(),
      );

      await expectLater(repository.findByCep('01310100'), throwsException);
      expect(service.callCount, 3);
    });
  });

  group('AddressFormController', () {
    CepRepository repositoryWith(_ScriptedCepService service) {
      return CepRepositoryImpl(service: service, retryPolicy: _fastPolicy());
    }

    test('CEP completo dispara a busca e preenche o endereço', () async {
      final controller = AddressFormController(
        repository: repositoryWith(
          _ScriptedCepService(failuresBeforeSuccess: 0, result: _sampleAddress),
        ),
      );

      await controller.onCepChanged('01310-100');

      expect(controller.status, AddressLookupStatus.found);
      expect(controller.address.city, 'São Paulo');
      expect(controller.lockLookupFields, isTrue);
    });

    test('falha após as tentativas libera a digitação manual', () async {
      final controller = AddressFormController(
        repository: repositoryWith(
          _ScriptedCepService(failuresBeforeSuccess: 99),
        ),
      );

      await controller.onCepChanged('01310-100');

      expect(controller.status, AddressLookupStatus.failed);
      expect(controller.message, contains('Preencha o endereço'));
      expect(controller.showsAddressFields, isTrue);
      expect(controller.lockLookupFields, isFalse);
    });

    test('CEP inexistente orienta a conferência', () async {
      final controller = AddressFormController(
        repository: repositoryWith(
          _ScriptedCepService(failuresBeforeSuccess: 0, result: null),
        ),
      );

      await controller.onCepChanged('99999-999');

      expect(controller.status, AddressLookupStatus.notFound);
      expect(controller.message, contains('CEP não encontrado'));
    });

    test('número digitado sobrevive à consulta do CEP', () async {
      final controller = AddressFormController(
        repository: repositoryWith(
          _ScriptedCepService(failuresBeforeSuccess: 0, result: _sampleAddress),
        ),
      );

      controller.updateNumber('1000');
      await controller.onCepChanged('01310-100');

      expect(controller.address.number, '1000');
      expect(controller.address.street, 'Avenida Paulista');
    });
  });
}
