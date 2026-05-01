import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/auth_config.dart';

class AuthService {
  AuthService();

  bool get isConfigured => AuthConfig.hasSupabaseConfig;

  SupabaseClient get _client {
    _ensureSupabaseConfigured();
    return Supabase.instance.client;
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _validateEmailPassword(email: email, password: password);

    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<Session?> createAccount({
    required String email,
    required String password,
  }) async {
    _validateEmailPassword(email: email, password: password);

    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );
    return response.session;
  }

  Future<void> signInWithGoogle() async {
    _ensureSupabaseConfigured();

    final opened = await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: AuthConfig.oauthRedirectUrl,
      scopes: 'email profile',
    );

    if (!opened) {
      throw const AuthSetupException('Could not open Google sign-in.');
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  void _ensureSupabaseConfigured() {
    if (!AuthConfig.hasSupabaseConfig) {
      throw const AuthSetupException(
        'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY to .env.',
      );
    }
  }

  void _validateEmailPassword({
    required String email,
    required String password,
  }) {
    if (email.trim().isEmpty || !email.contains('@')) {
      throw const AuthSetupException('Enter a valid email address.');
    }
    if (password.length < 6) {
      throw const AuthSetupException(
        'Password should be at least 6 characters.',
      );
    }
  }
}

class AuthSetupException implements Exception {
  const AuthSetupException(this.message);

  final String message;

  @override
  String toString() => message;
}
