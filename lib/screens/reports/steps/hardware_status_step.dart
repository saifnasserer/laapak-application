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
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'working':
        statusText = 'تم الفحص';
        statusColor = LaapakColors.success;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'not_available':
      case 'notavailable':
      case 'not available':
        statusText = 'غير متاح';
        statusColor = LaapakColors.textSecondary;
        statusIcon = Icons.cancel_outlined;
        break;
      // Legacy status values (for backward compatibility)
      case 'excellent':
      case 'good':
        statusText = 'تم الفحص';
        statusColor = LaapakColors.success;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'fair':
      case 'acceptable':
        statusText = 'مقبول';
        statusColor = LaapakColors.warning;
        statusIcon = Icons.info_outline;
        break;
      case 'poor':
      case 'bad':
      case 'not_working':
      case 'broken':
        statusText = 'ضعيف';
        statusColor = LaapakColors.error;
        statusIcon = Icons.error_outline;
        break;
      default:
        statusText = status;
        statusColor = LaapakColors.textSecondary;
        statusIcon = Icons.help_outline;
    }

    // Map component names to Arabic (case-insensitive matching)
    // Map component names to Arabic (case-insensitive matching)
    final componentNames = {
      'screen': 'الشاشة',
      'battery': 'البطارية',
      'camera': 'الكاميرا',
      'cam': 'الكاميرا',
      'webcam': 'الكاميرا',
      'speakers': 'السماعات',
      'speaker': 'السماعات',
      'audio': 'السماعات',
      'sound': 'السماعات',
      'microphone': 'الميكروفون',
      'mic': 'الميكروفون',
      'charging_port': 'منفذ الشحن',
      'buttons': 'الأزرار',
      'housing': 'الهيكل',
      'wi-fi': 'Wi-Fi',
      'wifi': 'Wi-Fi',
      'lan': 'منفذ Ethernet (LAN) بالجهاز',
      'ethernet': 'منفذ Ethernet (LAN) بالجهاز',
      'ports': 'المنافذ',
      'usb': 'منافذ USB,Type-C',
      'type-c': 'منافذ USB,Type-C',
      'keyboard': 'لوحة المفاتيح',
      'touchpad': 'Touchpad',
      'mouse': 'Touchpad',
      'card': 'Card Reader',
      'sd': 'Card Reader',
      'reader': 'Card Reader',
      'audio_jack': 'منفذ الصوت',
      'audiojack': 'منفذ الصوت',
      'headphone': 'منفذ الصوت',
      'displayport': 'منفذ العرض (HDMI)',
      'hdmi': 'منفذ العرض (HDMI)',
      'bluetooth': 'بلوتوث',
      'fan': 'المراوح',
      'cpu': 'المعالج',
      'gpu': 'كارت الشاشة',
      'ram': 'الذاكرة العشوائية',
      'hdd': 'التخزين',
      'ssd': 'التخزين',
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

    return Container(
      margin: EdgeInsets.only(bottom: Responsive.md),
      padding: EdgeInsets.all(Responsive.sm),
      decoration: BoxDecoration(
        color: LaapakColors.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(Responsive.cardRadius),
        border: Border.all(color: LaapakColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          // Component Icon
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: LaapakColors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getComponentIcon(componentName),
              color: LaapakColors.primary,
              size: 20,
            ),
          ),
          SizedBox(width: Responsive.md),

          // Name
          Expanded(
            child: Text(
              arabicName.isNotEmpty ? arabicName : componentName,
              style: LaapakTypography.titleSmall(
                color: LaapakColors.textPrimary,
              ),
            ),
          ),

          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 14, color: statusColor),
                SizedBox(width: 4),
                Text(
                  statusText,
                  style: LaapakTypography.labelSmall(
                    color: statusColor,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Get icon for component type
  IconData _getComponentIcon(String component) {
    final comp = component.toLowerCase();
    if (comp.contains('cpu') || comp.contains('processor')) return Icons.memory;
    if (comp.contains('gpu') || comp.contains('graphics')) {
      return Icons.videogame_asset;
    }
    if (comp.contains('hdd') ||
        comp.contains('ssd') ||
        comp.contains('storage')) {
      return Icons.storage;
    }
    if (comp.contains('ram') || comp.contains('memory')) {
      return Icons.memory_outlined;
    }
    if (comp.contains('battery')) return Icons.battery_charging_full;
    if (comp.contains('keyboard')) return Icons.keyboard;
    if (comp.contains('screen') ||
        comp.contains('display') ||
        comp.contains('lcd')) {
      return Icons.monitor;
    }
    if (comp.contains('camera') || comp.contains('webcam')) {
      return Icons.camera_alt;
    }
    if (comp.contains('speaker') ||
        comp.contains('audio') ||
        comp.contains('sound')) {
      return Icons.volume_up;
    }
    if (comp.contains('mic')) return Icons.mic;
    if (comp.contains('wifi') ||
        comp.contains('network') ||
        comp.contains('lan')) {
      return Icons.wifi;
    }
    if (comp.contains('bluetooth')) return Icons.bluetooth;
    if (comp.contains('port') || comp.contains('usb')) return Icons.usb;
    if (comp.contains('touchpad') || comp.contains('mouse')) return Icons.mouse;
    if (comp.contains('fan') || comp.contains('cool')) return Icons.ac_unit;
    return Icons.devices_other;
  }
}
