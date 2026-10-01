/// Public Supabase client config (anon key is safe for client apps).
/// Prefer `--dart-define=SUPABASE_URL=...` and `SUPABASE_ANON_KEY=...` at build time.
class SupabaseConfig {
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://awoliraufydoeaoorutm.supabase.co',
  );

  static const String anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImF3b2xpcmF1Znlkb2Vhb29ydXRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA4ODk2NTAsImV4cCI6MjEwNjQ2NTY1MH0.O003o2xX-sqbzVKoh2r5bQ_nI2iF1rv47Nim6e0Lt9c',
  );

  static const String projectRef = 'awoliraufydoeaoorutm';

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
