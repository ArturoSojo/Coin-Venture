import '../../domain/usecases/sign_in_email.dart';
import '../../domain/usecases/sign_up_email.dart';

abstract class AuthEvent {}

class AuthStarted extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  AuthSignInRequested(this.params);

  final SignInEmailParams params;
}

class AuthRegisterRequested extends AuthEvent {
  AuthRegisterRequested(this.params);

  final SignUpEmailParams params;
}

class AuthGoogleSignInRequested extends AuthEvent {}

class AuthSignOutRequested extends AuthEvent {}
