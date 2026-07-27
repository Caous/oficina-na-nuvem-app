import '../../models/fipe_reference.dart';

/// Consulta à Tabela FIPE.
///
/// A implementação atual é mock; ao integrar a API real basta fornecer outra
/// implementação desta interface, sem tocar em repositório, view model ou UI.
abstract class FipeService {
  Future<List<FipeBrand>> fetchBrands();

  Future<List<FipeModel>> fetchModelsOf(String brandCode);

  Future<List<FipeYear>> fetchYearsOf(String modelCode);

  /// Consulta o valor de referência para a combinação selecionada.
  Future<FipeQuote> fetchQuote({
    required String brandCode,
    required String modelCode,
    required String yearCode,
  });
}
