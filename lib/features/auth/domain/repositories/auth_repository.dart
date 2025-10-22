import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';
import '../entities/session_token.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthUser>> signInWithEmail(
    String email,
    String password,
  );

  Future<Either<Failure, AuthUser>> registerWithEmail(
    String email,
    String password,
  );

  Future<Either<Failure, AuthUser>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, AuthUser?>> getCurrentUser();

  Stream<AuthUser?> watchUser();

  Future<Either<Failure, SessionToken>> refreshToken();
}
