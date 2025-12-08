import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/dismiss_keyboard.dart';

/// Warranty Tracker Screen
///
/// Displays warranty information and status based on report data.
/// Shows warranty duration, expiry date, and status with daily countdown.
class WarrantyScreen extends StatefulWidget {
  const WarrantyScreen({super.key});

  @override
  State<WarrantyScreen> createState() => _WarrantyScreenState();
}

class _WarrantyScreenState extends State<WarrantyScreen> {
  // Mock data - replace with actual API data
  final Map<String, dynamic> reportData = {
    'id': 'RPT123456',
    'device_model': 'iPhone 15 Pro Max',
    'serial_number': 'ABC123456789',
    'inspection_date': '2024-01-15T10:00:00Z',
    'status': 'active',
    'created_at': '2024-01-15T10:00:00Z',
  };

  @override
  void initState() {
    super.initState();
    // Update every minute to show countdown
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    // Update every second for real-time countdown
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {});
        _startCountdownTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calculate warranty info
    final warrantyInfo = _calculateWarranty(reportData);

    return Scaffold(
      backgroundColor: LaapakColors.background,
      appBar: AppBar(
        title: Text(
          'الضمان',
          style: LaapakTypography.titleLarge(color: LaapakColors.textPrimary),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: DismissKeyboard(
          child: Directionality(
            textDirection: TextDirection.rtl, // RTL for Arabic
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: Responsive.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: Responsive.lg),

                  // Warranty Progress Bars
                  _buildWarrantyProgressBars(warrantyInfo),

                  SizedBox(height: Responsive.lg),

                  // Device Specs
                  // DeviceSpecsCard(
                  //   deviceModel: reportData['device_model'],
                  //   serialNumber: reportData['serial_number'],
                  //   inspectionDate: reportData['inspection_date'],
                  // ),

                  // SizedBox(height: Responsive.lg),

                  // Warranty Details Card
                  _buildWarrantyDetailsCard(warrantyInfo),

                  SizedBox(height: Responsive.lg),

                  // Warranty Terms Card
                  _buildWarrantyTermsCard(),

                  SizedBox(height: Responsive.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Calculate all warranty information
  Map<String, dynamic> _calculateWarranty(Map<String, dynamic> report) {
    try {
      final inspectionDate = DateTime.parse(
        report['inspection_date'] ?? report['created_at'],
      );
      final now = DateTime.now();

      // Warranty 1: 6 months manufacturing defects warranty
      final warranty1Months = 6;
      final warranty1Days = warranty1Months * 30;
      final warranty1Expiry = inspectionDate.add(Duration(days: warranty1Days));
      final warranty1Duration = warranty1Expiry.difference(now);
      final warranty1Progress = _calculateProgress(
        inspectionDate,
        warranty1Expiry,
        now,
      );

      // Warranty 2: 14 days replacement warranty
      final warranty2Days = 14;
      final warranty2Expiry = inspectionDate.add(Duration(days: warranty2Days));
      final warranty2Duration = warranty2Expiry.difference(now);
      final warranty2Progress = _calculateProgress(
        inspectionDate,
        warranty2Expiry,
        now,
      );

      // Warranty 3: Free periodic maintenance (twice annually for 1 year)
      // Split into two 6-month periods
      final maintenancePeriodMonths = 6;
      final maintenancePeriodDays = maintenancePeriodMonths * 30;

      // First 6-month period
      final warranty3aExpiry = inspectionDate.add(
        Duration(days: maintenancePeriodDays),
      );
      final warranty3aDuration = warranty3aExpiry.difference(now);
      final warranty3aProgress = _calculateProgress(
        inspectionDate,
        warranty3aExpiry,
        now,
      );

      // Second 6-month period
      final warranty3bStart = warranty3aExpiry;
      final warranty3bExpiry = warranty3bStart.add(
        Duration(days: maintenancePeriodDays),
      );
      final warranty3bDuration = warranty3bExpiry.difference(now);
      final warranty3bProgress = _calculateProgress(
        warranty3bStart,
        warranty3bExpiry,
        now,
      );

      return {
        'startDate': inspectionDate,
        'warranty1': {
          'name': 'ضمان 6 شهور ضد عيوب الصناعة',
          'expiryDate': warranty1Expiry,
          'daysRemaining': warranty1Duration.inDays,
          'hoursRemaining': warranty1Duration.inHours % 24,
          'minutesRemaining': warranty1Duration.inMinutes % 60,
          'secondsRemaining': warranty1Duration.inSeconds % 60,
          'totalDays': warranty1Days,
          'progress': warranty1Progress,
          'isExpired': warranty1Duration.isNegative,
        },
        'warranty2': {
          'name': 'ضمان 14 يوم استبدال',
          'expiryDate': warranty2Expiry,
          'daysRemaining': warranty2Duration.inDays,
          'hoursRemaining': warranty2Duration.inHours % 24,
          'minutesRemaining': warranty2Duration.inMinutes % 60,
          'secondsRemaining': warranty2Duration.inSeconds % 60,
          'totalDays': warranty2Days,
          'progress': warranty2Progress,
          'isExpired': warranty2Duration.isNegative,
        },
        'warranty3a': {
          'name': 'صيانة دورية - الفترة الأولى',
          'startDate': inspectionDate,
          'expiryDate': warranty3aExpiry,
          'daysRemaining': warranty3aDuration.inDays,
          'hoursRemaining': warranty3aDuration.inHours % 24,
          'minutesRemaining': warranty3aDuration.inMinutes % 60,
          'secondsRemaining': warranty3aDuration.inSeconds % 60,
          'totalDays': maintenancePeriodDays,
          'progress': warranty3aProgress,
          'isExpired': warranty3aDuration.isNegative,
        },
        'warranty3b': {
          'name': 'صيانة دورية - الفترة الثانية',
          'startDate': warranty3bStart,
          'expiryDate': warranty3bExpiry,
          'daysRemaining': warranty3bDuration.inDays,
          'hoursRemaining': warranty3bDuration.inHours % 24,
          'minutesRemaining': warranty3bDuration.inMinutes % 60,
          'secondsRemaining': warranty3bDuration.inSeconds % 60,
          'totalDays': maintenancePeriodDays,
          'progress': warranty3bProgress,
          'isExpired': warranty3bDuration.isNegative,
        },
      };
    } catch (e) {
      final now = DateTime.now();
      return {
        'startDate': now,
        'warranty1': {
          'name': 'ضمان 6 شهور ضد عيوب الصناعة',
          'expiryDate': now,
          'daysRemaining': 0,
          'hoursRemaining': 0,
          'minutesRemaining': 0,
          'secondsRemaining': 0,
          'totalDays': 180,
          'progress': 1.0,
          'isExpired': true,
        },
        'warranty2': {
          'name': 'ضمان 14 يوم استبدال',
          'expiryDate': now,
          'daysRemaining': 0,
          'hoursRemaining': 0,
          'minutesRemaining': 0,
          'secondsRemaining': 0,
          'totalDays': 14,
          'progress': 1.0,
          'isExpired': true,
        },
        'warranty3a': {
          'name': 'صيانة دورية - الفترة الأولى',
          'startDate': now,
          'expiryDate': now,
          'daysRemaining': 0,
          'hoursRemaining': 0,
          'minutesRemaining': 0,
          'secondsRemaining': 0,
          'totalDays': 180,
          'progress': 1.0,
          'isExpired': true,
        },
        'warranty3b': {
          'name': 'صيانة دورية - الفترة الثانية',
          'startDate': now,
          'expiryDate': now,
          'daysRemaining': 0,
          'hoursRemaining': 0,
          'minutesRemaining': 0,
          'secondsRemaining': 0,
          'totalDays': 180,
          'progress': 1.0,
          'isExpired': true,
        },
      };
    }
  }

  /// Calculate progress percentage
  double _calculateProgress(
    DateTime startDate,
    DateTime expiryDate,
    DateTime now,
  ) {
    if (now.isAfter(expiryDate)) return 1.0;
    if (now.isBefore(startDate)) return 0.0;

    final totalDuration = expiryDate.difference(startDate);
    final elapsedDuration = now.difference(startDate);

    return (elapsedDuration.inSeconds / totalDuration.inSeconds).clamp(
      0.0,
      1.0,
    );
  }

  /// Warranty progress bars for all 3 warranties
  Widget _buildWarrantyProgressBars(Map<String, dynamic> warrantyInfo) {
    return Card(
      child: Padding(
        padding: Responsive.cardPaddingInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'متابعة الضمان',
              style: LaapakTypography.titleLarge(
                color: LaapakColors.textPrimary,
              ),
            ),
            SizedBox(height: Responsive.xl),

            // Warranty 1: 6 months manufacturing defects
            _buildWarrantyProgressBar(
              warrantyInfo['warranty1'] as Map<String, dynamic>,
            ),

            SizedBox(height: Responsive.lg),

            // Warranty 2: 14 days replacement
            _buildWarrantyProgressBar(
              warrantyInfo['warranty2'] as Map<String, dynamic>,
            ),

            SizedBox(height: Responsive.lg),

            // Warranty 3: Free periodic maintenance (split into 2 periods)
            _buildMaintenanceWarrantyRow(
              warrantyInfo['warranty3a'] as Map<String, dynamic>,
              warrantyInfo['warranty3b'] as Map<String, dynamic>,
            ),
          ],
        ),
      ),
    );
  }

  /// Build maintenance warranty row with two 6-month progress bars
  Widget _buildMaintenanceWarrantyRow(
    Map<String, dynamic> warranty3a,
    Map<String, dynamic> warranty3b,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'صيانة دورية مجانية (مرتين سنوياً مجاناً)',
          style: LaapakTypography.bodyMedium(color: LaapakColors.textPrimary),
        ),
        SizedBox(height: Responsive.md),

        // Two progress bars side by side
        Row(
          children: [
            // First 6-month period
            Expanded(
              child: _buildCompactWarrantyProgressBar(
                warranty3a,
                'الفترة الأولى',
              ),
            ),
            SizedBox(width: Responsive.md),
            // Second 6-month period
            Expanded(
              child: _buildCompactWarrantyProgressBar(
                warranty3b,
                'الفترة الثانية',
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build compact warranty progress bar for maintenance periods
  Widget _buildCompactWarrantyProgressBar(
    Map<String, dynamic> warranty,
    String periodLabel,
  ) {
    final progress = warranty['progress'] as double;
    final isExpired = warranty['isExpired'] as bool;
    final daysRemaining = warranty['daysRemaining'] as int;

    Color progressColor;
    String statusText;

    if (isExpired) {
      progressColor = LaapakColors.error;
      statusText = 'منتهي';
    } else if (progress > 0.8) {
      progressColor = LaapakColors.warning;
      statusText = 'قرب الانتهاء';
    } else {
      progressColor = LaapakColors.success;
      statusText = 'نشط';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period Label and Status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              periodLabel,
              style: LaapakTypography.labelMedium(
                color: LaapakColors.textPrimary,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: progressColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                statusText,
                style: LaapakTypography.labelSmall(color: progressColor),
              ),
            ),
          ],
        ),

        SizedBox(height: Responsive.xs),

        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: isExpired ? 1.0 : progress,
            minHeight: 6,
            backgroundColor: LaapakColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),

        SizedBox(height: Responsive.xs),

        // Countdown and Percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Countdown
            Flexible(
              child: isExpired
                  ? Text(
                      'منتهي',
                      style: LaapakTypography.labelSmall(
                        color: LaapakColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      '$daysRemaining يوم',
                      style: LaapakTypography.labelSmall(
                        color: LaapakColors.textSecondary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),

            // Percentage
            Text(
              isExpired
                  ? '100%'
                  : '${((1 - progress) * 100).toStringAsFixed(0)}%',
              style: LaapakTypography.labelSmall(color: progressColor),
            ),
          ],
        ),
      ],
    );
  }

  /// Build individual warranty progress bar
  Widget _buildWarrantyProgressBar(Map<String, dynamic> warranty) {
    final name = warranty['name'] as String;
    final progress = warranty['progress'] as double;
    final isExpired = warranty['isExpired'] as bool;
    final daysRemaining = warranty['daysRemaining'] as int;
    final hoursRemaining = warranty['hoursRemaining'] as int;
    final minutesRemaining = warranty['minutesRemaining'] as int;
    final secondsRemaining = warranty['secondsRemaining'] as int;
    final expiryDate = warranty['expiryDate'] as DateTime;

    Color progressColor;
    String statusText;

    if (isExpired) {
      progressColor = LaapakColors.error;
      statusText = 'منتهي';
    } else if (progress > 0.8) {
      progressColor = LaapakColors.warning;
      statusText = 'قرب الانتهاء';
    } else {
      progressColor = LaapakColors.success;
      statusText = 'نشط';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Warranty Name and Status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                name,
                style: LaapakTypography.bodyMedium(
                  color: LaapakColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.sm,
                vertical: Responsive.xs,
              ),
              decoration: BoxDecoration(
                color: progressColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusText,
                style: LaapakTypography.labelSmall(color: progressColor),
              ),
            ),
          ],
        ),

        SizedBox(height: Responsive.sm),

        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: isExpired ? 1.0 : progress,
            minHeight: 8,
            backgroundColor: LaapakColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),

