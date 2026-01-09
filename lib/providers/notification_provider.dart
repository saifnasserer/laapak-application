import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../providers/auth_provider.dart';

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
      developer.log(
        '✅ Notifications initialized successfully',
        name: 'Notifications',
      );

      // Request permissions after initialization (for Android 13+)
      try {
        await notificationService.requestPermissions();

        // Initialize recurring notifications (weekly cleaning reminder)
        try {
          await notificationService.scheduledNotifications
              .initializeRecurringNotifications();
        } catch (e) {
          developer.log(
            '⚠️ Error initializing recurring notifications: $e',
            name: 'Notifications',
          );
        }
      } catch (e) {
        developer.log(
          '⚠️ Permission request failed: $e',
          name: 'Notifications',
        );
      }
    } else {
      developer.log(
        '⚠️ Notifications initialization failed',
        name: 'Notifications',
      );
    }

    return initialized;
  } catch (e, stackTrace) {
    developer.log(
      '❌ Error initializing notifications: $e',
      name: 'Notifications',
    );
    developer.log('   Stack trace: $stackTrace', name: 'Notifications');
    return false;
  }
});

/// Request notification permissions provider
final requestNotificationPermissionsProvider = FutureProvider.autoDispose<bool>(
  (ref) async {
    final notificationService = ref.read(notificationServiceProvider);
    final result = await notificationService.requestPermissions();
    return result ?? false;
  },
);

/// Check notification permissions status provider
final notificationPermissionsStatusProvider = FutureProvider.autoDispose<bool?>(
  (ref) async {
    final notificationService = ref.read(notificationServiceProvider);
    return await notificationService.areNotificationsEnabled();
  },
);

/// Notification preference provider (user setting)
final notificationPreferenceProvider = FutureProvider.autoDispose<bool>((
  ref,
) async {
  try {
    final storageServiceAsync = ref.watch(storageServiceProvider);
    return await storageServiceAsync.when(
      data: (storageService) => storageService.getNotificationsEnabled(),
      loading: () => Future.value(true), // Default to enabled
      error: (_, __) => Future.value(true), // Default to enabled on error
    );
  } catch (e) {
    developer.log(
      '⚠️ Error getting notification preference: $e',
      name: 'Notifications',
    );
    return true; // Default to enabled
  }
});

/// Set notification preference provider
final setNotificationPreferenceProvider = FutureProvider.autoDispose
    .family<bool, bool>((ref, enabled) async {
      try {
        final storageServiceAsync = ref.read(storageServiceProvider);
        final storageService = storageServiceAsync.value;
        if (storageService != null) {
          await storageService.setNotificationsEnabled(enabled);
          // Invalidate preference provider to refresh
          ref.invalidate(notificationPreferenceProvider);
          return true;
        }
        return false;
      } catch (e) {
        developer.log(
          '⚠️ Error setting notification preference: $e',
          name: 'Notifications',
        );
        return false;
      }
    });
