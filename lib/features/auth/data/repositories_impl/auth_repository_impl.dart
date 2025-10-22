import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/security/token_store.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/session_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../datasources/user_profile_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required FirebaseAuthDataSource remote,
    required UserProfileDataSource profile,
    required TokenStore tokenStore,
  })  : _remote = remote,
        _profile = profile,
        _tokenStore = tokenStore;

  final FirebaseAuthDataSource _remote;
  final UserProfileDataSource _profile;
  final TokenStore _tokenStore;

  @override
  Future<Either<Failure, AuthUser>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final user = await _remote.signInWithEmail(email, password);
      await _profile.saveProfile(user);
      return Right(user);
    } on AuthException catch (error) {
      return Left(AuthFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> registerWithEmail(
    String email,
    String password,
  ) async {
    try {
      final user = await _remote.registerWithEmail(email, password);
      await _profile.saveProfile(user);
      return Right(user);
    } on AuthException catch (error) {
      return Left(AuthFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> signInWithGoogle() async {
    try {
      final user = await _remote.signInWithGoogle();
      await _profile.saveProfile(user);
      return Right(user);
    } on AuthException catch (error) {
      return Left(AuthFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remote.signOut();
      await _tokenStore.clear();
      return const Right(null);
    } on AuthException catch (error) {
      return Left(AuthFailure(message: error.message));
    }
  }

  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() async {
    try {
      final user = await _remote.currentUser();
      return Right(user);
    } on AuthException catch (error) {
      return Left(AuthFailure(message: error.message));
    }
  }

  @override
  Stream<AuthUser?> watchUser() => _remote.userChanges();

  @override
  Future<Either<Failure, SessionToken>> refreshToken() async {
    try {
      final token = await _remote.refreshToken();
      await _tokenStore.save(token);
      return Right(token);
    } on AuthException catch (error) {
      return Left(AuthFailure(message: error.message));
    }
  }
}
