import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_in_usecase.dart';

// ---------- Eventos ----------

sealed class LoginEvent {}

/// El usuario tocó "Iniciar sesión".
class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;

  LoginSubmitted({required this.email, required this.password});
}

// ---------- Estados ----------

sealed class LoginState {}

class LoginIdle extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final Profile profile;
  LoginSuccess(this.profile);
}

class LoginFailure extends LoginState {
  final String message;
  LoginFailure(this.message);
}

// ---------- Bloc ----------

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final SignInUseCase _signIn;

  LoginBloc(this._signIn) : super(LoginIdle()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final email = event.email.trim();
    if (email.isEmpty || event.password.isEmpty) {
      emit(LoginFailure('Escribe tu correo y tu contraseña'));
      return;
    }

    emit(LoginLoading());
    try {
      final profile = await _signIn(email: email, password: event.password);
      emit(LoginSuccess(profile));
    } on AuthFailure catch (e) {
      emit(LoginFailure(e.message));
    } catch (_) {
      emit(LoginFailure('Ocurrió un error inesperado. Intenta de nuevo'));
    }
  }
}
