import 'dart:async';
import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Connectivity Service
///
/// Service for checking network connectivity status.
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Check current connectivity status
  Future<List<ConnectivityResult>> checkConnectivity() async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      developer.log('Error checking connectivity: $e', name: 'Connectivity');
      return [ConnectivityResult.none];
    }
  }

  /// Check if device is connected to internet
  Future<bool> isConnected() async {
    try {
      final results = await checkConnectivity();
      return results.isNotEmpty &&
          !results.contains(ConnectivityResult.none);
    } catch (e) {
      developer.log('Error checking if connected: $e', name: 'Connectivity');
      return false;
    }
  }

  /// Get connectivity stream
  Stream<List<ConnectivityResult>> get connectivityStream {
    return _connectivity.onConnectivityChanged;
  }

  /// Check if has any active connection
  bool hasConnection(List<ConnectivityResult> results) {
    return results.isNotEmpty &&
        !results.contains(ConnectivityResult.none);
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}

/// Connectivity Provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService.instance;
});

/// Connectivity Status Provider
final connectivityStatusProvider =
    StreamProvider<List<ConnectivityResult>>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

/// Is Connected Provider
final isConnectedProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(connectivityServiceProvider);
  return await service.isConnected();
});

