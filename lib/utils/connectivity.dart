import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityStatusProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  // `onConnectivityChanged` returns a List<ConnectivityResult>
  return Connectivity().onConnectivityChanged;
});

// A provider to easily check if online (derived from the above)
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityResults = ref.watch(connectivityStatusProvider).asData?.value;
  if (connectivityResults == null || connectivityResults.isEmpty) {
    // Handle loading or error state, or assume offline if no data
    // You might want to check initial connectivity here as well for a more robust solution
    return false;
  }
  // Check if any result in the list indicates an online connection
  return connectivityResults.any((result) =>
  result != ConnectivityResult.none &&
      result != ConnectivityResult.bluetooth);
});