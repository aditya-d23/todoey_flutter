import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/productivity_coach_app.dart';
import 'core/config/auth_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env', isOptional: true);

  if (AuthConfig.hasSupabaseConfig) {
    await Supabase.initialize(
      url: AuthConfig.supabaseUrl,
      anonKey: AuthConfig.supabaseAnonKey,
    );
  }

  runApp(const ProductivityCoachApp());
}
