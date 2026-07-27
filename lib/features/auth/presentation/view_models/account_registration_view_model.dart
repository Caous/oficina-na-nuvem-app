import 'package:flutter/material.dart';
import 'package:oficina_app/features/auth/data/repositories/account_registration_repository.dart';
import 'package:oficina_app/features/auth/models/account_registration.dart';
import 'package:oficina_app/shared/address_lookup/models/address.dart';
import 'package:oficina_app/features/auth/models/user.dart';

const _genericErrorMessage = 'Não foi possível concluir o cadastro.';

/// Estado e regras de apresentação das telas de cadastro (cliente/oficina).
class AccountRegistrationViewModel extends ChangeNotifier {
  final AccountRegistrationRepository _repository;

  AccountRegistrationViewModel({
    required AccountRegistrationRepository repository,
  }) : _repository = repository;

  AccountType _accountType = AccountType.client;
  bool _isSubmitting = false;
  String? _errorMessage;
  User? _registeredUser;

  AccountType get accountType => _accountType;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  User? get registeredUser => _registeredUser;

  void selectAccountType(AccountType type) {
    _accountType = type;
    notifyListeners();
  }

  Future<bool> submitClient({
    required String name,
    required String document,
    required String email,
    required String phone,
    required Address address,
    required String password,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _registeredUser = await _repository.registerClient(
        ClientRegistration(
          name: name,
          document: document,
          email: email,
          phone: phone,
          address: address,
          password: password,
        ),
      );

      return true;
    } on ArgumentError catch (error) {
      _errorMessage = error.message.toString();
      return false;
    } catch (_) {
      _errorMessage = _genericErrorMessage;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> submitWorkshop({
    required String tradeName,
    required String document,
    required String email,
    required String phone,
    required Address address,
    required String password,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _registeredUser = await _repository.registerWorkshop(
        WorkshopRegistration(
          tradeName: tradeName,
          document: document,
          email: email,
          phone: phone,
          address: address,
          password: password,
        ),
      );

      return true;
    } on ArgumentError catch (error) {
      _errorMessage = error.message.toString();
      return false;
    } catch (_) {
      _errorMessage = _genericErrorMessage;
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
