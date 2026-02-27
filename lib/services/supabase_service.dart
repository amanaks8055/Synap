// lib/services/supabase_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  // ── main.dart mein call karo ──────────────────────────────
  static Future<void> initialize() async {
    await Supabase.initialize(
      url:     'https://YOUR_PROJECT.supabase.co',  // ← replace karo
      anonKey: 'YOUR_ANON_KEY',                     // ← replace karo
    );
  }
}
