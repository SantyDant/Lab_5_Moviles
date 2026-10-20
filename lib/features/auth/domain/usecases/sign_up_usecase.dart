import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';

/// Registra un usuario: crea la cuenta en Auth y luego su fila en `profiles`.
class SignUpUseCase {
  static const minPasswordLength = 6;

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  SignUpUseCase(this._authRepository, this._profileRepository);

  Future<Profile> call({
    required String username,
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (!email.contains('@')) {
      throw const AuthFailure('Escribe un correo válido');
    }
    if (password.length < minPasswordLength) {
      throw const AuthFailure(
        'La contraseña debe tener al menos $minPasswordLength caracteres',
      );
    }

    // 1. Crear la cuenta en Supabase Auth.
    final user = await _authRepository.signUp(email: email, password: password);

    // 2. Guardar los datos del perfil con el id que asignó Auth.
    final profile = Profile(
      id: user.id,
      username: username,
      fullName: fullName,
      email: user.email,
    );
    await _profileRepository.createProfile(profile);
    return profile;
  }
}
