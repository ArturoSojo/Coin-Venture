import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class SaveSettings {
  SaveSettings(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, void>> call(AppSettings settings) {
    return _repository.saveSettings(settings);
  }
}
