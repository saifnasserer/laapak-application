import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/dismiss_keyboard.dart';
import '../../widgets/notification_permission_dialog.dart';
import '../../providers/reports_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/laapak_api_service.dart';
import '../../services/notification_service.dart';

/// Warranty Tracker Screen
///
/// Displays warranty information and status based on report data.
/// Shows warranty duration, expiry date, and status with daily countdown.
class WarrantyScreen extends ConsumerStatefulWidget {
  final String? reportId;

  const WarrantyScreen({super.key, this.reportId});

  @override
  ConsumerState<WarrantyScreen> createState() => _WarrantyScreenState();
}

class _WarrantyScreenState extends ConsumerState<WarrantyScreen> {
  @override
  void initState() {
    super.initState();
    // Update every second to show countdown
    _startCountdownTimer();
    // Schedule warranty notifications when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleWarrantyNotifications();
    });
  }

  /// Schedule warranty notifications for the current report
  Future<void> _scheduleWarrantyNotifications() async {
    try {
      Map<String, dynamic>? reportData;

      if (widget.reportId != null) {
        final reportAsync = ref.read(reportsProvider(widget.reportId!));
        reportData = reportAsync.value;
      } else {
        final reportsAsync = ref.read(clientReportsProvider);
        final reports = reportsAsync.value;
        if (reports != null && reports.isNotEmpty) {
          reportData = reports.first;
        }
      }

      if (reportData != null) {
        final inspectionDate = DateTime.parse(
          reportData['inspection_date'] ?? reportData['created_at'],
        );
        final reportId =
            reportData['id']?.toString() ??
            reportData['_id']?.toString() ??
            widget.reportId ??
            'unknown';

        final notificationService = NotificationService();
        await notificationService.scheduledNotifications
            .scheduleWarrantyNotifications(
              reportId: reportId,
              inspectionDate: inspectionDate,
            );
      }
    } catch (e) {
      developer.log(
        '⚠️ Error scheduling warranty notifications: $e',
        name: 'Warranty',
      );
    }
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
    // If reportId is provided, watch that specific report
    if (widget.reportId != null) {
      final reportAsync = ref.watch(reportsProvider(widget.reportId!));

      return Directionality(
        textDirection: TextDirection.rtl, // RTL for Arabic
        child: Scaffold(
          backgroundColor: LaapakColors.background,
          body: SafeArea(
            top: true,
            bottom: false,
            child: DismissKeyboard(
              child: CustomScrollView(
                slivers: [
                  // Sliver AppBar (scrollable header)
                  SliverAppBar(
                    backgroundColor: LaapakColors.background,
                    elevation: 0,
                    pinned: false, // Allow it to scroll away completely
                    floating: true, // Snap back when scrolling up
                    centerTitle: true,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_outlined,
                        color: LaapakColors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: Text(
                      'الضمان',
                      style: LaapakTypography.titleLarge(
                        color: LaapakColors.textPrimary,
                      ),
                    ),
                  ),

                  // Content
                  reportAsync.when(
                    data: (data) {
                      if (data == null) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildErrorState('التقرير غير موجود'),
                        );
                      }
                      return SliverPadding(
                        padding: Responsive.screenPadding,
                        sliver: SliverToBoxAdapter(
                          child: _buildWarrantyContent(data),
                        ),
                      );
                    },
                    loading: () => SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildLoadingState(),
                    ),
                    error: (error, stackTrace) {
                      developer.log(
                        '❌ Error loading report: $error',
                        name: 'Warranty',
                      );
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildErrorState(
                          error is LaapakApiException
                              ? error.message
                              : 'حدث خطأ في تحميل البيانات',
                        ),
                      );
                    },
                  ),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Otherwise, watch clientReportsProvider for the latest report
    final reportsAsync = ref.watch(clientReportsProvider);

    return Directionality(
      textDirection: TextDirection.rtl, // RTL for Arabic
      child: Scaffold(
        backgroundColor: LaapakColors.background,
        body: SafeArea(
          top: true,
          bottom: false,
          child: DismissKeyboard(
            child: CustomScrollView(
              slivers: [
                // Sliver AppBar (scrollable header)
                SliverAppBar(
                  backgroundColor: LaapakColors.background,
                  elevation: 0,
                  pinned: false, // Allow it to scroll away completely
                  floating: true, // Snap back when scrolling up
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_outlined,
                      color: LaapakColors.textPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    'الضمان',
                    style: LaapakTypography.titleLarge(
                      color: LaapakColors.textPrimary,
                    ),
                  ),
                ),

                // Content
                reportsAsync.when(
                  data: (reports) {
                    if (reports.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: _buildErrorState('لا توجد تقارير متاحة'),
                      );
                    }
                    return SliverPadding(
                      padding: Responsive.screenPadding,
                      sliver: SliverToBoxAdapter(
                        child: _buildWarrantyContent(reports.first),
                      ),
                    );
                  },
                  loading: () => SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildLoadingState(),
                  ),
                  error: (error, stackTrace) {
                    developer.log(
                      '❌ Error loading reports: $error',
                      name: 'Warranty',
                    );
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildErrorState(
                        error is LaapakApiException
                            ? error.message
                            : 'حدث خطأ في تحميل البيانات',
                      ),
                    );
                  },
                ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(color: LaapakColors.primary),
    );
  }

  /// Build error state
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: Responsive.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: LaapakColors.error),
            SizedBox(height: Responsive.lg),
            Text(
              message,
              style: LaapakTypography.bodyLarge(
                color: LaapakColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Responsive.lg),
            ElevatedButton(
              onPressed: () {
                // Refresh the provider
                if (widget.reportId != null) {
                  ref.invalidate(reportsProvider(widget.reportId!));
                } else {
                  ref.invalidate(clientReportsProvider);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: LaapakColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  /// Build warranty content
  Widget _buildWarrantyContent(Map<String, dynamic> reportData) {
    // Calculate warranty info
    final warrantyInfo = _calculateWarranty(reportData);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Warranty Progress Bars
        _buildWarrantyProgressBars(warrantyInfo),

        SizedBox(height: Responsive.lg),

        // Warranty Details Card
        _buildWarrantyDetailsCard(warrantyInfo),

        SizedBox(height: Responsive.lg),

        // Notification Status Card
        _buildNotificationStatusCard(),

        SizedBox(height: Responsive.lg),

        // Warranty Terms Card
        _buildWarrantyTermsCard(),

        SizedBox(height: Responsive.lg),

        // Maintenance Timeline Card
        _buildMaintenanceTimelineCard(),

        SizedBox(height: Responsive.xl),
      ],
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
                color: progressColor.withValues(alpha: 0.1),
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
                      ' متبقي $daysRemaining يوم',
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
                color: progressColor.withValues(alpha: 0.1),
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
                'متبقي: $daysRemaining  يوم و ${hoursRemaining.toString().padLeft(2, '0')}:${minutesRemaining.toString().padLeft(2, '0')}:${secondsRemaining.toString().padLeft(2, '0')} ساعة',
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
              'شروط الضمان الأساسية',
              style: LaapakTypography.titleLarge(
                color: LaapakColors.textPrimary,
              ),
            ),
            SizedBox(height: Responsive.lg),

            // Warranty Exclusions
            _buildTermSection(
              icon: Icons.block_outlined,
              title: 'استثناءات الضمان',
              description:
                  'لا يسري الضمان في حال وجود سوء استخدام، الكسر، أو الأضرار الناتجة عن الكهرباء ذات الجهد العالي أو ما شابه.',
            ),

            SizedBox(height: Responsive.md),

            // Device Opening Exclusion
            _buildTermSection(
              icon: Icons.lock_open_outlined,
              title: 'الاستثناء عند فتح الجهاز',
              description:
                  'لا يسري الضمان في حال تم إزالة الاستيكر الخاص بالشركة أو في حالة محاولة فتح أو صيانة الجهاز خارج الشركة.',
            ),

            SizedBox(height: Responsive.md),

            // Manufacturing Defects Only
            _buildTermSection(
              icon: Icons.info_outline,
              title: 'عيوب الصناعة فقط',
              description:
                  'يشمل الضمان فقط العيوب الناتجة عن التصنيع ولا يشمل الأعطال الناتجة عن البرمجيات أو أي مشاكل غير متعلقة بالأجزاء المادية.',
            ),
          ],
        ),
      ),
    );
  }

  /// Build a term section with minimal styling
  Widget _buildTermSection({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: Responsive.iconSizeSmall,
              color: LaapakColors.textSecondary,
            ),
            SizedBox(width: Responsive.xs),
            Text(
              title,
              style: LaapakTypography.titleSmall(
                color: LaapakColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.xs),
        Padding(
          padding: EdgeInsets.only(
            right: Responsive.iconSizeSmall + Responsive.xs,
          ),
          child: Text(
            description,
            style: LaapakTypography.bodyMedium(
              color: LaapakColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// Maintenance timeline card
  Widget _buildMaintenanceTimelineCard() {
    return Card(
      child: Padding(
        padding: Responsive.cardPaddingInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.build_outlined,
                  color: LaapakColors.textPrimary,
                  size: Responsive.iconSizeMedium,
                ),
                SizedBox(width: Responsive.sm),
                Text(
                  'مراحل الصيانة الدورية في Laapak',
                  style: LaapakTypography.titleLarge(
                    color: LaapakColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: Responsive.lg),
            _buildTimelineItem(
              icon: Icons.thermostat_outlined,
              title: 'استبدال المعجون الحراري',
              description:
                  'باستخدام نوع عالي الجودة ومناسب لطبيعة الجهاز لضمان أفضل تبريد ممكن.',
            ),
            SizedBox(height: Responsive.md),
            _buildTimelineItem(
              icon: Icons.air_outlined,
              title: 'إزالة الأكسدة من نظام التبريد',
              description:
                  'لتحسين نقل الحرارة بكفاءة، حيث تؤثر الأكسدة على كفاءة التبريد بنسبة قد تصل إلى 40%.',
            ),
            SizedBox(height: Responsive.md),
            _buildTimelineItem(
              icon: Icons.speed_outlined,
              title: 'فحص سرعة مراوح التبريد',
              description:
                  'وفي حالة تأثرها بالأتربة، يتم تنظيفها وإعادتها لحالتها الطبيعية لضمان التهوية المثالية.',
            ),
            SizedBox(height: Responsive.md),
            _buildTimelineItem(
              icon: Icons.memory_outlined,
              title: 'تنظيف اللوحة الأم بالكامل',
              description:
                  'شاملاً تنظيف جميع الفلاتات والوصلات بدقة لضمان استقرار الأداء.',
            ),
            SizedBox(height: Responsive.md),
            _buildTimelineItem(
              icon: Icons.search_outlined,
              title: 'إجراء فحص شامل لكل مكونات الجهاز',
              description:
                  'لاكتشاف أي أعطال محتملة مبكرًا واتخاذ الإجراءات الوقائية اللازمة.',
            ),
            SizedBox(height: Responsive.md),
            _buildTimelineItem(
              icon: Icons.cleaning_services_outlined,
              title: 'تنظيف خارجي كامل للجهاز',
              description:
                  'لإعادة مظهره كالجديد تمامًا، مما يعزز من تجربة الاستخدام والانطباع العام.',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Build timeline item
  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String description,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon with subtle background
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: LaapakColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: LaapakColors.textPrimary,
            size: Responsive.iconSizeSmall,
          ),
        ),
        SizedBox(width: Responsive.md),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: LaapakTypography.titleSmall(
                  color: LaapakColors.textPrimary,
                ),
              ),
              SizedBox(height: Responsive.xs),
              Text(
                description,
                style: LaapakTypography.bodyMedium(
                  color: LaapakColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
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

  /// Format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Build notification status card with toggle
  Widget _buildNotificationStatusCard() {
    final permissionStatusAsync = ref.watch(
      notificationPermissionsStatusProvider,
    );
    final preferenceAsync = ref.watch(notificationPreferenceProvider);

    return Card(
      child: Padding(
        padding: Responsive.cardPaddingInsets,
        child: permissionStatusAsync.when(
          data: (permissionGranted) {
            return preferenceAsync.when(
              data: (preferenceEnabled) {
                final hasPermission = permissionGranted == true;
                final isEnabled = hasPermission && preferenceEnabled;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isEnabled
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                          color: isEnabled
                              ? LaapakColors.success
                              : LaapakColors.textSecondary,
                          size: Responsive.iconSizeMedium,
                        ),
                        SizedBox(width: Responsive.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEnabled
                                    ? 'الإشعارات مفعلة'
                                    : 'الإشعارات معطلة',
                                style: LaapakTypography.titleSmall(
                                  color: LaapakColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: Responsive.xs),
                              Text(
                                isEnabled
                                    ? 'ستتلقى إشعاراً عند موعد الصيانة الدورية المجانية لتذكيرك باستخدام خدمة الصيانة المجانية.'
                                    : preferenceEnabled && !hasPermission
                                    ? 'يجب تفعيل صلاحيات الإشعارات أولاً'
                                    : 'فعّل الإشعارات لتلقي تذكيرات بفحص الضمان ومواعيد الصيانة الدورية المجانية.',
                                style: LaapakTypography.bodySmall(
                                  color: LaapakColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: preferenceEnabled,
                          onChanged: hasPermission
                              ? (value) async {
                                  // Update preference
                                  final storageServiceAsync = ref.read(
                                    storageServiceProvider,
                                  );
                                  final storageService =
                                      await storageServiceAsync.value;
                                  if (storageService != null) {
                                    await storageService
                                        .setNotificationsEnabled(value);
                                    ref.invalidate(
                                      notificationPreferenceProvider,
                                    );

                                    final notificationService =
                                        NotificationService();
                                    await notificationService.initialize();

                                    if (value) {
                                      // Schedule notifications
                                      await _scheduleWarrantyNotifications();
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'تم تفعيل الإشعارات بنجاح',
                                            ),
                                            backgroundColor:
                                                LaapakColors.success,
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      // Cancel notifications
                                      final reportId = widget.reportId;
                                      if (reportId != null) {
                                        await notificationService
                                            .scheduledNotifications
                                            .cancelWarrantyNotifications(
                                              reportId,
                                            );
                                      }
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('تم إيقاف الإشعارات'),
                                            backgroundColor:
                                                LaapakColors.textSecondary,
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                }
                              : null, // Disable toggle if no permission
                          activeColor: LaapakColors.primary,
                        ),
                      ],
                    ),
                    if (!hasPermission) ...[
                      SizedBox(height: Responsive.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final notificationService = NotificationService();
                            await notificationService.initialize();

                            final result = await notificationService
                                .requestPermissions(forceRequest: true);

                            if (mounted) {
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                              ref.invalidate(
                                notificationPermissionsStatusProvider,
                              );

                              final isEnabled = await notificationService
                                  .areNotificationsEnabled();

                              if (result == true || isEnabled == true) {
                                // Schedule notifications if preference is enabled
                                final prefValue = preferenceAsync.value;
                                if (prefValue != null && prefValue == true) {
                                  await _scheduleWarrantyNotifications();
                                }
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'تم تفعيل صلاحيات الإشعارات',
                                      ),
                                      backgroundColor: LaapakColors.success,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } else if (result == null) {
                                if (mounted) {
                                  await NotificationPermissionDialog.show(
                                    context,
                                  );
                                }
                              }
                            }
                          },
                          icon: Icon(
                            Icons.notifications_active,
                            size: Responsive.iconSizeSmall,
                          ),
                          label: Text('تفعيل صلاحيات الإشعارات'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LaapakColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
              loading: () => Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: Responsive.md),
                  child: CircularProgressIndicator(
                    color: LaapakColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
              error: (error, stackTrace) {
                return Text(
                  'خطأ في تحميل إعدادات الإشعارات',
                  style: LaapakTypography.bodySmall(color: LaapakColors.error),
                );
              },
            );
          },
          loading: () => Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: Responsive.md),
              child: CircularProgressIndicator(
                color: LaapakColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),
          error: (error, stackTrace) {
            return Text(
              'خطأ في تحميل حالة الإشعارات',
              style: LaapakTypography.bodySmall(color: LaapakColors.error),
            );
          },
        ),
      ),
    );
  }
}
