/// Exception thrown by [AuthProvider] on a failed login or registration
/// attempt, carrying a user-friendly (pt-BR) [message] to show in the UI.
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}
