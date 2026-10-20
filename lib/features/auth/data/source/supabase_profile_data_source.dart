import 'package:supabase_flutter/supabase_flutter.dart';

/// Lee y escribe la tabla `profiles` de Supabase.
class SupabaseProfileDataSource {
  static const _table = 'profiles';

  final SupabaseClient _client;

  SupabaseProfileDataSource(this._client);

  Future<void> insert(Map<String, dynamic> row) async {
    await _client.from(_table).insert(row);
  }

  Future<Map<String, dynamic>?> findById(String id) {
    return _client.from(_table).select().eq('id', id).maybeSingle();
  }
}
