import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:moviles_auth/features/auth/data/source/supabase_profile_data_source.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';

/// Implementa [ProfileRepository] sobre la tabla `profiles`.
class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseProfileDataSource _dataSource;

  ProfileRepositoryImpl(this._dataSource);

  @override
  Future<void> createProfile(Profile profile) async {
    try {
      await _dataSource.insert({
        'id': profile.id,
        'username': profile.username,
        'full_name': profile.fullName,
        'email': profile.email,
      });
    } on PostgrestException catch (e) {
      throw AuthFailure('No se pudo guardar el perfil: ${e.message}');
    }
  }

  @override
  Future<Profile> getProfile(String userId) async {
    try {
      final row = await _dataSource.findById(userId);
      if (row == null) {
        throw const AuthFailure('No se encontró el perfil del usuario');
      }
      return Profile(
        id: row['id'] as String,
        username: row['username'] as String,
        fullName: row['full_name'] as String,
        email: row['email'] as String,
      );
    } on PostgrestException catch (e) {
      throw AuthFailure('No se pudo leer el perfil: ${e.message}');
    }
  }
}
