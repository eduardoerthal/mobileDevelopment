import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_exception.dart';

/// Current phase of the local session lifecycle.
enum AuthStatus {
  /// Still reading persisted session state on startup.
  initializing,

  /// No active session — [LoginScreen] should be shown.
  unauthenticated,

  /// A user is logged in — the app's main screen should be shown.
  authenticated,
}

/// Simple **local-only** authentication, simulating register/login without
/// a backend: registered accounts and the active session are persisted with
/// [SharedPreferences] on-device.
///
/// NOTE: passwords are stored in plain text in local preferences. That is
/// acceptable for this local simulation but must never be done in a real
/// app talking to a server — real auth belongs behind a backend with
/// properly hashed/salted passwords.
class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _restoreSession();
  }

  static const _usersPrefsKey = 'auth_registered_users';
  static const _sessionPrefsKey = 'auth_session_username';

  AuthStatus _status = AuthStatus.initializing;
  AuthStatus get status => _status;

  bool get isInitializing => _status == AuthStatus.initializing;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  String? _currentUsername;
  String? get currentUsername => _currentUsername;

  /// Restores a previously active session, if any, on app startup.
  ///
  /// Never leaves [status] stuck at [AuthStatus.initializing]: if reading
  /// local storage fails for any reason, this falls back to
  /// [AuthStatus.unauthenticated] so the app still reaches [LoginScreen]
  /// instead of hanging on the startup spinner forever.
  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _currentUsername = prefs.getString(_sessionPrefsKey);
      _status = _currentUsername != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (error) {
      debugPrint('AuthProvider: failed to restore session: $error');
      _currentUsername = null;
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<Map<String, String>> _loadRegisteredUsers(
    SharedPreferences prefs,
  ) async {
    final raw = prefs.getString(_usersPrefsKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, value as String));
  }

  Future<void> _saveRegisteredUsers(
    SharedPreferences prefs,
    Map<String, String> users,
  ) {
    return prefs.setString(_usersPrefsKey, jsonEncode(users));
  }

  /// Registers a new local account and immediately starts a session for it.
  ///
  /// Throws [AuthException] when [username]/[password] are invalid or the
  /// username is already registered on this device.
  Future<void> register({
    required String username,
    required String password,
  }) async {
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty || password.isEmpty) {
      throw const AuthException('Usuário e senha não podem ficar em branco.');
    }
    if (normalizedUsername.length < 3) {
      throw const AuthException(
        'O usuário deve ter pelo menos 3 caracteres.',
      );
    }
    if (password.length < 4) {
      throw const AuthException('A senha deve ter pelo menos 4 caracteres.');
    }

    final prefs = await SharedPreferences.getInstance();
    final users = await _loadRegisteredUsers(prefs);
    final lookupKey = normalizedUsername.toLowerCase();

    if (users.containsKey(lookupKey)) {
      throw const AuthException('Este usuário já está cadastrado.');
    }

    users[lookupKey] = password;
    await _saveRegisteredUsers(prefs, users);
    await prefs.setString(_sessionPrefsKey, normalizedUsername);

    _currentUsername = normalizedUsername;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  /// Logs in with a previously registered [username]/[password].
  ///
  /// Throws [AuthException] when fields are blank, the username isn't
  /// registered, or the password doesn't match.
  Future<void> login({
    required String username,
    required String password,
  }) async {
    final normalizedUsername = username.trim();
    if (normalizedUsername.isEmpty || password.isEmpty) {
      throw const AuthException('Informe usuário e senha.');
    }

    final prefs = await SharedPreferences.getInstance();
    final users = await _loadRegisteredUsers(prefs);
    final lookupKey = normalizedUsername.toLowerCase();

    final storedPassword = users[lookupKey];
    if (storedPassword == null) {
      throw const AuthException(
        'Usuário não encontrado. Cadastre-se primeiro.',
      );
    }
    if (storedPassword != password) {
      throw const AuthException('Senha incorreta.');
    }

    await prefs.setString(_sessionPrefsKey, normalizedUsername);
    _currentUsername = normalizedUsername;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  /// Ends the active session. Registered accounts are kept, so the user
  /// can log in again later.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionPrefsKey);

    _currentUsername = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
