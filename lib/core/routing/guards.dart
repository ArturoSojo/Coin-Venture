import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';

class AuthGuard extends ChangeNotifier {
  AuthGuard(this._repository) {
    _subscription = _repository.watchUser().listen((user) {
      _isAuthenticated = user != null;
      notifyListeners();
    });
  }

  final AuthRepository _repository;
  late final StreamSubscription _subscription;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  String? redirect(BuildContext context, GoRouterState state) {
    final loggingIn = state.fullPath?.startsWith('/login') ?? false;
    if (!_isAuthenticated && !loggingIn) {
      return '/login';
    }
    if (_isAuthenticated && loggingIn) {
      return '/home/markets';
    }
    return null;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
