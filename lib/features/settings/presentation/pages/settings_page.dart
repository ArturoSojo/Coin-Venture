import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

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
            const SnackBar(content: Text('Ajustes guardados')), 
          );
        }
      },
      builder: (context, state) {
        if (state.status == SettingsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        final bloc = context.read<SettingsBloc>();
        final settings = state.settings;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile.adaptive(
              title: const Text('Auto actualizaciones'),
              value: settings.autoRefresh,
              onChanged: (value) => bloc.add(SettingsToggled(settings.copyWith(autoRefresh: value))),
            ),
            SwitchListTile.adaptive(
              title: const Text('Historial visible'),
              value: settings.showHistory,
              onChanged: (value) => bloc.add(SettingsToggled(settings.copyWith(showHistory: value))),
            ),
            ListTile(
              title: const Text('Idioma'),
              trailing: DropdownButton<String>(
                value: settings.language,
                items: const [
                  DropdownMenuItem(value: 'es', child: Text('Español')),
                  DropdownMenuItem(value: 'en', child: Text('Inglés')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    bloc.add(SettingsToggled(settings.copyWith(language: value)));
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Moneda base'),
              trailing: DropdownButton<String>(
                value: settings.currency,
                items: const [
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                  DropdownMenuItem(value: 'VES', child: Text('VES')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    bloc.add(SettingsToggled(settings.copyWith(currency: value)));
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => bloc.add(SettingsSaved(settings)),
              child: const Text('Guardar cambios'),
            ),
            if (state.status == SettingsStatus.failure && state.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(state.errorMessage!, style: const TextStyle(color: Colors.redAccent)),
              ),
          ],
        );
      },
    );
  }
}
