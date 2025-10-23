import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/feature_flags.dart';
import '../../features/auth/domain/entities/auth_user.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../styles/app_colors.dart';
import '../styles/app_spacing.dart';
import '../styles/app_typography.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final tabs = _buildTabs();
    final selected = tabs.firstWhere(
      (tab) => location.startsWith(tab.path),
      orElse: () => tabs.first,
    );
    final authState = context.watch<AuthBloc>().state;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AppTopBar(
            tabs: tabs,
            selectedTab: selected,
            user: authState.user,
            status: authState.status,
          ),
          const SizedBox(height: AppSpacing.lg),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Container(
                color: Colors.transparent,
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AppTopBar extends StatelessWidget {
  const _AppTopBar({
    required this.tabs,
    required this.selectedTab,
    required this.user,
    required this.status,
  });

  final List<_ShellDestination> tabs;
  final _ShellDestination selectedTab;
  final AuthUser? user;
  final AuthStatus status;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    final flags = GetIt.I<FeatureFlags>();
    final displayName = user?.displayName?.isNotEmpty == true ? user!.displayName! : (user?.email ?? 'Invitado');
    final email = user?.email;
    final photoUrl = user?.photoUrl;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 24,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: [
          _Branding(),
          const SizedBox(width: AppSpacing.xl),
          for (final tab in tabs) ...[
            _NavPill(
              label: tab.label,
              icon: tab.icon,
              active: tab == selectedTab,
              onTap: () => router.go(tab.path),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          const Spacer(),
          if (flags.settingsEnabled)
            _OutlinedButton(
              icon: Icons.settings,
              label: 'Ajustes',
              onTap: () => router.go('/home/settings'),
              highlight: selectedTab.path == '/home/settings',
            ),
          const SizedBox(width: AppSpacing.md),
          _UserBadge(
            displayName: displayName,
            email: email,
            photoUrl: photoUrl,
            loading: status == AuthStatus.loading,
            onPressed: () => router.go(flags.settingsEnabled ? '/home/settings' : '/home/markets'),
          ),
          const SizedBox(width: AppSpacing.sm),
          _OutlinedIconButton(
            icon: Icons.logout_rounded,
            tooltip: 'Cerrar sesion',
            onTap: () => context.read<AuthBloc>().add(AuthSignOutRequested()),
          ),
        ],
      ),
    );
  }
}

class _Branding extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: AppColors.primaryButton,
          ),
          child: const Icon(Icons.show_chart, color: Colors.white),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'CryptoExchange',
          style: AppTypography.titleMd.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          gradient: active ? AppColors.primaryButton : null,
          color: active ? null : AppColors.bgInput.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.bodySm.copyWith(
                color: color,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlinedButton extends StatelessWidget {
  const _OutlinedButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: highlight ? AppColors.primary.withValues(alpha: 0.12) : AppColors.bgInput.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: highlight ? AppColors.primary : AppColors.divider),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: highlight ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTypography.bodySm.copyWith(
                color: highlight ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlinedIconButton extends StatelessWidget {
  const _OutlinedIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.bgInput.withValues(alpha: 0.6),
          border: Border.all(color: AppColors.divider),
        ),
        child: Icon(icon, color: AppColors.textSecondary),
      ),
    );
    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}

class _UserBadge extends StatelessWidget {
  const _UserBadge({
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.loading,
    required this.onPressed,
  });

  final String displayName;
  final String? email;
  final String? photoUrl;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final subtitle = email ?? '';
    final initials = displayName.trim().isEmpty
        ? '??'
        : displayName
            .trim()
            .split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join();

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgInput.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: _UserAvatar(
                photoUrl: photoUrl,
                initials: initials,
                loading: loading,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({
    required this.photoUrl,
    required this.initials,
    required this.loading,
  });

  final String? photoUrl;
  final String initials;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          photoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _InitialsAvatar(initials: initials),
        ),
      );
    }
    return _InitialsAvatar(initials: initials);
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryButton,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: AppTypography.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

List<_ShellDestination> _buildTabs() {
  final flags = GetIt.I<FeatureFlags>();
  final items = <_ShellDestination>[
    const _ShellDestination(label: 'Mercados', icon: Icons.show_chart_rounded, path: '/home/markets'),
    const _ShellDestination(label: 'Portafolio', icon: Icons.account_balance_wallet_outlined, path: '/home/portfolio'),
  ];
  if (flags.historyEnabled) {
    items.add(const _ShellDestination(label: 'Historial', icon: Icons.history_rounded, path: '/home/history'));
  }
  if (flags.settingsEnabled) {
    items.add(const _ShellDestination(label: 'Ajustes', icon: Icons.tune_rounded, path: '/home/settings'));
  }
  return items;
}

class _ShellDestination {
  const _ShellDestination({
    required this.label,
    required this.icon,
    required this.path,
  });

  final String label;
  final IconData icon;
  final String path;
}
