import '../../domain/entities/app_settings.dart';

abstract class LocalSettingsDataSource {
  Future<AppSettings> loadSettings();
  Future<void> saveSettings(AppSettings settings);
}

class MemorySettingsDataSource implements LocalSettingsDataSource {
  AppSettings _settings = const AppSettings();

  @override
  Future<AppSettings> loadSettings() async {
    return _settings;
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    _settings = settings;
  }
}
