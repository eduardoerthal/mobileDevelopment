import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/character.dart';
import '../models/character_page.dart';
import 'api_exception.dart';

/// Talks to the public Rick and Morty API (https://rickandmortyapi.com/api).
///
/// Every method throws an [ApiException] with a user-friendly message when
/// the request fails — network issues, non-200 status codes, or a response
/// body that can't be parsed. Callers only need to catch [ApiException].
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _baseUrl = 'https://rickandmortyapi.com/api';

  /// Fetches one page of characters (20 per page, per the API).
  ///
  /// Returns a [CharacterPage] with the results plus [PageInfo],
  /// which exposes whether a next page exists via `info.hasNextPage`
  /// and `info.nextPage`.
  Future<CharacterPage> fetchCharacters(int page) async {
    final uri = Uri.parse(
      '$_baseUrl/character',
    ).replace(queryParameters: {'page': '$page'});

    final response = await _get(uri);
    if (response.statusCode != 200) {
      throw _exceptionForStatus(
        response.statusCode,
        notFoundMessage: 'Nenhum personagem encontrado nesta página.',
      );
    }
    return CharacterPage.fromJson(_decodeObject(response));
  }

  /// Fetches a single character by its numeric [id].
  Future<Character> fetchCharacterById(int id) async {
    final uri = Uri.parse('$_baseUrl/character/$id');

    final response = await _get(uri);
    if (response.statusCode != 200) {
      throw _exceptionForStatus(
        response.statusCode,
        notFoundMessage: 'Personagem com id $id não foi encontrado.',
      );
    }
    return Character.fromJson(_decodeObject(response));
  }

  /// Searches characters whose name contains [name] (case-insensitive,
  /// same matching rules as the API's `?name=` filter).
  ///
  /// Returns an empty list when nothing matches, instead of throwing —
  /// the API itself responds with 404 in that case, which is treated
  /// here as "no results", not as an error.
  Future<List<Character>> searchCharacters(String name) async {
    final uri = Uri.parse(
      '$_baseUrl/character',
    ).replace(queryParameters: {'name': name});

    final response = await _get(uri);
    if (response.statusCode == 404) {
      return const [];
    }
    if (response.statusCode != 200) {
      throw _exceptionForStatus(response.statusCode);
    }
    return CharacterPage.fromJson(_decodeObject(response)).results;
  }

  /// Performs the GET request, translating network-level failures into
  /// [ApiException]. HTTP status codes are left for callers to inspect
  /// on the returned [http.Response].
  Future<http.Response> _get(Uri uri) async {
    try {
      return await _client.get(uri);
    } on SocketException {
      throw const ApiException(
        'Sem conexão com a internet. Verifique sua rede e tente novamente.',
      );
    } on HttpException {
      throw const ApiException(
        'Não foi possível se comunicar com o servidor. Tente novamente.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Não foi possível se comunicar com o servidor. Tente novamente.',
      );
    } catch (_) {
      throw const ApiException(
        'Ocorreu um erro inesperado ao buscar os dados. Tente novamente.',
      );
    }
  }

  /// Decodes a 200 response body as a JSON object.
  Map<String, dynamic> _decodeObject(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw const ApiException('Resposta inválida recebida do servidor.');
    }
  }

  ApiException _exceptionForStatus(int statusCode, {String? notFoundMessage}) {
    if (statusCode == 404) {
      return ApiException(notFoundMessage ?? 'Recurso não encontrado.');
    }
    if (statusCode >= 500) {
      return const ApiException(
        'O servidor da Rick and Morty API está indisponível no momento. '
        'Tente novamente mais tarde.',
      );
    }
    return ApiException(
      'Erro ao buscar dados (código $statusCode). Tente novamente.',
    );
  }

  /// Releases the underlying HTTP client. Call when this service's
  /// owner (e.g. a Provider) is disposed.
  void dispose() => _client.close();
}
