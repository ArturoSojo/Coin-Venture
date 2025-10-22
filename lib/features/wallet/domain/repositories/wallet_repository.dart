import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/balance.dart';

abstract class WalletRepository {
  Future<Either<Failure, List<Balance>>> getBalances();
}
