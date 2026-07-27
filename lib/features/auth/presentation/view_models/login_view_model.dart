import 'package:flutter/foundation.dart';

import '../../data/repositories/auth_repository.dart';
import '../../models/user.dart';

/// Estado da tela de login.
class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel({required AuthRepository authRepository})
    : _authRepository = authRepository;

  bool _isLoading = false;
  String? _errorMessage;
  User? _userLogin;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get userLogin => _userLogin;

  Future<bool> login({required String email, required String pass}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authRepository.login(email: email, password: pass);

      if (user == null) {
        _errorMessage = 'E-mail ou senha inválidos.';
        return false;
      }

      _userLogin = user;
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível realizar o login.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
