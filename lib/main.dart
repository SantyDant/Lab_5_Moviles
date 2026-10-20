import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:moviles_auth/core/supabase_config.dart';
import 'package:moviles_auth/features/auth/data/repository/auth_repository_impl.dart';
import 'package:moviles_auth/features/auth/data/repository/profile_repository_impl.dart';
import 'package:moviles_auth/features/auth/data/source/supabase_auth_data_source.dart';
import 'package:moviles_auth/features/auth/data/source/supabase_profile_data_source.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:moviles_auth/features/home/ui/screens/home_screen.dart';
import 'package:moviles_auth/features/login/ui/screens/login_screen.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_bloc.dart';
import 'package:moviles_auth/features/register/ui/screens/register_screen.dart';
import 'package:moviles_auth/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  final client = Supabase.instance.client;
  runApp(
    App(
      authRepository: AuthRepositoryImpl(SupabaseAuthDataSource(client)),
      profileRepository: ProfileRepositoryImpl(
        SupabaseProfileDataSource(client),
      ),
    ),
  );
}

/// Widget raíz: tema, rutas nombradas e inyección de dependencias.
///
/// Recibe los repositorios desde afuera para poder probar la app con
/// implementaciones falsas, sin conectarse a Supabase.
class App extends StatelessWidget {
  final AuthRepository authRepository;
  final ProfileRepository profileRepository;

  const App({
    super.key,
    required this.authRepository,
    required this.profileRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Moviles Auth',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => BlocProvider(
          create: (_) =>
              RegisterBloc(SignUpUseCase(authRepository, profileRepository)),
          child: const RegisterScreen(),
        ),
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is! Profile) {
            // Sin perfil no hay sesión que mostrar.
            return const LoginScreen();
          }
          return HomeScreen(
            profile: args,
            signOut: SignOutUseCase(authRepository),
          );
        },
      },
    );
  }
}
