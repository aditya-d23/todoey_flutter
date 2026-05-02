import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/productivity_coach_app.dart';
import 'core/config/auth_config.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env', isOptional: true);

  // Initialize Firebase (required for Gemini AI)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (AuthConfig.hasSupabaseConfig) {
    await Supabase.initialize(
      url: AuthConfig.supabaseUrl,
      anonKey: AuthConfig.supabaseAnonKey,
    );
  }

  runApp(const ProductivityCoachApp());
}
