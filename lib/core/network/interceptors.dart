import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../security/token_store.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    TokenStore? tokenStore;
    if (GetIt.I.isRegistered<TokenStore>()) {
      tokenStore = GetIt.I<TokenStore>();
    }
    final token = await tokenStore?.read();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer ${token.accessToken}';
    }
    super.onRequest(options, handler);
  }
}
