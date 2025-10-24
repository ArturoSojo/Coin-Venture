import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/styles/app_spacing.dart';
import '../../../../shared/styles/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/usecases/sign_up_email.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            SignUpEmailParams(
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
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 92,
                  height: 92,
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
                  child: const Icon(Icons.person_add_alt_1_rounded, size: 44, color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text('Crear cuenta', style: AppTypography.titleLg),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Unete a Coin Venture en segundos',
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
                          hint: 'demo@crypto.com',
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
                          hint: 'Minimo 6 caracteres',
                          controller: _passwordController,
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword,
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
                        const SizedBox(height: AppSpacing.md),
                        AppTextField(
                          label: 'Confirmar contrasena',
                          hint: 'Repite tu contrasena',
                          controller: _confirmController,
                          prefixIcon: Icons.lock_reset_rounded,
                          obscureText: _obscureConfirm,
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirma tu contrasena';
                            }
                            if (value != _passwordController.text) {
                              return 'Las contrasenas no coinciden';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppButton.primary(
                          label: 'Crear cuenta',
                          icon: Icons.check_circle_outline,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () => context.go('/login'),
                            child: Text(
                              'Ya tienes cuenta? Inicia sesion',
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
