import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/dismiss_keyboard.dart';
import '../../widgets/device_specs_card.dart';
import '../../providers/reports_provider.dart';
import '../../providers/auth_provider.dart';
import '../reports/reports_screen.dart';
import '../reports/reports_list_screen.dart';
import '../warranty/warranty_screen.dart';

/// Order Screen
///
/// Main dashboard screen for users with orders.
/// Displays device information and navigation options.
class OrderScreen extends ConsumerStatefulWidget {
  final String? reportId;

  const OrderScreen({super.key, this.reportId});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(clientReportsProvider);

    // Check if user has multiple reports
    final reports = reportsAsync.valueOrNull ?? [];
    final hasMultipleReports = reports.length > 1;

    // If a specific reportId is provided, use that report
    // Otherwise, if user has multiple reports, show the reports list screen
    if (widget.reportId == null && hasMultipleReports) {
      return const ReportsListScreen();
    }

    // Get the report to display
    Map<String, dynamic>? firstReport;
    if (widget.reportId != null) {
      // Find the specific report by ID
      try {
        firstReport = reports.firstWhere(
          (report) => report['id']?.toString() == widget.reportId,
        );
      } catch (e) {
        // Report not found, use null
        firstReport = null;
      }
    } else {
      // Get the first report for device info (if available)
      firstReport = reports.isNotEmpty ? reports.first : null;
    }

