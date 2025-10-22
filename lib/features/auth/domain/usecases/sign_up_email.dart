import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignUpEmail {
  SignUpEmail(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, AuthUser>> call(SignUpEmailParams params) {
    return _repository.registerWithEmail(params.email, params.password);
  }
}

class SignUpEmailParams {
  const SignUpEmailParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;
}
