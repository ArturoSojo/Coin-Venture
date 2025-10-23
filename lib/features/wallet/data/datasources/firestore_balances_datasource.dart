import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/balance.dart';
import 'local_balances_datasource.dart';

class FirestoreBalancesDataSource implements LocalBalancesDataSource {
  FirestoreBalancesDataSource(this._firestore, this._auth);

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<List<Balance>> fetchBalances() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const CacheException(message: 'Usuario no autenticado');
    }
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) {
        throw const CacheException(message: 'Perfil de usuario no encontrado');
      }
      final data = doc.data();
      final rawBalances = (data?['balances'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final balances = rawBalances.entries
          .map(
            (entry) => Balance(
              symbol: entry.key.toUpperCase(),
              amount: (entry.value as num?)?.toDouble() ?? 0,
            ),
          )
          .where((balance) => balance.amount > 0)
          .toList(growable: false)
        ..sort((a, b) => b.amount.compareTo(a.amount));
      return balances;
    } on FirebaseException catch (error) {
      throw CacheException(message: error.message);
    }
  }
}
