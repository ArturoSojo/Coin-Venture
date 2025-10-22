import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class GetSettings {
  GetSettings(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, AppSettings>> call() {
    return _repository.getSettings();
  }
}
