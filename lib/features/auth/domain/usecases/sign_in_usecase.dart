import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';

/// Inicia sesión y devuelve el perfil del usuario para mostrarlo en Home.
class SignInUseCase {
  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;

  SignInUseCase(this._authRepository, this._profileRepository);

  Future<Profile> call({
    required String email,
    required String password,
  }) async {
    final user = await _authRepository.signIn(email: email, password: password);
    return _profileRepository.getProfile(user.id);
  }
}
