import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/save_settings.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required GetSettings getSettings,
    required SaveSettings saveSettings,
  })  : _getSettings = getSettings,
        _saveSettings = saveSettings,
        super(const SettingsState()) {
    on<SettingsStarted>(_onStarted);
    on<SettingsToggled>(_onToggled);
    on<SettingsSaved>(_onSaved);
  }

  final GetSettings _getSettings;
  final SaveSettings _saveSettings;

  Future<void> _onStarted(SettingsStarted event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    final result = await _getSettings();
    result.fold(
      (failure) => emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: failure.message,
      )),
      (settings) => emit(state.copyWith(
        status: SettingsStatus.loaded,
        settings: settings,
      )),
    );
  }

  void _onToggled(SettingsToggled event, Emitter<SettingsState> emit) {
    emit(state.copyWith(settings: event.settings));
  }

  Future<void> _onSaved(SettingsSaved event, Emitter<SettingsState> emit) async {
    emit(state.copyWith(status: SettingsStatus.saving));
    final result = await _saveSettings(event.settings);
    result.fold(
      (failure) => emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: SettingsStatus.saved,
        settings: event.settings,
      )),
    );
  }
}
