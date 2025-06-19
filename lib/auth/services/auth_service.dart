import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_auth_service.dart';
import 'package:tbtech/utils/constants.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthService extends StateNotifier<AuthStatus> {
  final apiAuthService = ApiAuthService(baseUrl: baseApiUrl); // Replace with your API

  AuthService() : super(AuthStatus.unknown) {
    Future.delayed(const Duration(milliseconds: 100), () async {
      bool isAuth = await apiAuthService.isAuthenticated();
      if (isAuth) {
        state = AuthStatus.authenticated;
      } else {
        state = AuthStatus.unauthenticated;
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    bool success = await apiAuthService.loginAndSaveToken(email, password);
    if (success) {
      state = AuthStatus.authenticated;
    }
  }

  Future<void> signOut() async {
    await apiAuthService.removeToken();
    state = AuthStatus.unauthenticated;
  }

}

final authServiceProvider = StateNotifierProvider<AuthService, AuthStatus>((
    ref) {
  return AuthService();
});