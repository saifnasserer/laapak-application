import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../theme/theme.dart';
import '../../../utils/responsive.dart';

/// Hardware Status Step Widget
///
/// Displays the status of hardware components
class HardwareStatusStep extends StatelessWidget {
  final Map<String, dynamic> reportData;

  const HardwareStatusStep({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    // Debug: Log all report data keys
    debugPrint('📊 Report Data Keys: ${reportData.keys}');
    debugPrint('📊 Report Data: $reportData');

    List<Map<String, dynamic>> hardwareStatus = [];

    try {
      // Try different possible field names
      final statusJson =
          reportData['hardware_status'] as String? ??
          reportData['hardwareStatus'] as String? ??
          reportData['hardware_status_json'] as String?;

      debugPrint('📊 Hardware Status JSON: $statusJson');

      if (statusJson != null && statusJson.isNotEmpty) {
        // Try parsing as JSON string
        final decoded = jsonDecode(statusJson);
        if (decoded is List) {
          hardwareStatus = List<Map<String, dynamic>>.from(
            decoded.map((e) => e as Map<String, dynamic>),
          );
        } else if (decoded is Map) {
          // If it's a single object, wrap it in a list
          hardwareStatus = [decoded as Map<String, dynamic>];
        }
        debugPrint('📊 Parsed Hardware Status: $hardwareStatus');
      } else {
        // Try if it's already a list/object
        if (reportData['hardware_status'] is List) {
          hardwareStatus = List<Map<String, dynamic>>.from(
            (reportData['hardware_status'] as List).map(
              (e) => e as Map<String, dynamic>,
            ),
          );
        } else if (reportData['hardware_status'] is Map) {
          hardwareStatus = [
            reportData['hardware_status'] as Map<String, dynamic>,
          ];
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing hardware_status: $e');
      debugPrint('   Stack trace: $stackTrace');
    }

    if (hardwareStatus.isEmpty) {
      return Center(
        child: Padding(
          padding: Responsive.screenPaddingV,
          child: Text(
            'لا توجد معلومات عن المكونات',
            style: LaapakTypography.bodyMedium(
              color: LaapakColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: Responsive.lg),
        Card(
          child: Padding(
            padding: Responsive.cardPaddingInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'حالة المكونات',
                  style: LaapakTypography.titleLarge(
                    color: LaapakColors.textPrimary,
                  ),
                ),
                SizedBox(height: Responsive.md),
                ...hardwareStatus.map(
                  (component) => Padding(
                    padding: EdgeInsets.only(bottom: Responsive.sm),
                    child: _buildComponentStatus(component),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Success Message - Always visible
        Card(
          margin: EdgeInsets.only(top: Responsive.md),
          color: LaapakColors.success.withValues(alpha: 0.1),
          child: Padding(
            padding: Responsive.cardPaddingInsets,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: LaapakColors.success,
                  size: Responsive.iconSizeMedium,
                ),
                SizedBox(width: Responsive.sm),
                Expanded(
                  child: Text(
                    'تم اختبار وتشغيل جميع المكونات المذكورة والتأكد انها تعمل بشكل كامل',
                    style: LaapakTypography.bodyMedium(
                      color: LaapakColors.success,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: Responsive.xl),
      ],
    );
  }

  /// Build component status row
  Widget _buildComponentStatus(Map<String, dynamic> component) {
    // Try different possible field names (API uses componentName in camelCase)
    final componentName =
        component['componentName']?.toString() ??
        component['component']?.toString() ??
        component['name']?.toString() ??
        component['component_name']?.toString() ??
        'Unknown';

    final status =
        component['status']?.toString() ??
        component['condition']?.toString() ??
        component['state']?.toString() ??
        'unknown';

    String statusText;
    Color statusColor;

    switch (status.toLowerCase()) {
      case 'working':
        statusText = 'تم الفحص';
        statusColor = LaapakColors.success;
        break;
      case 'not_available':
      case 'notavailable':
      case 'not available':
        statusText = 'غير متاح';
        statusColor = LaapakColors.textSecondary;
        break;
      // Legacy status values (for backward compatibility)
      case 'excellent':
      case 'good':
        statusText = 'تم الفحص';
        statusColor = LaapakColors.success;
        break;
      case 'fair':
      case 'acceptable':
        statusText = 'مقبول';
        statusColor = LaapakColors.warning;
        break;
      case 'poor':
      case 'bad':
      case 'not_working':
      case 'broken':
        statusText = 'ضعيف';
        statusColor = LaapakColors.error;
        break;
      default:
        statusText = status;
        statusColor = LaapakColors.textSecondary;
    }

    // Map component names to Arabic (case-insensitive matching)
    final componentNames = {
      'screen': 'الشاشة',
      'battery': 'البطارية',
      'camera': 'الكاميرا',
      'speakers': 'مكبرات الصوت',
      'speaker': 'مكبر الصوت',
      'microphone': 'الميكروفون',
      'charging_port': 'منفذ الشحن',
      'buttons': 'الأزرار',
      'housing': 'الهيكل',
      'wi-fi': 'واي فاي',
      'wifi': 'واي فاي',
      'lan': 'شبكة محلية',
      'ports': 'المنافذ',
      'keyboard': 'لوحة المفاتيح',
      'touchpad': 'لوحة اللمس',
      'card': 'البطاقة',
      'audio_jack': 'منفذ الصوت',
      'audiojack': 'منفذ الصوت',
      'displayport': 'منفذ العرض',
      'bluetooth': 'بلوتوث',
    };

    // Normalize component name for lookup (lowercase, remove spaces/special chars)
    final normalizedName = componentName.toLowerCase().replaceAll(
      RegExp(r'[-\s_]'),
      '',
    );
    final arabicName = componentNames.entries
        .firstWhere(
          (entry) =>
              entry.key.toLowerCase().replaceAll(RegExp(r'[-\s_]'), '') ==
              normalizedName,
          orElse: () =>
              MapEntry('', componentName), // Return original if not found
        )
        .value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          arabicName.isNotEmpty ? arabicName : componentName,
          style: LaapakTypography.bodyMedium(color: LaapakColors.textPrimary),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.sm,
            vertical: Responsive.xs,
          ),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            statusText,
            style: LaapakTypography.labelSmall(color: statusColor),
          ),
        ),
      ],
    );
  }
}
