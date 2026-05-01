import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/auth_config.dart';

class AuthService {
  AuthService();

  static bool _googleSignInInitialized = false;

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

    if (!AuthConfig.hasGoogleConfig) {
      throw const AuthSetupException(
        'Google sign-in needs GOOGLE_WEB_CLIENT_ID in .env.',
      );
    }

    if (!AuthConfig.hasValidGoogleWebClientId) {
      throw const AuthSetupException(
        'GOOGLE_WEB_CLIENT_ID should end with .apps.googleusercontent.com.',
      );
    }

    final googleSignIn = GoogleSignIn.instance;
    if (!_googleSignInInitialized) {
      await googleSignIn.initialize(
        clientId: AuthConfig.googleIosClientId.isEmpty
            ? null
            : AuthConfig.googleIosClientId,
        serverClientId: AuthConfig.googleWebClientId,
      );
      _googleSignInInitialized = true;
    }

    final googleAccount = await googleSignIn.authenticate();
    final googleAuth = googleAccount.authentication;
    final googleAuthorization = await googleAccount.authorizationClient
        .authorizationForScopes(const ['email', 'profile']);

    final idToken = googleAuth.idToken;
    final accessToken = googleAuthorization?.accessToken;

    if (idToken == null) {
      throw const AuthSetupException('Google did not return an ID token.');
    }
    if (accessToken == null) {
      throw const AuthSetupException('Google did not return an access token.');
    }

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  void _ensureSupabaseConfigured() {
    if (!AuthConfig.hasSupabaseConfig) {
      throw const AuthSetupException(
        'Supabase is not configured. Add SUPABASE_URL and SUPABASE_ANON_KEY with --dart-define.',
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
