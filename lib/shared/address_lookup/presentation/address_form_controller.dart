import 'package:flutter/foundation.dart';

import '../models/address.dart';
import '../repositories/cep_repository.dart';

/// Situação da consulta de CEP.
enum AddressLookupStatus {
  /// CEP ainda não preenchido por completo.
  idle,

  /// Consulta em andamento (já inclui as repetições da política).
  searching,

  /// Endereço encontrado e campos preenchidos.
  found,

  /// CEP válido em formato, porém inexistente na base.
  notFound,

  /// Falha de comunicação após esgotar as tentativas.
  failed,

  /// Pessoa optou por digitar o endereço manualmente.
  manual,
}

/// Estado do bloco de endereço, compartilhado por cliente, oficina e
/// funcionário.
///
/// Quando a consulta falha, o formulário não trava: [status] passa a permitir
/// a digitação manual e a mensagem orienta a pessoa.
class AddressFormController extends ChangeNotifier {
  final CepRepository _repository;

  AddressFormController({required CepRepository repository, Address? initial})
    : _repository = repository,
      _address = initial ?? Address.empty;

  Address _address;
  AddressLookupStatus _status = AddressLookupStatus.idle;
  String? _message;

  Address get address => _address;
  AddressLookupStatus get status => _status;
  String? get message => _message;

  bool get isSearching => _status == AddressLookupStatus.searching;

  /// Campos de rua/bairro/cidade/UF ficam visíveis e editáveis assim que há
  /// um resultado ou quando a consulta não pôde ser concluída.
  bool get showsAddressFields =>
      _status == AddressLookupStatus.found ||
      _status == AddressLookupStatus.notFound ||
      _status == AddressLookupStatus.failed ||
      _status == AddressLookupStatus.manual ||
      !_address.isEmpty;

  /// Só bloqueamos a edição do que veio da consulta bem-sucedida.
  bool get lockLookupFields => _status == AddressLookupStatus.found;

  /// Houve problema e a pessoa precisa completar à mão.
  bool get needsManualEntry =>
      _status == AddressLookupStatus.failed ||
      _status == AddressLookupStatus.notFound;

  static String sanitizeCep(String? value) {
    return (value ?? '').replaceAll(RegExp(r'\D'), '');
  }

  /// Dispara a consulta quando o CEP fica completo.
  Future<void> onCepChanged(String value) async {
    final digits = sanitizeCep(value);

    _address = _address.copyWith(cep: value);

    if (digits.length < 8) {
      // Voltar a um CEP incompleto limpa o resultado anterior.
      if (_status != AddressLookupStatus.manual) {
        _status = AddressLookupStatus.idle;
        _message = null;
      }

      notifyListeners();
      return;
    }

    await search();
  }

  /// Consulta o CEP atual. Reutilizada pelo botão "Tentar novamente".
  Future<void> search() async {
    final digits = sanitizeCep(_address.cep);

    if (digits.length != 8) {
      _status = AddressLookupStatus.idle;
      _message = null;
      notifyListeners();
      return;
    }

    _status = AddressLookupStatus.searching;
    _message = null;
    notifyListeners();

    try {
      final found = await _repository.findByCep(digits);

      if (found == null) {
        _status = AddressLookupStatus.notFound;
        _message =
            'CEP não encontrado. Confira o número ou preencha o endereço '
            'manualmente.';
        notifyListeners();
        return;
      }

      // Número e complemento digitados são preservados.
      _address = found.copyWith(
        number: _address.number,
        complement: _address.complement.isNotEmpty
            ? _address.complement
            : found.complement,
      );
      _status = AddressLookupStatus.found;
      _message = null;
    } catch (_) {
      _status = AddressLookupStatus.failed;
      _message =
          'Não foi possível buscar o CEP agora. Preencha o endereço '
          'manualmente ou tente novamente.';
    } finally {
      notifyListeners();
    }
  }

  /// Libera a digitação manual, mantendo o que já foi preenchido.
  void enableManualEntry() {
    _status = AddressLookupStatus.manual;
    _message = null;
    notifyListeners();
  }

  void updateStreet(String value) => _update(_address.copyWith(street: value));

  void updateNumber(String value) => _update(_address.copyWith(number: value));

  void updateComplement(String value) =>
      _update(_address.copyWith(complement: value));

  void updateNeighborhood(String value) =>
      _update(_address.copyWith(neighborhood: value));

  void updateCity(String value) => _update(_address.copyWith(city: value));

  void updateState(String value) => _update(_address.copyWith(state: value));

  void _update(Address updated) {
    _address = updated;
    notifyListeners();
  }
}