        SizedBox(height: Responsive.sm),

        // Countdown and Percentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Countdown
            if (isExpired)
              Text(
                'انتهى في ${_formatDate(expiryDate)}',
                style: LaapakTypography.labelSmall(
                  color: LaapakColors.textSecondary,
                ),
              )
            else
              Text(
                'متبقي: $daysRemaining يوم ${hoursRemaining.toString().padLeft(2, '0')}:${minutesRemaining.toString().padLeft(2, '0')}:${secondsRemaining.toString().padLeft(2, '0')}',
                style: LaapakTypography.labelSmall(
                  color: LaapakColors.textSecondary,
                ),
              ),

            // Percentage
            Text(
              isExpired
                  ? '100%'
                  : '${((1 - progress) * 100).toStringAsFixed(1)}%',
              style: LaapakTypography.labelMedium(color: progressColor),
            ),
          ],
        ),
      ],
    );
  }

  /// Warranty details card
  Widget _buildWarrantyDetailsCard(Map<String, dynamic> warrantyInfo) {
    final startDate = warrantyInfo['startDate'] as DateTime;
    final warranty1 = warrantyInfo['warranty1'] as Map<String, dynamic>;
    final warranty2 = warrantyInfo['warranty2'] as Map<String, dynamic>;

    return Card(
      child: Padding(
        padding: Responsive.cardPaddingInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تفاصيل الضمان',
              style: LaapakTypography.titleLarge(
                color: LaapakColors.textPrimary,
              ),
            ),
            SizedBox(height: Responsive.md),
            _buildInfoRow('تاريخ الشراء', _formatDate(startDate)),
            SizedBox(height: Responsive.sm),
            _buildInfoRow(
              'انتهاء ضمان 14 يوم',
              _formatDate(warranty2['expiryDate'] as DateTime),
            ),
            SizedBox(height: Responsive.sm),
            _buildInfoRow(
              'انتهاء ضمان 6 شهور',
              _formatDate(warranty1['expiryDate'] as DateTime),
            ),
            SizedBox(height: Responsive.sm),
            _buildInfoRow(
              'انتهاء الصيانة الدورية - الفترة الأولى',
              _formatDate(
                (warrantyInfo['warranty3a']
                        as Map<String, dynamic>)['expiryDate']
                    as DateTime,
              ),
            ),
            SizedBox(height: Responsive.sm),
            _buildInfoRow(
              'انتهاء الصيانة الدورية - الفترة الثانية',
              _formatDate(
                (warrantyInfo['warranty3b']
                        as Map<String, dynamic>)['expiryDate']
                    as DateTime,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Warranty terms card
  Widget _buildWarrantyTermsCard() {
    return Card(
      child: Padding(
        padding: Responsive.cardPaddingInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'شروط الضمان',
              style: LaapakTypography.titleLarge(
                color: LaapakColors.textPrimary,
              ),
            ),
            SizedBox(height: Responsive.md),
            _buildTermItem('الضمان يشمل عيوب الصناعة فقط'),
            SizedBox(height: Responsive.sm),
            _buildTermItem('لا يشمل السقوط أو تسرب السوائل'),
            SizedBox(height: Responsive.sm),
            _buildTermItem('لا يشمل محاولات الإصلاح خارج Fix Zone'),
            SizedBox(height: Responsive.sm),
            _buildTermItem('لا يشمل التعديلات غير المعتمدة'),
          ],
        ),
      ),
    );
  }

  /// Build info row
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: LaapakTypography.bodyMedium(color: LaapakColors.textSecondary),
        ),
        Flexible(
          child: Text(
            value,
            style: LaapakTypography.bodyMedium(color: LaapakColors.textPrimary),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  /// Build warranty term item
  Widget _buildTermItem(String term) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: Responsive.xs, left: Responsive.sm),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: LaapakColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            term,
            style: LaapakTypography.bodyMedium(color: LaapakColors.textPrimary),
          ),
        ),
      ],
    );
  }

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
