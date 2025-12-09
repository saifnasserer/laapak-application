import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:developer' as developer;
import 'dart:io';

/// Notification Service
///
/// Handles local notifications for the app
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _notificationIconPath;

  /// Get notification large icon from asset (Logo-mark.png)
  Future<String?> _getNotificationIconPath() async {
    if (_notificationIconPath != null) {
      return _notificationIconPath;
    }

    try {
      // Load the asset as bytes
      final ByteData data = await rootBundle.load('assets/logo/Logo-mark.png');
      final Uint8List bytes = data.buffer.asUint8List();

      // Get application documents directory
      final Directory tempDir = await getTemporaryDirectory();
      final File iconFile = File('${tempDir.path}/notification_icon.png');

      // Write the asset to a temporary file
      await iconFile.writeAsBytes(bytes);

      _notificationIconPath = iconFile.path;
      developer.log(
        '✅ Notification large icon prepared: $_notificationIconPath',
        name: 'Notifications',
      );
      return _notificationIconPath;
    } catch (e) {
      developer.log(
        '❌ Error preparing notification large icon: $e',
        name: 'Notifications',
      );
      return null;
    }
  }

  /// Initialize the notification service
  Future<bool> initialize() async {
    if (_initialized) {
      developer.log(
        '📱 Notifications already initialized',
        name: 'Notifications',
      );
      return true;
    }

    try {
      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      // Initialization settings
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialize the plugin
      final bool? initialized = await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        _initialized = true;
        developer.log(
          '✅ Notifications initialized successfully',
          name: 'Notifications',
        );

        // Request permissions on Android 13+ (don't await to avoid blocking initialization)
        if (Platform.isAndroid) {
          _requestAndroidPermissions().then((granted) {
            if (granted) {
              developer.log(
                '✅ Notification permissions granted on initialization',
                name: 'Notifications',
              );
            } else {
              developer.log(
                '⚠️ Notification permissions not granted - user may need to enable in settings',
                name: 'Notifications',
              );
            }
          });
        }

        return true;
      } else {
        developer.log(
          '❌ Failed to initialize notifications',
          name: 'Notifications',
        );
        return false;
      }
    } catch (e) {
      developer.log(
        '❌ Error initializing notifications: $e',
        name: 'Notifications',
      );
      return false;
    }
  }

  /// Request Android permissions (Android 13+)
  Future<bool> _requestAndroidPermissions() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation == null) {
        developer.log(
          '⚠️ Android implementation not available',
          name: 'Notifications',
        );
        return false;
      }

      // Check if permission is already granted
      final bool? granted = await androidImplementation
          .areNotificationsEnabled();

      if (granted == true) {
        developer.log(
          '✅ Notification permissions already granted',
          name: 'Notifications',
        );
        return true;
      }

      // Request permission
      final bool? result = await androidImplementation
          .requestNotificationsPermission();

      if (result == true) {
        developer.log(
          '✅ Notification permissions granted',
          name: 'Notifications',
        );
        return true;
      } else {
        developer.log(
          '❌ Notification permissions denied',
          name: 'Notifications',
        );
        return false;
      }
    } catch (e) {
      developer.log(
        '❌ Error requesting notification permissions: $e',
        name: 'Notifications',
      );
      return false;
    }
  }

  /// Check if notification permissions are granted (Android 13+)
  Future<bool?> areNotificationsEnabled() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();

      if (androidImplementation == null) {
        return null;
      }

      return await androidImplementation.areNotificationsEnabled();
    } catch (e) {
      developer.log(
        '❌ Error checking notification permissions: $e',
        name: 'Notifications',
      );
      return null;
    }
  }

  /// Request notification permissions (public method)
  Future<bool> requestPermissions() async {
    if (!_initialized) {
      await initialize();
    }
    return await _requestAndroidPermissions();
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    developer.log(
      '🔔 Notification tapped: ${response.id}',
      name: 'Notifications',
    );
    // Handle notification tap logic here if needed
  }

  /// Show a simple notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      developer.log(
        '⚠️ Notifications not initialized. Initializing now...',
        name: 'Notifications',
      );
      final initialized = await initialize();
      if (!initialized) {
        developer.log(
          '❌ Cannot show notification: service not initialized',
          name: 'Notifications',
        );
        return;
      }
    }

    // Check and request permissions on Android 13+ before showing notification
    if (Platform.isAndroid) {
      final bool? enabled = await areNotificationsEnabled();
      if (enabled == false) {
        developer.log(
          '⚠️ Notifications disabled - requesting permission...',
          name: 'Notifications',
        );
        final granted = await requestPermissions();
        if (!granted) {
          developer.log(
            '❌ Cannot show notification: permissions not granted',
            name: 'Notifications',
          );
          return;
        }
      }
    }

    try {
      // Get notification icon paths
      String? largeIconPath;
      if (Platform.isAndroid) {
        largeIconPath = await _getNotificationIconPath();
      }

      // Android notification details with custom icons
      // Small icon uses drawable resource (noti_ico.png copied to drawable/notification_icon.png)
      // Large icon uses asset file path
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'laapak_channel',
            'Laapak Notifications',
            channelDescription: 'Notifications for Laapak app',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            icon: '@drawable/notification_icon',
            largeIcon: largeIconPath != null
                ? FilePathAndroidBitmap(largeIconPath)
                : const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
          );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Notification details (non-const because androidDetails is dynamic)
      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      developer.log('✅ Notification shown: $title', name: 'Notifications');
    } catch (e) {
      developer.log('❌ Error showing notification: $e', name: 'Notifications');
    }
  }

  /// Show a test notification
  Future<void> showTestNotification() async {
    await showNotification(
      id: 0,
      title: 'إشعار تجريبي',
      body: 'هذا إشعار تجريبي من تطبيق Laapak',
      payload: 'test',
    );
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notificationsPlugin.cancel(id);
      developer.log('✅ Notification cancelled: $id', name: 'Notifications');
    } catch (e) {
      developer.log(
        '❌ Error cancelling notification: $e',
        name: 'Notifications',
      );
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
      developer.log('✅ All notifications cancelled', name: 'Notifications');
    } catch (e) {
      developer.log(
        '❌ Error cancelling all notifications: $e',
        name: 'Notifications',
      );
    }
  }
}
