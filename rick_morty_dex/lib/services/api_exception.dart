/// Exception thrown by [ApiService] when a request to the Rick and
/// Morty API fails — network failure, non-200 status code, or an
/// unparseable response. Carries a [message] already in user-friendly
/// (pt-BR) wording, suitable for showing directly in the UI.
class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}
