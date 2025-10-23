import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/app_settings.dart';
import 'local_settings_datasource.dart';

class FirestoreSettingsDataSource implements LocalSettingsDataSource {
  FirestoreSettingsDataSource(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<AppSettings> loadSettings() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const CacheException(message: 'Usuario no autenticado');
    }
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      final data = doc.data();
      final settingsMap = data?['settings'] as Map<String, dynamic>?;
      return AppSettings.fromMap(settingsMap);
    } on FirebaseException catch (error) {
      throw CacheException(message: error.message);
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const CacheException(message: 'Usuario no autenticado');
    }
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set(<String, dynamic>{'settings': settings.toMap()}, SetOptions(merge: true));
    } on FirebaseException catch (error) {
      throw CacheException(message: error.message);
    }
  }
}
