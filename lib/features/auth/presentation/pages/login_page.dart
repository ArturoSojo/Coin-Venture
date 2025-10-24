import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/styles/app_spacing.dart';
import '../../../../shared/styles/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/usecases/sign_in_email.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthSignInRequested(
            SignInEmailParams(
              email: _emailController.text,
              password: _passwordController.text,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryButton,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x3327B3FF),
                        blurRadius: 32,
                        offset: Offset(0, 18),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.show_chart_rounded, size: 46, color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Coin Venture', style: AppTypography.titleLg),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Inicia sesion en tu cuenta',
                  style: AppTypography.bodyMd.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          label: 'Email',
                          hint: 'tu@email.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.mail_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu correo electronico';
                            }
                            if (!value.contains('@')) {
                              return 'Correo invalido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Contrasena',
                          hint: 'Introduce tu contrasena',
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu contrasena';
                            }
                            if (value.length < 6) {
                              return 'Debe contener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppButton.primary(
                          label: 'Iniciar sesion',
                          icon: Icons.login_rounded,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: AppColors.divider.withValues(alpha: 0.6)),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              'O continua con',
                              style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Divider(color: AppColors.divider.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        AppButton.ghost(
                          label: 'Google',
                          icon: Icons.g_mobiledata_outlined,
                          onPressed: () => context.read<AuthBloc>().add(AuthGoogleSignInRequested()),
                          expanded: true,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () => context.go('/register'),
                            child: Text(
                              'No tienes cuenta? Registrate',
                              style: AppTypography.bodySm.copyWith(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
