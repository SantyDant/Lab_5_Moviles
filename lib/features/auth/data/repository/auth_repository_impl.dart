import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import 'package:moviles_auth/features/auth/data/source/supabase_auth_data_source.dart';
import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';

/// Implementa [AuthRepository] con Supabase y traduce sus errores.
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dataSource.signUp(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('No se pudo crear la cuenta');
      }
      // Sin sesión no se puede escribir en `profiles` (RLS). Pasa cuando el
      // proyecto de Supabase exige confirmar el correo.
      if (response.session == null) {
        throw const AuthFailure(
          'Confirma tu correo antes de continuar, o desactiva '
          '"Confirm email" en Supabase (Authentication > Sign In / Providers)',
        );
      }
      return AuthUser(id: user.id, email: user.email ?? email);
    } on AuthException catch (e) {
      throw AuthFailure(_translate(e));
    }
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dataSource.signIn(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthFailure('No se pudo iniciar sesión');
      }
      return AuthUser(id: user.id, email: user.email ?? email);
    } on AuthException catch (e) {
      throw AuthFailure(_translate(e));
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _dataSource.signOut();
    } on AuthException catch (e) {
      throw AuthFailure(_translate(e));
    }
  }

  String _translate(AuthException e) {
    final text = e.message.toLowerCase();
    if (text.contains('invalid login credentials')) {
      return 'Correo o contraseña incorrectos';
    }
    if (text.contains('already registered') || text.contains('already exists')) {
      return 'Ya existe una cuenta con ese correo';
    }
    if (text.contains('email not confirmed')) {
      return 'Debes confirmar tu correo antes de iniciar sesión';
    }
    if (text.contains('password')) {
      return 'La contraseña no cumple los requisitos: ${e.message}';
    }
    return 'Error de autenticación: ${e.message}';
  }
}
