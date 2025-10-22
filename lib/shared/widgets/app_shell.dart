import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/feature_flags.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(context).location;
    final tabs = _buildTabs();
    final currentIndex = tabs.indexWhere((tab) => location.startsWith(tab.path));
    final flags = GetIt.I<FeatureFlags>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('CryptoExchange'),
        actions: [
          TextButton(
            onPressed: () => context.go(flags.settingsEnabled ? '/home/settings' : '/home/markets'),
            child: const Text('Usuario Demo'),
          ),
        ],
      ),
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex < 0 ? 0 : currentIndex,
        onDestinationSelected: (index) => context.go(tabs[index].path),
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              label: tab.label,
            )
        ],
      ),
    );
  }
}

List<_ShellDestination> _buildTabs() {
  final flags = GetIt.I<FeatureFlags>();
  final items = <_ShellDestination>[
    const _ShellDestination(label: 'Mercados', icon: Icons.show_chart, path: '/home/markets'),
    const _ShellDestination(label: 'Portafolio', icon: Icons.account_balance_wallet, path: '/home/portfolio'),
  ];
  if (flags.historyEnabled) {
    items.add(const _ShellDestination(label: 'Historial', icon: Icons.receipt_long, path: '/home/history'));
  }
  if (flags.settingsEnabled) {
    items.add(const _ShellDestination(label: 'Ajustes', icon: Icons.settings, path: '/home/settings'));
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
