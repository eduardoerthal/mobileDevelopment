import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_exception.dart';
import '../providers/auth_provider.dart';

/// Login / local sign-up screen.
///
/// On success, [AuthProvider] updates its status and notifies listeners;
/// the app's root widget reacts to that and swaps this screen out for the
/// main one, so no manual navigation happens here.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegisterMode = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Informe um usuário.';
    if (trimmed.length < 3) return 'Mínimo de 3 caracteres.';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Informe uma senha.';
    if (password.length < 4) return 'Mínimo de 4 caracteres.';
    return null;
  }

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final auth = context.read<AuthProvider>();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      if (_isRegisterMode) {
        await auth.register(username: username, password: password);
      } else {
        await auth.login(username: username, password: password);
      }
      // On success the app root swaps this screen for the home screen.
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(
        () => _errorMessage = 'Ocorreu um erro inesperado. Tente novamente.',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _errorMessage = null;
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.travel_explore,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Rick and Morty Dex',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isRegisterMode
                          ? 'Crie sua conta local'
                          : 'Entre para continuar',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Usuário',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      enabled: !_isSubmitting,
                      validator: _validateUsername,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      enabled: !_isSubmitting,
                      validator: _validatePassword,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : Text(_isRegisterMode ? 'Cadastrar' : 'Entrar'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _isSubmitting ? null : _toggleMode,
                      child: Text(
                        _isRegisterMode
                            ? 'Já tem uma conta? Entrar'
                            : 'Não tem conta? Cadastre-se',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
