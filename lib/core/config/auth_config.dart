import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthConfig {
  static const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const oauthRedirectUrl =
      'com.adityadas.productivitycoach://login-callback/';

  static String get supabaseUrl => _value(_supabaseUrl, 'SUPABASE_URL');

  static String get supabaseAnonKey =>
      _value(_supabaseAnonKey, 'SUPABASE_ANON_KEY');

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String _value(String dartDefineValue, String envKey) {
    if (dartDefineValue.isNotEmpty) {
      return dartDefineValue;
    }

    if (!dotenv.isInitialized) {
      return '';
    }

    return dotenv.env[envKey]?.trim() ?? '';
  }
}
