import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:oficina_app/shared/address_lookup/models/address.dart';
import 'package:oficina_app/shared/address_lookup/services/cep_service.dart';

class ViaCepService implements CepService {
  final http.Client _client;

  ViaCepService({required http.Client client}) : _client = client;

  @override
  Future<Address?> findByCep(String cep) async {
    final normalizedCep = cep.replaceAll(RegExp(r'\D'), '');

    if (normalizedCep.length != 8) {
      return null;
    }

    final uri = Uri.parse('https://viacep.com.br/ws/$normalizedCep/json/');

    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Erro ao consultar CEP: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    if (json['erro'] == true) {
      return null;
    }

    return Address(
      cep: json['cep']?.toString() ?? '',
      street: json['logradouro']?.toString() ?? '',
      complement: json['complemento']?.toString() ?? '',
      neighborhood: json['bairro']?.toString() ?? '',
      city: json['localidade']?.toString() ?? '',
      state: json['uf']?.toString() ?? '',
    );
  }
}
