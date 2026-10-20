import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';
import 'package:moviles_auth/main.dart';

/// Auth en memoria: guarda correo -> contraseña.
class FakeAuthRepository implements AuthRepository {
  final _users = <String, String>{};

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    if (_users.containsKey(email)) {
      throw const AuthFailure('Ya existe una cuenta con ese correo');
    }
    _users[email] = password;
    return AuthUser(id: 'id-$email', email: email);
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    if (_users[email] != password) {
      throw const AuthFailure('Correo o contraseña incorrectos');
    }
    return AuthUser(id: 'id-$email', email: email);
  }

  @override
  Future<void> signOut() async {}
}

/// Tabla profiles en memoria.
class FakeProfileRepository implements ProfileRepository {
  final _profiles = <String, Profile>{};

  @override
  Future<void> createProfile(Profile profile) async {
    _profiles[profile.id] = profile;
  }

  @override
  Future<Profile> getProfile(String userId) async {
    final profile = _profiles[userId];
    if (profile == null) {
      throw const AuthFailure('No se encontró el perfil del usuario');
    }
    return profile;
  }
}

Widget buildApp() => App(
  authRepository: FakeAuthRepository(),
  profileRepository: FakeProfileRepository(),
);

Future<void> tapButton(WidgetTester tester, String label) async {
  final button = find.widgetWithText(FilledButton, label);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('login muestra error con campos vacíos y credenciales malas', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);

    await tapButton(tester, 'Iniciar sesión');
    expect(find.text('Escribe tu correo y tu contraseña'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'nadie@icesi.edu.co');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tapButton(tester, 'Iniciar sesión');
    expect(find.text('Correo o contraseña incorrectos'), findsOneWidget);
  });

  testWidgets('registro valida, crea la cuenta, muestra el perfil y vuelve '
      'a entrar con login', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('¿No tienes cuenta? Regístrate'));
    await tester.pumpAndSettle();
    expect(find.text('Crea tu cuenta'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'smosquera');
    await tester.enterText(find.byType(TextField).at(1), 'Santiago Mosquera');
    await tester.enterText(find.byType(TextField).at(2), 'santi@icesi.edu.co');
    await tester.enterText(find.byType(TextField).at(3), '123456');
    await tester.enterText(find.byType(TextField).at(4), '654321');
    await tapButton(tester, 'Registrarme');
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(4), '123456');
    await tapButton(tester, 'Registrarme');
    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('@smosquera'), findsOneWidget);
    expect(find.text('santi@icesi.edu.co'), findsOneWidget);

    await tapButton(tester, 'Cerrar sesión');
    expect(find.text('Bienvenido de nuevo'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'santi@icesi.edu.co');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tapButton(tester, 'Iniciar sesión');
    expect(find.text('Santiago Mosquera'), findsWidgets);
  });
}
