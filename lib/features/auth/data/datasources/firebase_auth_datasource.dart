import '../../domain/entities/auth_user.dart';
import '../../domain/entities/session_token.dart';

abstract class FirebaseAuthDataSource {
  Future<AuthUser> signInWithEmail(String email, String password);
  Future<AuthUser> registerWithEmail(String email, String password);
  Future<AuthUser> signInWithGoogle();
  Future<void> signOut();
  Future<AuthUser?> currentUser();
  Stream<AuthUser?> userChanges();
  Future<SessionToken> refreshToken();
}
