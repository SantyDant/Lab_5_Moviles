# Laboratorio 5 — Registro e inicio de sesión con Supabase

**Autor:** Santiago Mosquera — Aplicaciones Móviles, Universidad Icesi

App Flutter con registro (Parte 1) e inicio de sesión (Parte 2) sobre Supabase, organizada con Clean Architecture y Bloc. Parte del proyecto base 262App3 del curso.

## Cómo correrlo

```bash
flutter pub get
flutter run
```

Por defecto usa el proyecto de Supabase del curso. Para usar otro:

```bash
flutter run --dart-define=SUPABASE_URL=https://xxxx.supabase.co --dart-define=SUPABASE_KEY=sb_publishable_xxxx
```

En Supabase hay que tener la tabla `profiles` (ver `supabase/migrations`) y desactivar **Confirm email** en *Authentication*, porque el perfil se inserta con la sesión que devuelve el registro.

## Arquitectura

```
lib/
├── core/supabase_config.dart           URL y llave de Supabase
├── features/auth/
│   ├── domain/                          sin dependencias de Supabase
│   │   ├── entities/      Profile, AuthUser
│   │   ├── errors/        AuthFailure (mensaje para el usuario)
│   │   ├── repository/    AuthRepository, ProfileRepository (contratos)
│   │   └── usecases/      SignUpUseCase, SignInUseCase, SignOutUseCase
│   └── data/
│       ├── source/        SupabaseAuthDataSource, SupabaseProfileDataSource
│       └── repository/    implementaciones que traducen errores a AuthFailure
├── features/register/ui/  RegisterBloc + RegisterScreen   (Parte 1)
├── features/login/ui/     LoginBloc + LoginScreen         (Parte 2)
└── features/home/ui/      HomeScreen con el perfil real y cierre de sesión
```

**Flujo de registro:** `RegisterScreen` → evento `RegisterSubmitted` → `RegisterBloc` valida campos y contraseñas → `SignUpUseCase` crea la cuenta en Supabase Auth e inserta la fila en `profiles` → estado `RegisterSuccess(profile)` → `BlocListener` navega a `/home` con el perfil.

**Flujo de login:** `LoginScreen` → `LoginSubmitted` → `LoginBloc` → `SignInUseCase` inicia sesión y lee el perfil → `LoginSuccess(profile)` → `/home`.

`main.dart` crea los repositorios y envuelve cada ruta en su `BlocProvider`. `App` recibe los repositorios por constructor, así los tests usan versiones en memoria (`test/navigation_test.dart`).

```bash
flutter test
```
