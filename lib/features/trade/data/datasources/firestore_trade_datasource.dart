import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/quote.dart';
import 'markets_datasource.dart';

class FirestoreTradeDataSource implements LocalTradeDataSource {
  FirestoreTradeDataSource(this._firestore, this._auth);

  final firestore.FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<void> persistOrder(Order order) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const CacheException(message: 'Usuario no autenticado');
    }

    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(uid);
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) {
          throw const CacheException(message: 'Perfil de usuario no encontrado');
        }

        final data = snapshot.data() ?? <String, dynamic>{};
        final balancesRaw = Map<String, dynamic>.from(data['balances'] ?? <String, dynamic>{});
        final baseSymbol = order.pair.base.toUpperCase();
        final quoteSymbol = order.pair.quote.toUpperCase();
        final amountBase = order.amountBase;
        final amountQuote = amountBase * order.price;

        final currentQuote = (balancesRaw[quoteSymbol] as num?)?.toDouble() ?? 0;
        final currentBase = (balancesRaw[baseSymbol] as num?)?.toDouble() ?? 0;

        if (order.side == TradeSide.buy) {
          if (currentQuote + 1e-9 < amountQuote) {
            throw const CacheException(message: 'Fondos insuficientes para completar la compra');
          }
          balancesRaw[quoteSymbol] = currentQuote - amountQuote;
          balancesRaw[baseSymbol] = currentBase + amountBase;
        } else {
          if (currentBase + 1e-9 < amountBase) {
            throw const CacheException(message: 'Cantidad insuficiente para vender');
          }
          balancesRaw[baseSymbol] = currentBase - amountBase;
          balancesRaw[quoteSymbol] = currentQuote + amountQuote;
        }

        transaction.update(userRef, <String, dynamic>{
          'balances': balancesRaw,
          'updatedAt': firestore.FieldValue.serverTimestamp(),
        });

        final historyRef = userRef.collection('transactions').doc(order.id);
        transaction.set(historyRef, <String, dynamic>{
          'pair': <String, dynamic>{
            'base': baseSymbol,
            'quote': quoteSymbol,
          },
          'side': order.side.name,
          'amountBase': amountBase,
          'amountQuote': amountQuote,
          'price': order.price,
          'status': OrderStatus.filled.name,
          'timestamp': firestore.Timestamp.fromDate(order.createdAt),
        });

        final ordersRef = userRef.collection('orders').doc(order.id);
        transaction.set(ordersRef, <String, dynamic>{
          'pair': <String, dynamic>{
            'base': baseSymbol,
            'quote': quoteSymbol,
          },
          'side': order.side.name,
          'amountBase': amountBase,
          'amountQuote': amountQuote,
          'price': order.price,
          'status': OrderStatus.filled.name,
          'createdAt': firestore.Timestamp.fromDate(order.createdAt),
        });
      });
    } on CacheException {
      rethrow;
    } on firestore.FirebaseException catch (error) {
      throw CacheException(message: error.message);
    }
  }
}
