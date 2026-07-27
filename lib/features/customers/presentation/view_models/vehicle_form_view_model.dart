import 'package:flutter/foundation.dart';

import '../../data/repositories/customer_repository.dart';
import '../../models/fipe_reference.dart';
import '../../models/vehicle.dart';

/// Cadastro de veículo guiado pela Tabela FIPE.
///
/// A seleção é encadeada: escolher uma marca recarrega os modelos e limpa
/// modelo, ano e cotação; escolher um modelo recarrega os anos e limpa o
/// restante. Isso impede que a tela exiba uma combinação inconsistente.
class VehicleFormViewModel extends ChangeNotifier {
  final CustomerRepository _repository;
  final String customerId;
  final String customerName;

  VehicleFormViewModel({
    required CustomerRepository repository,
    required this.customerId,
    required this.customerName,
  }) : _repository = repository;

  List<FipeBrand> _brands = const [];
  List<FipeModel> _models = const [];
  List<FipeYear> _years = const [];

  FipeBrand? _selectedBrand;
  FipeModel? _selectedModel;
  FipeYear? _selectedYear;
  FipeQuote? _quote;

  bool _isLoadingBrands = false;
  bool _isLoadingModels = false;
  bool _isLoadingYears = false;
  bool _isLoadingQuote = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<FipeBrand> get brands => _brands;
  List<FipeModel> get models => _models;
  List<FipeYear> get years => _years;

  FipeBrand? get selectedBrand => _selectedBrand;
  FipeModel? get selectedModel => _selectedModel;
  FipeYear? get selectedYear => _selectedYear;
  FipeQuote? get quote => _quote;

  bool get isLoadingBrands => _isLoadingBrands;
  bool get isLoadingModels => _isLoadingModels;
  bool get isLoadingYears => _isLoadingYears;
  bool get isLoadingQuote => _isLoadingQuote;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  /// O formulário só pode ser salvo com a cotação FIPE já resolvida.
  bool get canSubmit => _quote != null && !_isSaving;

  Future<void> loadBrands() async {
    _isLoadingBrands = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _brands = await _repository.fetchBrands();
    } catch (_) {
      _errorMessage = 'Não foi possível carregar as marcas.';
    } finally {
      _isLoadingBrands = false;
      notifyListeners();
    }
  }

  Future<void> selectBrand(FipeBrand brand) async {
    _selectedBrand = brand;
    _selectedModel = null;
    _selectedYear = null;
    _models = const [];
    _years = const [];
    _quote = null;
    _isLoadingModels = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _models = await _repository.fetchModelsOf(brand.code);
    } catch (_) {
      _errorMessage = 'Não foi possível carregar os modelos.';
    } finally {
      _isLoadingModels = false;
      notifyListeners();
    }
  }

  Future<void> selectModel(FipeModel model) async {
    _selectedModel = model;
    _selectedYear = null;
    _years = const [];
    _quote = null;
    _isLoadingYears = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _years = await _repository.fetchYearsOf(model.code);
    } catch (_) {
      _errorMessage = 'Não foi possível carregar os anos.';
    } finally {
      _isLoadingYears = false;
      notifyListeners();
    }
  }

  Future<void> selectYear(FipeYear year) async {
    final brand = _selectedBrand;
    final model = _selectedModel;

    if (brand == null || model == null) {
      return;
    }

    _selectedYear = year;
    _quote = null;
    _isLoadingQuote = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _quote = await _repository.fetchQuote(
        brandCode: brand.code,
        modelCode: model.code,
        yearCode: year.code,
      );
    } catch (_) {
      _errorMessage = 'Não foi possível consultar o valor FIPE.';
    } finally {
      _isLoadingQuote = false;
      notifyListeners();
    }
  }

  /// Salva o veículo. Retorna o registro criado, ou `null` em caso de falha.
  Future<Vehicle?> save({required String plate}) async {
    final quote = _quote;

    if (quote == null) {
      _errorMessage = 'Selecione marca, modelo e ano antes de salvar.';
      notifyListeners();
      return null;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _repository.createVehicle(
        Vehicle(
          id: '',
          customerId: customerId,
          brand: quote.brandName,
          model: quote.modelName,
          year: quote.yearLabel,
          plate: plate.trim().toUpperCase(),
          fipeCode: quote.fipeCode,
          fipeValue: quote.value,
        ),
      );
    } catch (_) {
      _errorMessage = 'Não foi possível salvar o veículo.';
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
