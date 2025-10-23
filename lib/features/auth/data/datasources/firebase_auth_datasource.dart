import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/entities/session_token.dart';
import '../../../../core/error/exceptions.dart';

abstract class FirebaseAuthDataSource {
  Future<AuthUser> signInWithEmail(String email, String password);
  Future<AuthUser> registerWithEmail(String email, String password);
  Future<AuthUser> signInWithGoogle();
  Future<void> signOut();
  Future<AuthUser?> currentUser();
  Stream<AuthUser?> userChanges();
  Future<SessionToken> refreshToken();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  FirebaseAuthDataSourceImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: const ['email']);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  bool _persistenceConfigured = false;

  Future<void> _ensurePersistence() async {
    if (_persistenceConfigured) {
      return;
    }
    if (kIsWeb) {
      try {
        await _auth.setPersistence(Persistence.LOCAL);
      } on FirebaseAuthException catch (error) {
        throw AuthException(error.message ?? 'No se pudo configurar la sesion');
      }
    }
    _persistenceConfigured = true;
  }

  AuthUser _mapUser(User user) {
    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  @override
  Future<AuthUser?> currentUser() async {
    await _ensurePersistence();
    final user = _auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  @override
  Future<SessionToken> refreshToken() async {
    await _ensurePersistence();
    final user = _auth.currentUser;
    if (user == null) {
      throw const AuthException('No hay usuario autenticado');
    }
    try {
      final accessToken = await user.getIdToken(true);
      final tokenResult = await user.getIdTokenResult();
      final refreshToken = user.refreshToken ?? '';
      final expiration = tokenResult.expirationTime ?? DateTime.now().add(const Duration(minutes: 55));
      return SessionToken(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiry: expiration,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'No fue posible refrescar el token');
    }
  }

  @override
  Future<void> signOut() async {
    await _ensurePersistence();
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'No fue posible cerrar sesion');
    }
  }

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    await _ensurePersistence();
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user == null) {
        throw const AuthException('No fue posible iniciar sesion con correo');
      }
      return _mapUser(user);
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'Credenciales invalidas');
    }
  }

  @override
  Future<AuthUser> registerWithEmail(String email, String password) async {
    await _ensurePersistence();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final user = credential.user;
      if (user == null) {
        throw const AuthException('No fue posible registrar la cuenta');
      }
      return _mapUser(user);
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'No fue posible registrar la cuenta');
    }
  }

  @override
  Future<AuthUser> signInWithGoogle() async {
    await _ensurePersistence();
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final credential = await _auth.signInWithPopup(provider);
        final user = credential.user;
        if (user == null) {
          throw const AuthException('No fue posible iniciar sesion con Google');
        }
        return _mapUser(user);
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Inicio de sesion cancelado');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw const AuthException('No fue posible iniciar sesion con Google');
      }
      return _mapUser(user);
    } on FirebaseAuthException catch (error) {
      throw AuthException(error.message ?? 'No fue posible iniciar sesion con Google');
    }
  }

  @override
  Stream<AuthUser?> userChanges() {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) {
        return null;
      }
      return _mapUser(user);
    });
  }
}
