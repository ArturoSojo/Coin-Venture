import 'dart:async';

import '../../domain/entities/auth_user.dart';
import '../../domain/entities/session_token.dart';
import 'firebase_auth_datasource.dart';

class MockFirebaseAuthDataSource implements FirebaseAuthDataSource {
  MockFirebaseAuthDataSource();

  final StreamController<AuthUser?> _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;

  @override
  Future<AuthUser?> currentUser() async => _currentUser;

  @override
  Future<SessionToken> refreshToken() async {
    return SessionToken(
      accessToken: 'mock-access-token',
      refreshToken: 'mock-refresh-token',
      expiry: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(_currentUser);
  }

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    _currentUser = AuthUser(uid: 'uid-$email', email: email, displayName: 'Usuario Demo');
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AuthUser> registerWithEmail(String email, String password) {
    return signInWithEmail(email, password);
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    return signInWithEmail('demo@google.com', '');
  }

  @override
  Stream<AuthUser?> userChanges() => _controller.stream;
}
