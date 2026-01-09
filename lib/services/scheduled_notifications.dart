import 'dart:developer' as developer;
import 'notification_service.dart';

/// Scheduled Notifications Service
///
/// Handles all scheduled notification logic including:
/// - Warranty notifications (expiry reminders and periodic maintenance)
/// - Weekly laptop cleaning reminders
class ScheduledNotifications {
  final NotificationService _notificationService;

  ScheduledNotifications(this._notificationService);

  // Notification ID ranges
  static const int warrantyMaintenance1IdBase = 2000;
  static const int warrantyMaintenance2IdBase = 3000;
  static const int weeklyCleaningReminderId = 9999;
  static const int testRepeatingCleaningId = 8888;

  /// Schedule warranty-related notifications for a report
  ///
  /// Schedules:
  /// - Notification at first periodic maintenance date (6 months) - Egyptian slang
  /// - Notification at second periodic maintenance date (12 months) - Egyptian slang
  Future<void> scheduleWarrantyNotifications({
    required String reportId,
    required DateTime inspectionDate,
  }) async {
    try {
      // Generate unique notification IDs based on report ID hash
      final reportHash = reportId.hashCode.abs();
      final warranty3aMaintenanceId =
          warrantyMaintenance1IdBase + (reportHash % 900);
      final warranty3bMaintenanceId =
          warrantyMaintenance2IdBase + (reportHash % 900);

      final now = DateTime.now();

      // First periodic maintenance (6 months)
      final maintenancePeriodDays = 6 * 30;
      final warranty3aMaintenanceDate = inspectionDate.add(
        Duration(days: maintenancePeriodDays),
      );

      // Second periodic maintenance (12 months)
      final warranty3bMaintenanceDate = warranty3aMaintenanceDate.add(
        Duration(days: maintenancePeriodDays),
      );

      // Schedule first periodic maintenance notification - Egyptian slang
      if (warranty3aMaintenanceDate.isAfter(now)) {
        await _notificationService.scheduleNotification(
          id: warranty3aMaintenanceId,
          title: 'وقت الصيانة الدورية المجانية',
          body:
              'دلوقتي وقت الصيانة المجانية - الفترة الأولى. روح لـ Laapak واستفيد منها!',
          scheduledDate: warranty3aMaintenanceDate,
          payload: 'maintenance_period1|$reportId',
        );
      }

      // Schedule second periodic maintenance notification - Egyptian slang
      if (warranty3bMaintenanceDate.isAfter(now)) {
        await _notificationService.scheduleNotification(
          id: warranty3bMaintenanceId,
          title: 'وقت الصيانة الدورية المجانية',
          body:
              'دلوقتي وقت آخر صيانة مجانية - الفترة التانية. روح لـ Laapak دلوقتي!',
          scheduledDate: warranty3bMaintenanceDate,
          payload: 'maintenance_period2|$reportId',
        );
      }

      developer.log(
        '✅ Warranty notifications scheduled for report: $reportId',
        name: 'ScheduledNotifications',
      );
    } catch (e) {
      developer.log(
        '❌ Error scheduling warranty notifications: $e',
        name: 'ScheduledNotifications',
      );
    }
  }

  /// Cancel warranty notifications for a specific report
  Future<void> cancelWarrantyNotifications(String reportId) async {
    try {
      final reportHash = reportId.hashCode.abs();
      final warranty3aMaintenanceId =
          warrantyMaintenance1IdBase + (reportHash % 900);
      final warranty3bMaintenanceId =
          warrantyMaintenance2IdBase + (reportHash % 900);

      await _notificationService.cancelNotification(warranty3aMaintenanceId);
      await _notificationService.cancelNotification(warranty3bMaintenanceId);

      developer.log(
        '✅ Warranty notifications cancelled for report: $reportId',
        name: 'ScheduledNotifications',
      );
    } catch (e) {
      developer.log(
        '❌ Error cancelling warranty notifications: $e',
        name: 'ScheduledNotifications',
      );
    }
  }

