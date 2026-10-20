import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';

/// Cierra la sesión del usuario actual.
class SignOutUseCase {
  final AuthRepository _authRepository;

  SignOutUseCase(this._authRepository);

  Future<void> call() => _authRepository.signOut();
}
