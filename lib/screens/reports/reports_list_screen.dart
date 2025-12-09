import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/dismiss_keyboard.dart';
import '../../widgets/empty_state.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reports_provider.dart';
import '../order/order_screen.dart';

/// Reports List Screen
///
/// Landing page that displays all reports as cards when user has multiple reports
class ReportsListScreen extends ConsumerWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(clientReportsProvider);

    return Scaffold(
      backgroundColor: LaapakColors.background,
      appBar: AppBar(
        backgroundColor: LaapakColors.background,
        title: Text(
          'مشترياتك من لابك',
          style: LaapakTypography.titleLarge(color: LaapakColors.textPrimary),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: DismissKeyboard(
          child: Directionality(
            textDirection: TextDirection.rtl, // RTL for Arabic
            child: reportsAsync.when(
              data: (reports) {
                if (reports.isEmpty) {
                  return EmptyState.noReports();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // Invalidate the provider to force refresh
                    ref.invalidate(clientReportsProvider);
                    // Wait for the refresh to complete
                    await ref.read(clientReportsProvider.future);
                  },
                  color: LaapakColors.primary,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: Responsive.screenPadding,
                    itemCount: reports.length + 1, // +1 for logout button
                    itemBuilder: (context, index) {
                      if (index < reports.length) {
                        return _buildReportCard(context, reports[index], index);
                      } else {
                        // Logout button as last item
                        return Column(
                          children: [
                            SizedBox(height: Responsive.xl),
                            _buildLogoutButton(context, ref),
                          ],
                        );
                      }
                    },
                  ),
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(color: LaapakColors.primary),
              ),
              error: (error, stackTrace) => EmptyState.error(
                message: 'حدث خطأ في تحميل التقارير',
                action: ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(clientReportsProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LaapakColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build a report card
  Widget _buildReportCard(
    BuildContext context,
    Map<String, dynamic> report,
    int index,
  ) {
    final reportId = report['id']?.toString() ?? '';
    final deviceModel = report['device_model']?.toString() ?? 'غير محدد';
    final serialNumber = report['serial_number']?.toString() ?? 'غير محدد';
    final inspectionDate =
        report['inspection_date']?.toString() ??
        report['created_at']?.toString() ??
        '';
    final status = report['status']?.toString() ?? '';

    // Format date
    String formattedDate = 'غير محدد';
    try {
      if (inspectionDate.isNotEmpty) {
        final date = DateTime.parse(inspectionDate);
        formattedDate = '${date.year}/${date.month}/${date.day}';
      }
    } catch (e) {
      // Keep default
    }

    // Status text and color
    String statusText = status;
    Color statusColor = LaapakColors.textSecondary;
    switch (status.toLowerCase()) {
      case 'active':
        statusText = 'نشط';
        statusColor = LaapakColors.success;
        break;
      case 'completed':
        statusText = 'مكتمل';
        statusColor = LaapakColors.success;
        break;
      case 'cancelled':
        statusText = 'ملغي';
        statusColor = LaapakColors.error;
        break;
    }

    return Card(
      margin: EdgeInsets.only(bottom: Responsive.md),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderScreen(reportId: reportId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(Responsive.cardRadius),
        child: Padding(
          padding: Responsive.cardPaddingInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          deviceModel,
                          style: LaapakTypography.titleMedium(
                            color: LaapakColors.textPrimary,
                          ),
                        ),
                        if (serialNumber.isNotEmpty &&
                            serialNumber != 'غير محدد')
                          Padding(
                            padding: EdgeInsets.only(top: Responsive.xs),
                            child: Text(
                              'السيريال: $serialNumber',
                              style: LaapakTypography.bodySmall(
                                color: LaapakColors.textSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
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
              ),

              SizedBox(height: Responsive.md),

              // Details Row
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: Responsive.iconSizeSmall,
                    color: LaapakColors.textSecondary,
                  ),
                  SizedBox(width: Responsive.xs),
                  Text(
                    'تاريخ المعاينة: $formattedDate',
                    style: LaapakTypography.bodySmall(
                      color: LaapakColors.textSecondary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: Responsive.sm),

              // Arrow indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.arrow_forward_ios,
                    size: Responsive.iconSizeSmall,
                    color: LaapakColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build logout button
  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Divider
        Divider(
          color: LaapakColors.border,
          height: Responsive.xl,
          thickness: 1,
        ),

        // Logout button with subtle styling
        TextButton.icon(
          onPressed: () async {
            // Show confirmation dialog
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => Directionality(
                textDirection: TextDirection.rtl,
                child: AlertDialog(
                  backgroundColor: LaapakColors.background,
                  title: Text(
                    'تأكيد تسجيل الخروج',
                    style: LaapakTypography.titleMedium(
                      color: LaapakColors.textPrimary,
                    ),
                  ),
                  content: Text(
                    'هل أنت متأكد من تسجيل الخروج؟',
                    style: LaapakTypography.bodyMedium(
                      color: LaapakColors.textSecondary,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: Text(
                        'إلغاء',
                        style: LaapakTypography.button(
                          color: LaapakColors.textSecondary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      style: TextButton.styleFrom(
                        foregroundColor: LaapakColors.error,
                      ),
                      child: Text(
                        'تسجيل الخروج',
                        style: LaapakTypography.button(
                          color: LaapakColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );

            if (shouldLogout == true) {
              // Perform logout
              await ref.read(authProvider.notifier).logout();
              // The main.dart will automatically navigate to LoginScreen
              // when authState.isAuthenticated becomes false
            }
          },
          icon: Icon(
            Icons.logout_outlined,
            size: Responsive.iconSizeSmall,
            color: LaapakColors.textSecondary,
          ),
          label: Text(
            'تسجيل الخروج',
            style: LaapakTypography.bodyMedium(
              color: LaapakColors.textSecondary,
            ),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.md,
              vertical: Responsive.sm,
            ),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}
