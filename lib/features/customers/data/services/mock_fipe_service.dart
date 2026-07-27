import '../../models/fipe_reference.dart';
import 'fipe_service.dart';

/// Implementação mock da Tabela FIPE.
///
/// A lista de marcas é propositalmente longa para exercitar a busca por
/// digitação exigida no design.
class MockFipeService implements FipeService {
  static const Duration _latency = Duration(milliseconds: 400);

  static const List<String> _brandNames = [
    'Audi',
    'BMW',
    'BYD',
    'Caoa Chery',
    'Chevrolet',
    'Citroën',
    'Fiat',
    'Ford',
    'GWM',
    'Honda',
    'Hyundai',
    'Jeep',
    'Kia',
    'Land Rover',
    'Mercedes-Benz',
    'Mitsubishi',
    'Nissan',
    'Peugeot',
    'Volkswagen',
    'Volvo',
    'Renault',
    'Suzuki',
    'Toyota',
    'RAM',
  ];

  /// Modelos por nome de marca. Marcas sem entrada usam [_genericModels].
  static const Map<String, List<String>> _modelsByBrand = {
    'Honda': [
      'Civic 2.0 EXL 16V',
      'Civic 1.5 Touring Turbo',
      'City 1.5 EX',
      'Fit 1.5 EXL',
      'HR-V 1.8 EXL',
      'WR-V 1.5 EX',
    ],
    'Volkswagen': [
      'Gol 1.0 MPI',
      'Polo 1.0 200 TSI',
      'T-Cross 1.0 200 TSI',
      'Nivus 1.0 200 TSI',
      'Virtus 1.6 MSI',
    ],
    'Fiat': [
      'Argo 1.0 Drive',
      'Mobi 1.0 Like',
      'Cronos 1.3 Drive',
      'Toro 1.3 Turbo 270',
      'Strada 1.4 Endurance',
    ],
    'Chevrolet': [
      'Onix 1.0 LT',
      'Onix Plus 1.0 Turbo LTZ',
      'Tracker 1.0 Turbo',
      'Spin 1.8 LTZ',
      'S10 2.8 LTZ 4x4',
    ],
    'Toyota': [
      'Corolla 2.0 XEi',
      'Corolla Cross 1.8 XRE Hybrid',
      'Yaris 1.5 XLS',
      'Hilux 2.8 SRV 4x4',
    ],
    'Hyundai': [
      'HB20 1.0 Comfort',
      'HB20S 1.0 Turbo Evolution',
      'Creta 1.0 Turbo Comfort',
      'Tucson 1.6 GLS',
    ],
  };

  static const List<String> _genericModels = [
    '1.0 Entrada',
    '1.6 Intermediário',
    '2.0 Completo',
  ];

  static const List<String> _yearLabels = [
    '2024 Gasolina',
    '2023 Gasolina',
    '2022 Flex',
    '2021 Flex',
    '2020 Gasolina',
    '2019 Flex',
    '2018 Flex',
  ];

  @override
  Future<List<FipeBrand>> fetchBrands() async {
    await Future<void>.delayed(_latency);

    final sorted = [..._brandNames]..sort();

    return [
      for (final (index, name) in sorted.indexed)
        FipeBrand(code: 'B${index + 1}', name: name),
    ];
  }

  @override
  Future<List<FipeModel>> fetchModelsOf(String brandCode) async {
    await Future<void>.delayed(_latency);

    final brandName = await _brandNameOf(brandCode);
    final models = _modelsByBrand[brandName] ?? _genericModels;

    return [
      for (final (index, name) in models.indexed)
        FipeModel(
          code: '$brandCode-M${index + 1}',
          brandCode: brandCode,
          name: name,
        ),
    ];
  }

  @override
  Future<List<FipeYear>> fetchYearsOf(String modelCode) async {
    await Future<void>.delayed(_latency);

    return [
      for (final (index, label) in _yearLabels.indexed)
        FipeYear(
          code: '$modelCode-Y${index + 1}',
          modelCode: modelCode,
          label: label,
        ),
    ];
  }

  @override
  Future<FipeQuote> fetchQuote({
    required String brandCode,
    required String modelCode,
    required String yearCode,
  }) async {
    await Future<void>.delayed(_latency);

    final brandName = await _brandNameOf(brandCode);

    final models = await fetchModelsOf(brandCode);
    final model = models.firstWhere(
      (candidate) => candidate.code == modelCode,
      orElse: () => throw StateError('Modelo $modelCode não encontrado.'),
    );

    final years = await fetchYearsOf(modelCode);
    final year = years.firstWhere(
      (candidate) => candidate.code == yearCode,
      orElse: () => throw StateError('Ano $yearCode não encontrado.'),
    );

    return FipeQuote(
      brandName: brandName,
      modelName: model.name,
      yearLabel: year.label,
      fipeCode: _fipeCodeFor(modelCode),
      value: _valueFor(modelCode: modelCode, yearLabel: year.label),
    );
  }

  Future<String> _brandNameOf(String brandCode) async {
    final brands = await fetchBrands();

    return brands
        .firstWhere(
          (brand) => brand.code == brandCode,
          orElse: () => throw StateError('Marca $brandCode não encontrada.'),
        )
        .name;
  }

  /// Código FIPE determinístico, no formato `######-#`.
  String _fipeCodeFor(String modelCode) {
    final base = modelCode.hashCode.abs() % 1000000;
    final digit = base % 10;

    return '${base.toString().padLeft(6, '0')}-$digit';
  }

  /// Valor determinístico e plausível: modelos mais novos valem mais.
  double _valueFor({required String modelCode, required String yearLabel}) {
    final modelYear = int.tryParse(yearLabel.substring(0, 4)) ?? 2020;
    final base = 45000 + (modelCode.hashCode.abs() % 90000);
    final depreciation = (2025 - modelYear) * 4500;
    final value = (base - depreciation).clamp(18000, 400000);

    return value.toDouble();
  }
}
