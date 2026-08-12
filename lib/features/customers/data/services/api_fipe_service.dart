import '../../../../core/network/api_client.dart';
import '../../models/fipe_reference.dart';
import 'fipe_service.dart';

/// Tabela FIPE via backend, que cacheia as respostas da API pública.
class ApiFipeService implements FipeService {
  final ApiClient _api;

  ApiFipeService({required ApiClient api}) : _api = api;

  @override
  Future<List<FipeBrand>> fetchBrands() async {
    final json = await _api.get('/fipe/brands') as List<dynamic>;

    return json
        .map(
          (item) => FipeBrand(
            code: item['code'].toString(),
            name: item['name'].toString(),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<FipeModel>> fetchModelsOf(String brandCode) async {
    final json = await _api.get(
      '/fipe/models',
      query: {'brandCode': brandCode},
    ) as List<dynamic>;

    return json
        .map(
          (item) => FipeModel(
            code: composeModelCode(brandCode, item['code'].toString()),
            brandCode: item['brandCode'].toString(),
            name: item['name'].toString(),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<FipeYear>> fetchYearsOf(String modelCode) async {
    final json = await _api.get(
      '/fipe/years',
      query: {'brandCode': _brandOf(modelCode), 'modelCode': _bareModel(modelCode)},
    ) as List<dynamic>;

    return json
        .map(
          (item) => FipeYear(
            code: item['code'].toString(),
            modelCode: modelCode,
            label: item['label'].toString(),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<FipeQuote> fetchQuote({
    required String brandCode,
    required String modelCode,
    required String yearCode,
  }) async {
    final json = await _api.get('/fipe/quote', query: {
      'brandCode': brandCode,
      'modelCode': _bareModel(modelCode),
      'yearCode': yearCode,
    }) as Map<String, dynamic>;

    return FipeQuote(
      brandName: json['brandName'].toString(),
      modelName: json['modelName'].toString(),
      yearLabel: json['yearLabel'].toString(),
      fipeCode: json['fipeCode'].toString(),
      value: (json['value'] as num).toDouble(),
    );
  }

  // A FIPE endereça anos por marca + modelo, mas a interface do app só carrega
  // o modelo. O código composto "marca:modelo" preserva os dois sem mudar a
  // interface; [fetchModelsOf] é quem o monta.
  static String composeModelCode(String brandCode, String modelCode) {
    return '$brandCode:$modelCode';
  }

  String _brandOf(String composedCode) {
    final parts = composedCode.split(':');
    return parts.length == 2 ? parts.first : '';
  }

  String _bareModel(String composedCode) {
    final parts = composedCode.split(':');
    return parts.length == 2 ? parts.last : composedCode;
  }
}
