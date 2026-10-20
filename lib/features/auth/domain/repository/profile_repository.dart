import 'package:moviles_auth/features/auth/domain/entities/profile.dart';

/// Contrato para guardar y leer perfiles de usuario.
abstract class ProfileRepository {
  Future<void> createProfile(Profile profile);

  Future<Profile> getProfile(String userId);
}
