import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/auth_user.dart';
import '../../../../core/error/exceptions.dart';
import 'user_profile_datasource.dart';

class FirestoreUserProfileDataSource implements UserProfileDataSource {
  FirestoreUserProfileDataSource(this._firestore);

  final FirebaseFirestore _firestore;
  static const Map<String, dynamic> _defaultBalances = <String, double>{
    'USDT': 10000.0,
    'USD': 5000.0,
  };
  static const Map<String, dynamic> _defaultSettings = <String, dynamic>{
    'showMarkets': true,
    'showPortfolio': true,
    'showHistory': true,
    'autoRefresh': true,
    'language': 'es',
    'currency': 'USD',
    'twoFactorEnabled': false,
    'biometricEnabled': false,
  };

  CollectionReference<Map<String, dynamic>> get _usersCollection => _firestore.collection('users');

  @override
  Future<AuthUser> fetchProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      final data = doc.data();
      if (data == null) {
        return AuthUser(uid: uid, email: '');
      }
      return AuthUser(
        uid: uid,
        email: (data['email'] as String?) ?? '',
        displayName: data['displayName'] as String?,
        photoUrl: data['photoUrl'] as String?,
      );
    } on FirebaseException catch (error) {
      throw CacheException(message: error.message);
    }
  }

  @override
  Future<void> saveProfile(AuthUser user) async {
    final docRef = _usersCollection.doc(user.uid);
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = <String, dynamic>{
        'email': user.email,
        'displayName': user.displayName?.isNotEmpty == true ? user.displayName : user.email,
        'photoUrl': user.photoUrl,
        'lastLoginAt': FieldValue.serverTimestamp(),
      };
      if (!snapshot.exists) {
        transaction.set(docRef, {
          ...data,
          'createdAt': FieldValue.serverTimestamp(),
          'balances': _defaultBalances,
          'settings': _defaultSettings,
        });
      } else {
        transaction.update(docRef, data);
      }
    });
  }
}
