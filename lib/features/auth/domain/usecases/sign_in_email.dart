import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignInEmail {
  SignInEmail(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AuthUser>> call(
    SignInEmailParams params,
  ) {
    return _repository.signInWithEmail(params.email, params.password);
  }
}

class SignInEmailParams {
  const SignInEmailParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}
