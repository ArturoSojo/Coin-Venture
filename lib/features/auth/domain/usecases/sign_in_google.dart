import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInGoogle {
  SignInGoogle(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AuthUser>> call() {
    return _repository.signInWithGoogle();
  }
}
