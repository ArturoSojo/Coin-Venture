import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local_settings_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._localDataSource);

  final LocalSettingsDataSource _localDataSource;

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final settings = await _localDataSource.loadSettings();
      return Right(settings);
    } on CacheException catch (error) {
      return Left(CacheFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(AppSettings settings) async {
    try {
      await _localDataSource.saveSettings(settings);
      return const Right(null);
    } on CacheException catch (error) {
      return Left(CacheFailure(message: error.message));
    }
  }
}
