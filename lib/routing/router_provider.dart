// lib/src/routing/app_router.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tbtech/job_orders/ui/job_order_details.dart';
import 'package:tbtech/job_orders/ui/job_orders_list.dart';
import '../auth/services/auth_service.dart';
import '../auth/ui/login_screen.dart';
import '../home/ui/home_screen.dart';
import '../splash/ui/splash_screen.dart'; // Create this simple screen

// Provider for the GoRouter instance
final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authServiceProvider);

  return GoRouter(
    initialLocation: '/splash',
    // Start with a splash screen
    debugLogDiagnostics: true,
    // Helpful for debugging
    redirect: (BuildContext context, GoRouterState state) {
      final isAuthenticated = authState == AuthStatus.authenticated;
      final isUnauthenticated = authState == AuthStatus.unauthenticated;

      final loggingIn = state.matchedLocation == '/login';
      final splashing = state.matchedLocation == '/splash';

      // If auth state is unknown, stay on splash
      if (authState == AuthStatus.unknown) {
        return splashing ? null : '/splash';
      }

      // If authenticated:
      if (isAuthenticated) {
        // If on login or splash, redirect to home
        if (loggingIn || splashing) {
          return '/home';
        }
      }
      // If unauthenticated:
      else if (isUnauthenticated) {
        // If not on login or splash, redirect to login
        if (!loggingIn && splashing) {
          return '/login';
        }
      }
      return null; // No redirect needed
    },
    refreshListenable: GoRouterRefreshStream(ref
        .watch(authServiceProvider.notifier)
        .stream),
    // Re-evaluate routes on auth state change
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        // Example of a sub-route:
        // routes: [
        //   GoRoute(
        //     path: 'details/:id',
        //     builder: (context, state) {
        //       final id = state.pathParameters['id']!;
        //       return ItemDetailsScreen(itemId: id);
        //     },
        //   ),
        // ],
      ),
      GoRoute(
        path: '/job_orders',
        builder: (context, state) => const JobOrdersListScreen(),
      ),
      GoRoute(
        path: '/job_order/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'];
          return JobOrderDetailScreen(id: int.parse(id!));
        }),
    ],
    // Optional: Error page
    errorBuilder: (context, state) =>
        Scaffold(
          appBar: AppBar(title: const Text('Page Not Found')),
          body: Center(child: Text('Error: ${state.error}')),
        ),
  );
});

// Helper class to listen to Riverpod StateNotifier stream for GoRouter refresh
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}