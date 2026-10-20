import 'package:flutter/material.dart';

import 'package:moviles_auth/components/error_message.dart';
import 'package:moviles_auth/components/primary_button.dart';
import 'package:moviles_auth/components/profile_field.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:moviles_auth/theme/app_theme.dart';

/// Muestra el perfil del usuario que inició sesión y permite cerrarla.
class HomeScreen extends StatefulWidget {
  final Profile profile;
  final SignOutUseCase signOut;

  const HomeScreen({super.key, required this.profile, required this.signOut});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _signingOut = false;
  String? _error;

  Future<void> _signOut() async {
    setState(() {
      _signingOut = true;
      _error = null;
    });
    try {
      await widget.signOut();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } on AuthFailure catch (e) {
      setState(() {
        _signingOut = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final initial = profile.fullName.isEmpty
        ? '?'
        : profile.fullName[0].toUpperCase();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: AppColors.surface,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                profile.fullName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '@${profile.username}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              ProfileField(
                icon: Icons.alternate_email,
                label: 'Nombre de usuario',
                value: profile.username,
              ),
              const SizedBox(height: 12),
              ProfileField(
                icon: Icons.person_outline,
                label: 'Nombre completo',
                value: profile.fullName,
              ),
              const SizedBox(height: 12),
              ProfileField(
                icon: Icons.mail_outline,
                label: 'Correo',
                value: profile.email,
              ),
              const SizedBox(height: 32),
              if (_error != null) ...[
                ErrorMessage(message: _error!),
                const SizedBox(height: 16),
              ],
              PrimaryButton(
                label: 'Cerrar sesión',
                isLoading: _signingOut,
                onPressed: _signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
