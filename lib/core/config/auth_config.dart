import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthConfig {
  static const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const _googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );
  static const _googleIosClientId = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
  );

  static String get supabaseUrl => _value(_supabaseUrl, 'SUPABASE_URL');

  static String get supabaseAnonKey =>
      _value(_supabaseAnonKey, 'SUPABASE_ANON_KEY');

  static String get googleWebClientId =>
      _value(_googleWebClientId, 'GOOGLE_WEB_CLIENT_ID');

  static String get googleIosClientId =>
      _value(_googleIosClientId, 'GOOGLE_IOS_CLIENT_ID');

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasGoogleConfig => googleWebClientId.isNotEmpty;

  static bool get hasValidGoogleWebClientId =>
      googleWebClientId.endsWith('.apps.googleusercontent.com');

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
