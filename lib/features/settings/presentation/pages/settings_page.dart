import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:coin_venture/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:coin_venture/features/auth/domain/entities/auth_user.dart';

import '../../../../shared/styles/app_colors.dart';
import '../../../../shared/styles/app_spacing.dart';
import '../../../../shared/styles/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_page.dart';
import '../../domain/entities/app_settings.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<SettingsBloc>()..add(SettingsStarted()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state.status == SettingsStatus.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ajustes guardados'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == SettingsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final bloc = context.read<SettingsBloc>();
        final settings = state.settings;
        final authState = context.watch<AuthBloc>().state;
        final user = authState.user;

        return AppPage(
          children: [
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Configuracion', style: AppTypography.titleMd),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Administra tus preferencias y seguridad',
                    style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            _ProfileSection(settings: settings, user: user),
            _NotificationsSection(
              settings: settings,
              onChanged: (updated) => bloc.add(SettingsToggled(updated)),
            ),
            _SecuritySection(
              settings: settings,
              onChanged: (updated) => bloc.add(SettingsToggled(updated)),
            ),
            _PreferenceSection(
              settings: settings,
              onChanged: (updated) => bloc.add(SettingsToggled(updated)),
            ),
            AppButton.primary(
              label: 'Guardar cambios',
              icon: Icons.save_outlined,
              onPressed: () => bloc.add(SettingsSaved(settings)),
            ),
            if (state.status == SettingsStatus.failure && state.errorMessage != null)
              Text(
                state.errorMessage!,
                style: AppTypography.bodySm.copyWith(color: AppColors.danger),
              ),
          ],
        );
      },
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.settings, required this.user});

  final AppSettings settings;
  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    final displayName = user?.displayName?.isNotEmpty == true ? user!.displayName! : (user?.email ?? 'Invitado');
    final email = user?.email ?? '--';
    final photoUrl = user?.photoUrl ?? '';
    final bool hasPhoto = photoUrl.isNotEmpty;
    final initials = displayName.trim().isEmpty
        ? '??'
        : displayName
            .trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Perfil', style: AppTypography.titleSm),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary.withValues(alpha: 0.3),
                backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
                child: hasPhoto
                    ? null
                    : Text(
                        initials,
                        style: AppTypography.bodyMd.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTypography.bodyMd.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _buildTagChip(Icons.public, settings.language.toUpperCase()),
                        _buildTagChip(Icons.attach_money, settings.currency.toUpperCase()),
                        if (settings.autoRefresh)
                          _buildTagChip(Icons.bolt, 'Auto refresh'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.bgInput.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}


class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection({
    required this.settings,
    required this.onChanged,
  });

  final AppSettings settings;
  final ValueChanged<AppSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Notificaciones', style: AppTypography.titleSm),
          const SizedBox(height: AppSpacing.md),
          _SettingToggle(
            title: 'Alertas de precio',
            subtitle: 'Recibe notificaciones cuando cambie el precio',
            value: settings.autoRefresh,
            onChanged: (value) => onChanged(settings.copyWith(autoRefresh: value)),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SettingToggle(
            title: 'Confirmaciones de trading',
            subtitle: 'Confirma cada transaccion',
            value: settings.showHistory,
            onChanged: (value) => onChanged(settings.copyWith(showHistory: value)),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SettingToggle(
            title: 'Mostrar portafolio',
            subtitle: 'Incluye la vista de portafolio en el menu principal',
            value: settings.showPortfolio,
            onChanged: (value) => onChanged(settings.copyWith(showPortfolio: value)),
          ),
        ],
      ),
    );
  }
}

class _SecuritySection extends StatelessWidget {
  const _SecuritySection({
    required this.settings,
    required this.onChanged,
  });

  final AppSettings settings;
  final ValueChanged<AppSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Seguridad', style: AppTypography.titleSm),
          const SizedBox(height: AppSpacing.md),
          _SettingToggle(
            title: 'Autenticacion de dos factores',
            subtitle: 'Anade una capa extra de seguridad',
            value: settings.twoFactorEnabled,
            onChanged: (value) => onChanged(settings.copyWith(twoFactorEnabled: value)),
          ),
          const SizedBox(height: AppSpacing.sm),
          _SettingToggle(
            title: 'Autenticacion biometrica',
            subtitle: 'Usa huella o reconocimiento facial',
            value: settings.biometricEnabled,
            onChanged: (value) => onChanged(settings.copyWith(biometricEnabled: value)),
          ),
        ],
      ),
    );
  }
}

class _PreferenceSection extends StatelessWidget {
  const _PreferenceSection({
    required this.settings,
    required this.onChanged,
  });

  final AppSettings settings;
  final ValueChanged<AppSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Preferencias', style: AppTypography.titleSm),
          const SizedBox(height: AppSpacing.md),
          _DropdownSetting(
            label: 'Idioma',
            value: settings.language,
            items: const [
              DropdownMenuItem(value: 'es', child: Text('Espanol')),
              DropdownMenuItem(value: 'en', child: Text('Ingles')),
            ],
            onChanged: (value) => onChanged(settings.copyWith(language: value)),
          ),
          const SizedBox(height: AppSpacing.md),
          _DropdownSetting(
            label: 'Moneda preferida',
            value: settings.currency,
            items: const [
              DropdownMenuItem(value: 'USD', child: Text('USD - Dolar')),
              DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
              DropdownMenuItem(value: 'VES', child: Text('VES - Bolivar')),
            ],
            onChanged: (value) => onChanged(settings.copyWith(currency: value)),
          ),
        ],
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  const _SettingToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodyMd),
              const SizedBox(height: 4),
              Text(subtitle, style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _DropdownSetting extends StatelessWidget {
  const _DropdownSetting({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.bodyMd),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.bgInput.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items,
              onChanged: (selected) {
                if (selected != null) {
                  onChanged(selected);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
