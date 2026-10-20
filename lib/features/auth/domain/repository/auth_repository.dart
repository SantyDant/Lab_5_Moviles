import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';

/// Contrato de autenticación. La capa de datos decide cómo se implementa.
abstract class AuthRepository {
  /// Crea la cuenta y devuelve el usuario con sesión iniciada.
  Future<AuthUser> signUp({required String email, required String password});

  /// Inicia sesión con correo y contraseña.
  Future<AuthUser> signIn({required String email, required String password});

  /// Cierra la sesión actual.
  Future<void> signOut();
}
