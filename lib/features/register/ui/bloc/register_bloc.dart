import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';

// ---------- Eventos ----------

sealed class RegisterEvent {}

/// El usuario tocó "Registrarme".
class RegisterSubmitted extends RegisterEvent {
  final String username;
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;

  RegisterSubmitted({
    required this.username,
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
}

// ---------- Estados ----------

sealed class RegisterState {}

class RegisterIdle extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final Profile profile;
  RegisterSuccess(this.profile);
}

class RegisterFailure extends RegisterState {
  final String message;
  RegisterFailure(this.message);
}

// ---------- Bloc ----------

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final SignUpUseCase _signUp;

  RegisterBloc(this._signUp) : super(RegisterIdle()) {
    on<RegisterSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    final username = event.username.trim();
    final fullName = event.fullName.trim();
    final email = event.email.trim();

    if (username.isEmpty ||
        fullName.isEmpty ||
        email.isEmpty ||
        event.password.isEmpty) {
      emit(RegisterFailure('Completa todos los campos'));
      return;
    }
    if (event.password != event.confirmPassword) {
      emit(RegisterFailure('Las contraseñas no coinciden'));
      return;
    }

    emit(RegisterLoading());
    try {
      final profile = await _signUp(
        username: username,
        fullName: fullName,
        email: email,
        password: event.password,
      );
      emit(RegisterSuccess(profile));
    } on AuthFailure catch (e) {
      emit(RegisterFailure(e.message));
    } catch (_) {
      emit(RegisterFailure('Ocurrió un error inesperado. Intenta de nuevo'));
    }
  }
}
