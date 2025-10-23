import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../../trade/domain/entities/order.dart';
import '../../../trade/domain/entities/quote.dart';
import '../../../trade/domain/entities/trade_pair.dart';
import '../../domain/entities/transaction.dart';
import 'local_history_datasource.dart';

class FirestoreHistoryDataSource implements LocalHistoryDataSource {
  FirestoreHistoryDataSource(this._firestore, this._auth);

  final firestore.FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const CacheException(message: 'Usuario no autenticado');
    }
    try {
      final transactionRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc(transaction.id);
      await transactionRef.set(<String, dynamic>{
        'pair': {
          'base': transaction.pair.base,
          'quote': transaction.pair.quote,
        },
        'side': transaction.side.name,
        'amountBase': transaction.amountBase,
        'amountQuote': transaction.amountQuote,
        'price': transaction.price,
        'status': transaction.status.name,
        'timestamp': firestore.Timestamp.fromDate(transaction.timestamp),
      });
    } on firestore.FirebaseException catch (error) {
      throw CacheException(message: error.message);
    }
  }

  @override
  Future<List<Transaction>> fetchTransactions() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const CacheException(message: 'Usuario no autenticado');
    }
    try {
      final query = await _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .get();
      return query.docs
          .map((doc) => _mapTransaction(doc))
          .toList(growable: false);
    } on firestore.FirebaseException catch (error) {
      throw CacheException(message: error.message);
    }
  }

  Transaction _mapTransaction(firestore.QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final pairData = (data['pair'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final timestampValue = data['timestamp'];
    final timestamp = timestampValue is firestore.Timestamp ? timestampValue.toDate() : DateTime.now();
    final sideRaw = data['side'] as String? ?? TradeSide.buy.name;
    final statusRaw = data['status'] as String? ?? OrderStatus.filled.name;
    final amountBase = (data['amountBase'] as num?)?.toDouble() ?? 0;
    final amountQuote = (data['amountQuote'] as num?)?.toDouble() ?? 0;
    final price = (data['price'] as num?)?.toDouble() ?? 0;

    return Transaction(
      id: doc.id,
      pair: TradePair(
        base: (pairData['base'] as String? ?? 'N/A').toUpperCase(),
        quote: (pairData['quote'] as String? ?? 'USDT').toUpperCase(),
      ),
      side: TradeSide.values.firstWhere(
        (item) => item.name == sideRaw,
        orElse: () => TradeSide.buy,
      ),
      amountBase: amountBase,
      amountQuote: amountQuote,
      price: price,
      status: OrderStatus.values.firstWhere(
        (item) => item.name == statusRaw,
        orElse: () => OrderStatus.filled,
      ),
      timestamp: timestamp,
    );
  }
}
