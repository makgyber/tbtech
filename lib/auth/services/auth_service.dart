import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_auth_service.dart';
import 'package:tbtech/utils/constants.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthService extends StateNotifier<AuthStatus> {
  final apiAuthService = ApiAuthService(baseUrl: baseApiUrl); // Replace with your API

  AuthService() : super(AuthStatus.unknown) {
    // In a real app, you'd check the initial auth state here
    // For example, by checking for a stored token or listening to Firebase Auth changes.
    // For this example, we'll simulate a delay and then set to unauthenticated.


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
    // Simulate signing out
    await apiAuthService.removeToken();
    state = AuthStatus.unauthenticated;
  }

// You might also have methods like:
// Future<void> signUp(String email, String password) async { ... }
// Stream<AuthStatus> authStateChanges() { ... }
}

final authServiceProvider = StateNotifierProvider<AuthService, AuthStatus>((
    ref) {
  return AuthService();
});