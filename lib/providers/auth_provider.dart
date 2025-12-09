import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client_model.dart';
import '../services/laapak_api_service.dart';
import '../services/storage_service.dart';
import '../services/error_handler_service.dart';
import '../utils/constants.dart';

/// Authentication State
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? token;
  final ClientModel? client;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.token,
    this.client,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? token,
    ClientModel? client,
    String? error,
    bool clearError = false,
    bool clearClient = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      client: clearClient ? null : (client ?? this.client),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Authentication Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final LaapakApiService _apiService;
  final StorageService _storageService;

  AuthNotifier(this._apiService, this._storageService) : super(const AuthState()) {
    developer.log('🔧 AuthNotifier constructor called', name: 'Auth');
    developer.log('   API Service: ${_apiService.runtimeType}', name: 'Auth');
    developer.log('   Storage Service: ${_storageService.runtimeType}', name: 'Auth');
    
    // Load saved session on initialization
    _loadSession();
  }

  /// Load saved session from storage
  Future<void> _loadSession() async {
    state = state.copyWith(isLoading: true);
    
    try {
      developer.log('🔍 Loading saved session from storage...', name: 'Auth');
      
      final token = await _storageService.getToken();
      final client = await _storageService.getClient();

      if (token != null && token.isNotEmpty && client != null) {
        developer.log('✅ Session restored successfully', name: 'Auth');
        developer.log('   Client: ${client.name} (ID: ${client.id})', name: 'Auth');
        developer.log('   Token: ${token.substring(0, 20)}...', name: 'Auth');
        
        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
          token: token,
          client: client,
          clearError: true,
        );
      } else {
        developer.log('ℹ️ No saved session found', name: 'Auth');
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      developer.log('❌ Failed to load session: $e', name: 'Auth');
      // If loading fails, clear storage
      await _storageService.clearAll();
      state = state.copyWith(isLoading: false);
    }
  }

  /// Login with phone and order code
  Future<void> login({
    required String phone,
    required String orderCode,
  }) async {
    developer.log('🔐 Attempting login...', name: 'Auth');
    developer.log('   Phone: $phone', name: 'Auth');
    developer.log('   Order Code: $orderCode', name: 'Auth');
    
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiService.clientLogin(
        phone: phone,
        orderCode: orderCode,
      );

      developer.log('📥 API Response received', name: 'Auth');
      developer.log('   Response keys: ${response.keys}', name: 'Auth');

      final token = response['token'] as String?;
      final clientData = response['client'] as Map<String, dynamic>?;

      if (token == null || clientData == null) {
        developer.log('❌ Invalid response: missing token or client data', name: 'Auth');
        throw Exception('Invalid response from server');
      }

      final client = ClientModel.fromJson(clientData);

      developer.log('✅ Login successful!', name: 'Auth');
      developer.log('   Client: ${client.name} (ID: ${client.id})', name: 'Auth');
      developer.log('   Phone: ${client.phone}', name: 'Auth');
      developer.log('   Order Code: ${client.orderCode}', name: 'Auth');
      developer.log('   Token: ${token.substring(0, 20)}...', name: 'Auth');

      // Save to secure storage
      developer.log('💾 Saving session to storage...', name: 'Auth');
      developer.log('   Storage Service type: ${_storageService.runtimeType}', name: 'Auth');
      
      // Try to save, but don't fail if storage is unavailable
      developer.log('   Attempting to save token...', name: 'Auth');
      await _storageService.saveToken(token);
      
      developer.log('   Attempting to save client data...', name: 'Auth');
      await _storageService.saveClient(client);
      
      developer.log('✅ Session save attempt completed', name: 'Auth');
      // Note: Storage methods now handle errors internally and log warnings
      // The login is successful regardless of storage status

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        token: token,
        client: client,
        clearError: true,
      );
      
      developer.log('🎉 Authentication state updated', name: 'Auth');
    } catch (e, stackTrace) {
      developer.log('❌ Login failed', name: 'Auth');
      developer.log('   Error type: ${e.runtimeType}', name: 'Auth');
      developer.log('   Error message: $e', name: 'Auth');
      
      // Use error handler service for user-friendly messages
      final errorHandler = ErrorHandlerService.instance;
      errorHandler.logError(e, stackTrace, context: 'Login');
      
      final errorMessage = errorHandler.getErrorMessage(
        e,
        defaultMessage: AppConstants.errorLoginFailed,
      );

      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
        clearClient: true,
      );
      
      developer.log('⚠️ Authentication state updated with error', name: 'Auth');
    }
  }

  /// Logout
  Future<void> logout() async {
    developer.log('🚪 Logging out...', name: 'Auth');
    
    // Clear storage
    await _storageService.clearAll();
    developer.log('✅ Storage cleared', name: 'Auth');
    
    // Clear state
    state = const AuthState();
    developer.log('✅ Authentication state cleared', name: 'Auth');
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Storage Service Provider
final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  developer.log('🔧 Creating StorageService instance...', name: 'Auth');
  try {
    final service = await StorageService.create();
    developer.log('✅ StorageService created successfully', name: 'Auth');
    return service;
  } catch (e, stackTrace) {
    developer.log('❌ Failed to create StorageService: $e', name: 'Auth');
    developer.log('   Stack trace: $stackTrace', name: 'Auth');
    rethrow;
  }
});

/// API Service Provider
final apiServiceProvider = Provider<LaapakApiService>((ref) {
  // For client login, we don't need API key or JWT initially
  // The service will be updated with JWT after login
  return LaapakApiService(
    apiKey: null,
    jwtToken: null,
    useDevelopment: false,
  );
});

/// Authentication Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  developer.log('🔧 Creating AuthNotifier...', name: 'Auth');
  final apiService = ref.read(apiServiceProvider);
  developer.log('   ✅ API Service obtained: ${apiService.runtimeType}', name: 'Auth');
  
  final storageServiceAsync = ref.watch(storageServiceProvider);
  
  // Wait for storage service to be ready
  return storageServiceAsync.when(
    data: (storageService) {
      developer.log('   ✅ Storage Service obtained: ${storageService.runtimeType}', name: 'Auth');
      final notifier = AuthNotifier(apiService, storageService);
      developer.log('✅ AuthNotifier created successfully', name: 'Auth');
      return notifier;
    },
      loading: () {
        developer.log('   ⏳ Storage Service loading...', name: 'Auth');
        // Return a notifier that will be updated when storage is ready
        // For now, create a temporary one that will fail gracefully
        return AuthNotifier(apiService, StorageService.empty());
      },
      error: (error, stackTrace) {
        developer.log('❌ Failed to get StorageService: $error', name: 'Auth');
        developer.log('   Stack trace: $stackTrace', name: 'Auth');
        // Return a notifier with empty storage (will use file-based fallback)
        return AuthNotifier(apiService, StorageService.empty());
      },
  );
});

/// Authenticated API Service Provider
/// This provider returns an API service instance with the JWT token from auth state
final authenticatedApiServiceProvider = Provider<LaapakApiService?>((ref) {
  final authState = ref.watch(authProvider);
  
  if (authState.token == null) {
    return null;
  }

  return LaapakApiService(
    apiKey: null,
    jwtToken: authState.token,
    useDevelopment: false,
  );
});

