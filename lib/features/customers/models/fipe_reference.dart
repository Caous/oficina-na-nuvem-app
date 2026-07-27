/// Marca retornada pela Tabela FIPE.
class FipeBrand {
  final String code;
  final String name;

  const FipeBrand({required this.code, required this.name});
}

/// Modelo de uma marca na Tabela FIPE.
class FipeModel {
  final String code;
  final String brandCode;
  final String name;

  const FipeModel({
    required this.code,
    required this.brandCode,
    required this.name,
  });
}

/// Ano/combustível disponível para um modelo.
class FipeYear {
  final String code;
  final String modelCode;
  final String label;

  const FipeYear({
    required this.code,
    required this.modelCode,
    required this.label,
  });
}

/// Resultado da consulta FIPE para marca + modelo + ano.
class FipeQuote {
  final String brandName;
  final String modelName;
  final String yearLabel;
  final String fipeCode;
  final double value;

  const FipeQuote({
    required this.brandName,
    required this.modelName,
    required this.yearLabel,
    required this.fipeCode,
    required this.value,
  });

  String get fullName => '$brandName $modelName $yearLabel';
}
