import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

/// Notification Service Provider
/// 
/// Provides access to the notification service singleton
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Initialize notifications on app startup
final initializeNotificationsProvider = FutureProvider<bool>((ref) async {
  final notificationService = ref.read(notificationServiceProvider);
  
  try {
    developer.log('🔧 Initializing notifications...', name: 'Notifications');
    final initialized = await notificationService.initialize();
    
    if (initialized) {
      developer.log('✅ Notifications initialized successfully', name: 'Notifications');
      
      // Request permissions after initialization (for Android 13+)
      try {
        await notificationService.requestPermissions();
      } catch (e) {
        developer.log('⚠️ Permission request failed: $e', name: 'Notifications');
      }
    } else {
      developer.log('⚠️ Notifications initialization failed', name: 'Notifications');
    }
    
    return initialized;
  } catch (e, stackTrace) {
    developer.log('❌ Error initializing notifications: $e', name: 'Notifications');
    developer.log('   Stack trace: $stackTrace', name: 'Notifications');
    return false;
  }
});

/// Request notification permissions provider
final requestNotificationPermissionsProvider = FutureProvider.autoDispose<bool>((ref) async {
  final notificationService = ref.read(notificationServiceProvider);
  return await notificationService.requestPermissions();
});

/// Check notification permissions status provider
final notificationPermissionsStatusProvider = FutureProvider.autoDispose<bool?>((ref) async {
  final notificationService = ref.read(notificationServiceProvider);
  return await notificationService.areNotificationsEnabled();
});

