import 'package:flutter/foundation.dart';

import '../../../client_home/data/repositories/client_garage_repository.dart';
import '../../data/repositories/customer_repository.dart';
import '../../models/fipe_reference.dart';
import '../../models/vehicle.dart';

/// Cadastro de veículos logo após o registro do cliente (tela 19 do design).
///
/// O cliente escolhe o tipo (carro, moto, caminhão, utilitário, jet ski ou
/// aeronave) e adiciona quantos veículos quiser antes de seguir para a home.
/// Tipos cobertos pela FIPE usam a cascata marca → modelo → ano; os demais
/// (jet ski, aeronave) são preenchidos manualmente.
class VehicleOnboardingViewModel extends ChangeNotifier {
  final CustomerRepository _fipeRepository;
  final ClientGarageRepository _garageRepository;

  VehicleOnboardingViewModel({
    required CustomerRepository fipeRepository,
    required ClientGarageRepository garageRepository,
  }) : _fipeRepository = fipeRepository,
       _garageRepository = garageRepository;

  /// Dono dos veículos criados neste fluxo (o cliente autenticado, no mock).
  static const String _ownerId = 'me';

  VehicleType _selectedType = VehicleType.car;

  List<FipeBrand> _brands = const [];
  List<FipeModel> _models = const [];
  List<FipeYear> _years = const [];

  FipeBrand? _selectedBrand;
  FipeModel? _selectedModel;
  FipeYear? _selectedYear;
  FipeQuote? _quote;

  final List<Vehicle> _addedVehicles = [];

  bool _isLoadingBrands = false;
  bool _isLoadingModels = false;
  bool _isLoadingYears = false;
  bool _isSaving = false;
  String? _errorMessage;

  VehicleType get selectedType => _selectedType;

  List<FipeBrand> get brands => _brands;
  List<FipeModel> get models => _models;
  List<FipeYear> get years => _years;

  FipeBrand? get selectedBrand => _selectedBrand;
  FipeModel? get selectedModel => _selectedModel;
  FipeYear? get selectedYear => _selectedYear;

  List<Vehicle> get addedVehicles => List.unmodifiable(_addedVehicles);

  bool get isLoadingBrands => _isLoadingBrands;
  bool get isLoadingModels => _isLoadingModels;
  bool get isLoadingYears => _isLoadingYears;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  /// O passo só é concluído com pelo menos um veículo (há o "pular" à parte).
  bool get canFinish => _addedVehicles.isNotEmpty && !_isSaving;

  Future<void> loadBrands() async {
    _isLoadingBrands = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _brands = await _fipeRepository.fetchBrands();
    } catch (_) {
      _errorMessage = 'Não foi possível carregar as marcas.';
    } finally {
      _isLoadingBrands = false;
      notifyListeners();
    }
  }

  /// Trocar o tipo zera a seleção FIPE — os catálogos não se misturam.
  void selectType(VehicleType type) {
    if (type == _selectedType) {
      return;
    }

    _selectedType = type;
    _selectedBrand = null;
    _selectedModel = null;
    _selectedYear = null;
    _models = const [];
    _years = const [];
    _quote = null;
    _errorMessage = null;
    notifyListeners();
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
      _models = await _fipeRepository.fetchModelsOf(brand.code);
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
      _years = await _fipeRepository.fetchYearsOf(model.code);
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
    notifyListeners();

    try {
      _quote = await _fipeRepository.fetchQuote(
        brandCode: brand.code,
        modelCode: model.code,
        yearCode: year.code,
      );
    } catch (_) {
      // Sem cotação o veículo ainda pode ser adicionado; o valor fica zerado.
    } finally {
      notifyListeners();
    }
  }

  /// Adiciona o veículo montado a partir da FIPE ou dos campos manuais.
  ///
  /// Para tipos FIPE, [manualBrand]/[manualModel]/[manualYear] são ignorados;
  /// para os demais, são obrigatórios.
  Future<bool> addVehicle({
    required String plate,
    String manualBrand = '',
    String manualModel = '',
    String manualYear = '',
  }) async {
    final vehicle = _buildVehicle(
      plate: plate,
      manualBrand: manualBrand,
      manualModel: manualModel,
      manualYear: manualYear,
    );

    if (vehicle == null) {
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await _garageRepository.addVehicle(vehicle);

      _addedVehicles.add(created);
      _resetSelectionKeepingType();

      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível adicionar o veículo.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Vehicle? _buildVehicle({
    required String plate,
    required String manualBrand,
    required String manualModel,
    required String manualYear,
  }) {
    if (_selectedType.supportsFipe) {
      final brand = _selectedBrand;
      final model = _selectedModel;
      final year = _selectedYear;

      if (brand == null || model == null || year == null) {
        _errorMessage = 'Selecione marca, modelo e ano do veículo.';
        return null;
      }

      return Vehicle(
        id: '',
        customerId: _ownerId,
        type: _selectedType,
        brand: _quote?.brandName ?? brand.name,
        model: _quote?.modelName ?? model.name,
        year: _quote?.yearLabel ?? year.label,
        plate: plate.trim().toUpperCase(),
        fipeCode: _quote?.fipeCode ?? '',
        fipeValue: _quote?.value ?? 0,
      );
    }

    if (manualBrand.trim().isEmpty ||
        manualModel.trim().isEmpty ||
        manualYear.trim().isEmpty) {
      _errorMessage = 'Preencha marca, modelo e ano do veículo.';
      return null;
    }

    return Vehicle(
      id: '',
      customerId: _ownerId,
      type: _selectedType,
      brand: manualBrand.trim(),
      model: manualModel.trim(),
      year: manualYear.trim(),
      plate: plate.trim().toUpperCase(),
      fipeCode: '',
      fipeValue: 0,
    );
  }

  void _resetSelectionKeepingType() {
    _selectedBrand = null;
    _selectedModel = null;
    _selectedYear = null;
    _models = const [];
    _years = const [];
    _quote = null;
  }

  Future<bool> removeVehicle(String id) async {
    try {
      await _garageRepository.removeVehicle(id);
      _addedVehicles.removeWhere((vehicle) => vehicle.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      _errorMessage = 'Não foi possível remover o veículo.';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
