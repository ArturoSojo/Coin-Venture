import '../../domain/entities/app_settings.dart';

abstract class SettingsEvent {}

class SettingsStarted extends SettingsEvent {}

class SettingsToggled extends SettingsEvent {
  SettingsToggled(this.settings);

  final AppSettings settings;
}

class SettingsSaved extends SettingsEvent {
  SettingsSaved(this.settings);

  final AppSettings settings;
}
