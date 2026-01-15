import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:developer' as developer;
import 'dart:io';
import 'scheduled_notifications.dart';
import 'navigation_service.dart';
import '../screens/warranty/warranty_screen.dart';
import '../screens/device_care/device_care_screen.dart';

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
  bool _timezoneInitialized = false;
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

  /// Initialize timezone data
  Future<void> _initializeTimezone() async {
    if (_timezoneInitialized) {
      return;
    }

    try {
      tz.initializeTimeZones();
      // The local timezone is automatically set by the system
      _timezoneInitialized = true;
      developer.log('✅ Timezone initialized', name: 'Notifications');
    } catch (e) {
      developer.log(
        '⚠️ Error initializing timezone: $e',
        name: 'Notifications',
      );
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
      // Initialize timezone for scheduled notifications
      await _initializeTimezone();
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

        // Request permissions on Android 13+ immediately during initialization
        if (Platform.isAndroid) {
          developer.log(
            '📱 Requesting notification permissions during initialization...',
            name: 'Notifications',
          );
          final granted = await _requestAndroidPermissions();
          if (granted != null && granted == true) {
            developer.log(
              '✅ Notification permissions granted on initialization',
              name: 'Notifications',
            );
          } else if (granted == null) {
            developer.log(
              '⚠️ Notification permissions denied - user needs to enable in settings',
              name: 'Notifications',
            );
          } else {
            developer.log(
              '⚠️ Notification permissions not granted',
              name: 'Notifications',
            );
          }
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
  /// Returns true if granted, false if denied, null if permanently denied (should open settings)
  Future<bool?> _requestAndroidPermissions({bool forceRequest = false}) async {
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

      // Check if permission is already granted first
      final bool? granted = await androidImplementation
          .areNotificationsEnabled();

      if (granted == true && !forceRequest) {
        developer.log(
          '✅ Notification permissions already granted',
          name: 'Notifications',
        );
        return true;
      }

      // Request permission - this will show the system dialog on Android 13+
      developer.log(
        '📱 Requesting notification permission...',
        name: 'Notifications',
      );

      final bool? result = await androidImplementation
          .requestNotificationsPermission();

      developer.log(
        '📱 Permission request result: $result',
        name: 'Notifications',
      );

      // Wait a moment for the system to update permission status
      await Future.delayed(const Duration(milliseconds: 500));

      // Check the actual permission status after requesting
      final bool? currentStatus = await androidImplementation
          .areNotificationsEnabled();

      developer.log(
        '📱 Current permission status after request: $currentStatus',
        name: 'Notifications',
      );

      if (currentStatus == true) {
        developer.log(
          '✅ Notification permissions granted',
          name: 'Notifications',
        );
        return true;
      } else if (currentStatus == false) {
        developer.log(
          '⚠️ Notification permissions denied by user',
          name: 'Notifications',
        );
        // Return null to indicate user denied and may need to enable in settings
        return null;
      } else {
        developer.log(
          '⚠️ Notification permission status unclear',
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

  /// Check if notification permissions are granted
  Future<bool?> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _notificationsPlugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        if (androidImplementation == null) {
          return null;
        }

        return await androidImplementation.areNotificationsEnabled();
      } else if (Platform.isIOS) {
        // For iOS, we check by trying to get permission status
        // iOS permissions are handled during initialization
        // This is a simplified check - actual permission status requires platform channels
        return true; // iOS typically grants during initialization
      }
      return true;
    } catch (e) {
      developer.log(
        '❌ Error checking notification permissions: $e',
        name: 'Notifications',
      );
      return null;
    }
  }

  /// Request notification permissions (public method)
  /// Returns: true if granted, false if denied, null if permanently denied (should open settings)
  Future<bool?> requestPermissions({bool forceRequest = false}) async {
    if (!_initialized) {
      final initialized = await initialize();
      if (!initialized) {
        return false;
      }
    }

    // On iOS, try to request permissions if not already granted
    if (Platform.isIOS) {
      try {
        // iOS permissions are typically requested during initialization
        // but we can check the status
        final bool? enabled = await areNotificationsEnabled();

        // If not enabled, try showing a test notification to trigger permission request
        if (enabled != true) {
          developer.log(
            '📱 Requesting iOS notification permissions...',
            name: 'Notifications',
          );
          // Show a silent test notification to trigger permission request
          try {
            await _notificationsPlugin.show(
              999999,
              '',
              '',
              const NotificationDetails(
                iOS: DarwinNotificationDetails(
                  presentAlert: false,
                  presentBadge: false,
                  presentSound: false,
                ),
              ),
            );
            // Cancel it immediately
            await _notificationsPlugin.cancel(999999);
          } catch (e) {
            // Ignore errors - this is just to trigger permission request
          }

          // Wait a moment and check again
          await Future.delayed(const Duration(milliseconds: 500));
          final bool? newStatus = await areNotificationsEnabled();
          return newStatus == true ? true : null;
        }

        return enabled == true;
      } catch (e) {
        developer.log(
          '⚠️ Error requesting iOS permissions: $e',
          name: 'Notifications',
        );
        return null;
      }
    }

    // On Android, request runtime permission (will show system dialog)
    return await _requestAndroidPermissions(forceRequest: forceRequest);
  }

  // Note: Exact alarm methods removed - app now uses inexact scheduling only
  // This avoids the need for USE_EXACT_ALARM permission which is restricted
  // to calendar and alarm clock apps only

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    developer.log(
      '🔔 Notification tapped: ${response.id}',
      name: 'Notifications',
    );

    final payload = response.payload ?? '';

    // Handle navigation based on payload
    final navigator = NavigationService.instance.navigator;
    if (navigator == null) {
      developer.log(
        '⚠️ Navigator not available for notification tap',
        name: 'Notifications',
      );
      return;
    }

    // Reschedule for next 30 seconds (fire and forget)
    if (payload == 'test_repeating_cleaning') {
      scheduledNotifications.scheduleTestRepeatingCleaningNotification();
      return;
    }

    // Weekly cleaning reminder - navigate to device care screen (cleaning step)
    if (payload == 'weekly_cleaning_reminder' ||
        payload == 'test_weekly_cleaning') {
      scheduledNotifications.scheduleWeeklyCleaningReminder();

      // Navigate to device care screen at cleaning step (step 1, index 1)
      navigator.push(
        MaterialPageRoute(
          builder: (context) => const DeviceCareScreen(initialStep: 1),
        ),
      );
      return;
    }

    // Warranty notifications - navigate to warranty screen
    if (payload.startsWith('maintenance_period1') ||
        payload.startsWith('maintenance_period2') ||
        payload == 'test_maintenance') {
      // Extract report ID from payload if available
      String? reportId;
      if (payload.contains('|')) {
        reportId = payload.split('|').last;
      }

      // Navigate to warranty screen
      navigator.push(
        MaterialPageRoute(
          builder: (context) => WarrantyScreen(reportId: reportId),
        ),
      );
      return;
    }

    developer.log(
      'ℹ️ No navigation handler for payload: $payload',
      name: 'Notifications',
    );
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
        if (granted == null || granted == false) {
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

  /// Show a test maintenance notification
  Future<void> showTestMaintenanceNotification() async {
    await showNotification(
      id: 998,
      title: 'وقت الصيانة الدورية المجانية',
      body:
          'دلوقتي وقت الصيانة المجانية - الفترة الأولى. روح لـ Laapak واستفيد منها!',
      payload: 'test_maintenance',
    );
  }

  /// Show a test weekly cleaning notification
  Future<void> showTestWeeklyCleaningNotification() async {
    await showNotification(
      id: 997,
      title: 'تنظيف اللاب! مهم جداً 😊',
      body: 'خد 10 دقائق وامسحه عشان تحميه من المشاكل!',
      payload: 'test_weekly_cleaning',
    );
  }

  /// Start test repeating notification (every 30 seconds)
  /// This is for debugging notification scheduling
  Future<void> startTestRepeatingNotification() async {
    await scheduledNotifications.scheduleTestRepeatingCleaningNotification();
  }

  /// Stop test repeating notification
  Future<void> stopTestRepeatingNotification() async {
    await scheduledNotifications.cancelTestRepeatingCleaningNotification();
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

  /// Schedule a notification at a specific date and time
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    bool useExactScheduling =
        false, // For test notifications, use exact scheduling
  }) async {
    if (!_initialized) {
      developer.log(
        '⚠️ Notifications not initialized. Initializing now...',
        name: 'Notifications',
      );
      final initialized = await initialize();
      if (!initialized) {
        developer.log(
          '❌ Cannot schedule notification: service not initialized',
          name: 'Notifications',
        );
        return;
      }
    }

    final now = DateTime.now();
    // Don't schedule if the date is in the past
    if (scheduledDate.isBefore(now)) {
      developer.log(
        '⚠️ Cannot schedule notification: scheduled date is in the past',
        name: 'Notifications',
      );
      return;
    }

    // Check and request permissions on Android 13+
    if (Platform.isAndroid) {
      final bool? enabled = await areNotificationsEnabled();
      if (enabled == false) {
        developer.log(
          '⚠️ Notifications disabled - requesting permission...',
          name: 'Notifications',
        );
        final granted = await requestPermissions();
        if (granted == null || granted == false) {
          developer.log(
            '❌ Cannot schedule notification: permissions not granted',
            name: 'Notifications',
          );
          return;
        }
      }
    }

    try {
      // Initialize timezone if not already done
      await _initializeTimezone();

      // Get notification icon paths
      String? largeIconPath;
      if (Platform.isAndroid) {
        largeIconPath = await _getNotificationIconPath();
      }

      // Android notification details
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

      // Notification details
      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Convert DateTime to TZDateTime
      final scheduledTZDate = tz.TZDateTime.from(scheduledDate, tz.local);

      // Choose scheduling mode: exact for test notifications, inexact for production
      AndroidScheduleMode scheduleMode = AndroidScheduleMode.inexact;
      if (useExactScheduling) {
        scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;
      }

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZDate,
        notificationDetails,
        androidScheduleMode: scheduleMode,
        payload: payload,
      );

      developer.log(
        '✅ Notification scheduled with ${useExactScheduling ? "exact" : "inexact"} mode: $title at $scheduledDate (ID: $id)',
        name: 'Notifications',
      );
    } catch (e) {
      developer.log(
        '❌ Unexpected error in scheduleNotification: $e',
        name: 'Notifications',
      );
    }
  }

  /// Get an instance of ScheduledNotifications for managing scheduled notifications
  ScheduledNotifications get scheduledNotifications {
    return ScheduledNotifications(this);
  }
}