    return Builder(
      builder: (context) {
        // Check if there's a back stack (navigated from reports list)
        final hasBackStack = Navigator.canPop(context);
        final deviceModel = hasBackStack
            ? (firstReport?['device_model']?.toString() ?? '')
            : '';

        return Scaffold(
          backgroundColor: LaapakColors.background,
          appBar: AppBar(
            backgroundColor: LaapakColors.background,
            elevation: 0,
            title: deviceModel.isNotEmpty
                ? Text(
                    deviceModel,
                    style: LaapakTypography.titleLarge(
                      color: LaapakColors.textPrimary,
                    ),
                  )
                : null,
            centerTitle: true,
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
                      // SizedBox(height: Responsive.lg),

                      // Device Name (only when root page, no back stack)
                      Builder(
                        builder: (ctx) {
                          if (!Navigator.canPop(ctx)) {
                            return _buildDeviceName(firstReport);
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Add spacing only if device name is shown
                      Builder(
                        builder: (ctx) {
                          if (!Navigator.canPop(ctx)) {
                            return SizedBox(height: Responsive.xl);
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Device Specs Card (using reusable component)
                      if (firstReport != null)
                        DeviceSpecsCard(
                          deviceModel:
                              firstReport['device_model']?.toString() ??
                              'غير محدد',
                          serialNumber:
                              firstReport['serial_number']?.toString() ??
                              'غير محدد',
                          inspectionDate:
                              firstReport['inspection_date']?.toString() ??
                              firstReport['created_at']?.toString() ??
                              DateTime.now().toIso8601String(),
                          deviceStatus: 'جيد',
                        )
                      else
                        reportsAsync.when(
                          data: (_) => const SizedBox.shrink(),
                          loading: () => Card(
                            child: Padding(
                              padding: Responsive.cardPaddingInsets,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: LaapakColors.primary,
                                ),
                              ),
                            ),
                          ),
                          error: (error, _) => Card(
                            child: Padding(
                              padding: Responsive.cardPaddingInsets,
                              child: Text(
                                'خطأ في تحميل بيانات الجهاز',
                                style: LaapakTypography.bodyMedium(
                                  color: LaapakColors.error,
                                ),
                              ),
                            ),
                          ),
                        ),

                      SizedBox(height: Responsive.xl),

                      // Navigation Buttons
                      _buildNavigationButtons(context, firstReport),

                      // Logout Button (only when there's no back stack - root screen)
                      Builder(
                        builder: (ctx) {
                          if (!Navigator.canPop(ctx)) {
                            return Column(
                              children: [
                                SizedBox(height: Responsive.xl),
                                _buildLogoutButton(ctx),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Device name section
  Widget _buildDeviceName(Map<String, dynamic>? report) {
    final deviceModel = report?['device_model']?.toString() ?? 'غير محدد';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          deviceModel,
          style: LaapakTypography.displaySmall(color: LaapakColors.textPrimary),
        ),
        if (report?['serial_number'] != null) ...[
          SizedBox(height: Responsive.xs),
          Text(
            'السيريال: ${report!['serial_number']}',
            style: LaapakTypography.bodyMedium(
              color: LaapakColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  /// Navigation buttons section
  Widget _buildNavigationButtons(
    BuildContext context,
    Map<String, dynamic>? firstReport,
  ) {
    // Get report ID from first report
    final reportId = firstReport?['id']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Reports Button
        _buildNavButton(
          icon: Icons.description_outlined,
          text: 'التقارير',
          onPressed: reportId != null
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportsScreen(reportId: reportId),
                    ),
                  );
                }
              : null,
        ),

        SizedBox(height: Responsive.md),

        // Warranty Button
        _buildNavButton(
          icon: Icons.verified_outlined,
          text: 'الضمان',
          onPressed: () {
            final reportId = firstReport?['id']?.toString();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WarrantyScreen(reportId: reportId),
              ),
            );
          },
        ),

        SizedBox(height: Responsive.md),

        // Download Invoice Button
        _buildNavButton(
          icon: Icons.download_outlined,
          text: 'تحميل الفاتورة',
          onPressed:
              firstReport != null &&
                  firstReport['invoice_id'] != null &&
                  firstReport['invoice_created'] == true
              ? () => _openInvoicePrint(context, firstReport)
              : null,
        ),
      ],
    );
  }

  /// Build a navigation button
  Widget _buildNavButton({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: Responsive.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style:
            OutlinedButton.styleFrom(
              side: BorderSide(color: LaapakColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.buttonRadius),
              ),
              padding: Responsive.buttonPadding,
            ).copyWith(
              foregroundColor: onPressed == null
                  ? WidgetStateProperty.all(LaapakColors.textDisabled)
                  : null,
            ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: LaapakTypography.button(color: LaapakColors.textPrimary),
            ),
            Icon(
              icon,
              size: Responsive.iconSizeMedium,
              color: LaapakColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  /// Open invoice print view
  Future<void> _openInvoicePrint(
    BuildContext context,
    Map<String, dynamic> report,
  ) async {
    final invoiceId = report['invoice_id']?.toString();

    if (invoiceId == null || invoiceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا توجد فاتورة متاحة لهذا التقرير',
            style: LaapakTypography.bodyMedium(color: LaapakColors.background),
          ),
          backgroundColor: LaapakColors.error,
        ),
      );
      return;
    }

    try {
      final apiService = ref.read(authenticatedApiServiceProvider);

      if (apiService == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ في المصادقة',
              style: LaapakTypography.bodyMedium(
                color: LaapakColors.background,
              ),
            ),
            backgroundColor: LaapakColors.error,
          ),
        );
        return;
      }

      // Get the print URL
      final printUrl = apiService.getInvoicePrintUrl(invoiceId);

      // Launch the URL
      final uri = Uri.parse(printUrl);

      // Try to launch directly - canLaunchUrl can be unreliable on Android
      // The "component name is null" warning is common but doesn't prevent launching
      try {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Open in external browser
        );
      } catch (launchError) {
        // If external application fails, try with platformDefault mode
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e) {
          throw Exception('Could not launch URL: ${e.toString()}');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'حدث خطأ أثناء فتح الفاتورة: ${e.toString()}',
            style: LaapakTypography.bodyMedium(color: LaapakColors.background),
          ),
          backgroundColor: LaapakColors.error,
        ),
      );
    }
  }

  /// Build logout button
  Widget _buildLogoutButton(BuildContext context) {
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
