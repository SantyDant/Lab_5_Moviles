/// Credenciales del proyecto de Supabase.
///
/// Se pueden cambiar sin tocar el código al ejecutar:
/// flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_KEY=...
///
/// Si no se pasan, se usan los valores del proyecto del curso.
class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://pmijmrkaucdwadmnnvbo.supabase.co',
  );

  static const publishableKey = String.fromEnvironment(
    'SUPABASE_KEY',
    defaultValue: 'sb_publishable_8tS9o_mjkvKA4z9WUvRjCg_01oNcv6y',
  );
}
