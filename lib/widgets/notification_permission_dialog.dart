import 'package:flutter/material.dart';
import 'package:app_settings/app_settings.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';

/// Notification Permission Dialog
///
/// Shows instructions on how to enable notifications in app settings
/// with a button to open the app settings directly
class NotificationPermissionDialog extends StatelessWidget {
  const NotificationPermissionDialog({super.key});

  /// Show the notification permission dialog
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const NotificationPermissionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Responsive.cardRadius),
        ),
        backgroundColor: LaapakColors.surface,
        child: Padding(
          padding: Responsive.cardPaddingInsets,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Icon
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: LaapakColors.warning.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_off_outlined,
                    size: 32,
                    color: LaapakColors.warning,
                  ),
                ),
              ),

              SizedBox(height: Responsive.lg),

              // Title
              Text(
                'تفعيل الإشعارات',
                style: LaapakTypography.titleLarge(
                  color: LaapakColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: Responsive.md),

              // Instructions
              Text(
                'لتفعيل الإشعارات، يرجى اتباع الخطوات التالية:',
                style: LaapakTypography.bodyMedium(
                  color: LaapakColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: Responsive.lg),

              // Steps
              _buildStep(
                number: 1,
                text: 'اضغط على زر "فتح الإعدادات" أدناه',
              ),
              SizedBox(height: Responsive.md),
              _buildStep(
                number: 2,
                text: 'ابحث عن "الإشعارات" أو "Notifications"',
              ),
              SizedBox(height: Responsive.md),
              _buildStep(
                number: 3,
                text: 'فعّل الإشعارات للتطبيق',
              ),

              SizedBox(height: Responsive.xl),

              // Open Settings Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    AppSettings.openAppSettings(
                      type: AppSettingsType.notification,
                    );
                  },
                  icon: Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'فتح الإعدادات',
                    style: LaapakTypography.button(
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LaapakColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: Responsive.lg,
                      vertical: Responsive.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Responsive.buttonRadius),
                    ),
                  ),
                ),
              ),

              SizedBox(height: Responsive.md),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'إلغاء',
                    style: LaapakTypography.button(
                      color: LaapakColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({required int number, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: LaapakColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$number',
              style: LaapakTypography.labelMedium(
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: Responsive.md),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: LaapakTypography.bodyMedium(
                color: LaapakColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