  /// Schedule weekly laptop cleaning reminder
  ///
  /// Schedules a weekly notification (every Monday at 10 AM) to remind
  /// users to clean their laptop to prevent problems.
  /// Note: This needs to be rescheduled after each notification for true recurrence.
  Future<void> scheduleWeeklyCleaningReminder() async {
    try {
      // Calculate next Monday at 10 AM
      final now = DateTime.now();
      DateTime nextMonday;

      // Find next Monday
      int daysUntilMonday = (DateTime.monday - now.weekday) % 7;

      // If today is Monday
      if (daysUntilMonday == 0) {
        // If it's before 10 AM today, schedule for today
        if (now.hour < 10) {
          nextMonday = DateTime(now.year, now.month, now.day, 10, 0);
        } else {
          // It's after 10 AM, schedule for next Monday
          nextMonday = now.add(const Duration(days: 7));
          nextMonday = DateTime(
            nextMonday.year,
            nextMonday.month,
            nextMonday.day,
            10,
            0,
          );
        }
      } else {
        // Schedule for the upcoming Monday
        nextMonday = now.add(Duration(days: daysUntilMonday));
        nextMonday = DateTime(
          nextMonday.year,
          nextMonday.month,
          nextMonday.day,
          10,
          0,
        );
      }

      // Don't schedule if in the past (safety check)
      if (nextMonday.isBefore(now)) {
        nextMonday = nextMonday.add(const Duration(days: 7));
      }

      // Schedule the notification
      await _notificationService.scheduleNotification(
        id: weeklyCleaningReminderId,
        title: 'تنظيف اللاب! مهم جداً 😊',
        body: 'خد 10 دقائق وامسحه عشان تحميه من المشاكل!',
        scheduledDate: nextMonday,
        payload: 'weekly_cleaning_reminder',
      );

      developer.log(
        '✅ Weekly cleaning reminder scheduled for: $nextMonday',
        name: 'ScheduledNotifications',
      );
    } catch (e) {
      developer.log(
        '❌ Error scheduling weekly cleaning reminder: $e',
        name: 'ScheduledNotifications',
      );
    }
  }

  /// Cancel weekly cleaning reminder
  Future<void> cancelWeeklyCleaningReminder() async {
    try {
      await _notificationService.cancelNotification(weeklyCleaningReminderId);
      developer.log(
        '✅ Weekly cleaning reminder cancelled',
        name: 'ScheduledNotifications',
      );
    } catch (e) {
      developer.log(
        '❌ Error cancelling weekly cleaning reminder: $e',
        name: 'ScheduledNotifications',
      );
    }
  }

  /// Initialize all recurring notifications
  ///
  /// Should be called on app startup to ensure recurring notifications
  /// are properly scheduled. This also ensures that if a notification
  /// was fired but the app wasn't opened, it gets rescheduled for the next week.
  Future<void> initializeRecurringNotifications() async {
    try {
      // Always reschedule the weekly cleaning reminder
      // This ensures it's scheduled for the next Monday, even if:
      // 1. The previous notification already fired
      // 2. The user didn't tap the notification
      // 3. The app was closed when the notification fired
      // Using the same ID (9999) will overwrite any existing scheduled notification
      await scheduleWeeklyCleaningReminder();

      developer.log(
        '✅ Recurring notifications initialized',
        name: 'ScheduledNotifications',
      );
    } catch (e) {
      developer.log(
        '❌ Error initializing recurring notifications: $e',
        name: 'ScheduledNotifications',
      );
    }
  }

  /// Schedule a test repeating notification every 30 seconds for device cleaning
  /// This is for debugging notification scheduling issues
  Future<void> scheduleTestRepeatingCleaningNotification() async {
    try {
      final now = DateTime.now();
      final nextNotificationTime = now.add(const Duration(seconds: 30));

      await _notificationService.scheduleNotification(
        id: testRepeatingCleaningId,
        title: 'تنظيف اللاب! مهم جداً 😊 [TEST]',
        body: 'خد 10 دقائق وامسحه عشان تحميه من المشاكل! (اختبار كل 30 ثانية)',
        scheduledDate: nextNotificationTime,
        payload: 'test_repeating_cleaning',
        useExactScheduling: true, // Use exact scheduling for test notifications
      );

      developer.log(
        '✅ Test repeating cleaning notification scheduled for: $nextNotificationTime (every 30 seconds)',
        name: 'ScheduledNotifications',
      );
    } catch (e) {
      developer.log(
        '❌ Error scheduling test repeating cleaning notification: $e',
        name: 'ScheduledNotifications',
      );
    }
  }

  /// Cancel test repeating notification
  Future<void> cancelTestRepeatingCleaningNotification() async {
    try {
      await _notificationService.cancelNotification(testRepeatingCleaningId);
      developer.log(
        '✅ Test repeating cleaning notification cancelled',
        name: 'ScheduledNotifications',
      );
    } catch (e) {
      developer.log(
        '❌ Error cancelling test repeating cleaning notification: $e',
        name: 'ScheduledNotifications',
      );
    }
  }
}
