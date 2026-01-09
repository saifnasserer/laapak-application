import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../theme/theme.dart';
import '../../utils/responsive.dart';
import '../../utils/constants.dart';
import '../../widgets/dismiss_keyboard.dart';
import '../../widgets/device_specs_card.dart';
import '../../widgets/empty_state.dart';
import '../../providers/reports_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/share_service.dart';
import '../reports/reports_screen.dart';
import '../reports/reports_list_screen.dart';
import '../warranty/warranty_screen.dart';
// import '../profile/profile_screen.dart';

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
  bool _hasRequestedPermissions = false;

  @override
  void initState() {
    super.initState();
    // Request notification permissions when screen first loads (only for root screen)
    // Delay to ensure the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestNotificationPermissionsIfNeeded();
    });
  }

  /// Request notification permissions if needed (Android 13+)
  Future<void> _requestNotificationPermissionsIfNeeded() async {
    // Only request once and only on Android
    if (_hasRequestedPermissions || !Platform.isAndroid) {
      return;
    }

    _hasRequestedPermissions = true;

    try {
      final notificationService = ref.read(notificationServiceProvider);

      // Check if permissions are already granted
      final enabled = await notificationService.areNotificationsEnabled();

      if (enabled != true) {
        // Request permissions
        await notificationService.requestPermissions();
      }
    } catch (e) {
      // Silently fail - permissions will be requested when user tries to show notification
    }
  }

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
            actions: [
              /*
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  );
                },
                icon: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: LaapakColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: LaapakColors.primary,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: Responsive.md),
              */
            ],
          ),
          body: SafeArea(
            child: DismissKeyboard(
              child: Directionality(
                textDirection: TextDirection.rtl, // RTL for Arabic
                child: reportsAsync.when(
                  data: (reports) {
                    // Show empty state when user has no reports
                    if (reports.isEmpty) {
                      return SingleChildScrollView(
                        padding: Responsive.screenPadding,
                        child: Column(
                          children: [
                            SizedBox(height: Responsive.xl),

                            // Icon
                            Container(
                              padding: EdgeInsets.all(Responsive.xl),
                              decoration: BoxDecoration(
                                color: LaapakColors.primary.withValues(
                                  alpha: 0.1,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.description_outlined,
                                size: Responsive.iconSizeXLarge,
                                color: LaapakColors.primary,
                              ),
                            ),

                            SizedBox(height: Responsive.lg),

                            // Title
                            Text(
                              'لا توجد تقارير متاحة',
                              style: LaapakTypography.headlineSmall(
                                color: LaapakColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: Responsive.md),

                            // Description with two scenarios
                            Container(
                              padding: EdgeInsets.all(Responsive.md),
                              decoration: BoxDecoration(
                                color: LaapakColors.surface,
                                borderRadius: BorderRadius.circular(
                                  Responsive.cardRadius,
                                ),
                                border: Border.all(
                                  color: LaapakColors.borderLight,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Scenario 1: Report in progress
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: 4),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: LaapakColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: Responsive.sm),
                                      Expanded(
                                        child: Text(
                                          'لو عندك طلب وتقريرك لسه بيتجهز، استنى شوية وهيظهرلك قريب',
                                          style: LaapakTypography.bodyMedium(
                                            color: LaapakColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: Responsive.sm),

                                  // Scenario 2: Create new order
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: 4),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: LaapakColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: Responsive.sm),
                                      Expanded(
                                        child: Text(
                                          'لو محتاج تعمل طلب جديد، تقدر تتواصل معانا',
                                          style: LaapakTypography.bodyMedium(
                                            color: LaapakColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: Responsive.xl),

                            // Action Buttons
                            Column(
                              children: [
                                // WhatsApp Button
                                SizedBox(
                                  width: double.infinity,
                                  height: Responsive.buttonHeight,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _openWhatsApp(context),
                                    icon: Icon(
                                      Icons.phone,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      'تواصل معانا واتساب',
                                      style: LaapakTypography.button(
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(
                                        0xFF25D366,
                                      ), // WhatsApp green
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          Responsive.buttonRadius,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: Responsive.md),

                                // Website Button
                                SizedBox(
                                  width: double.infinity,
                                  height: Responsive.buttonHeight,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _openWebsite(context),
                                    icon: Icon(
                                      Icons.language,
                                      color: LaapakColors.primary,
                                    ),
                                    label: Text(
                                      'زيارة الموقع',
                                      style: LaapakTypography.button(
                                        color: LaapakColors.primary,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: LaapakColors.primary,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          Responsive.buttonRadius,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: Responsive.xl * 2),
                            _buildLogoutButton(context),
                          ],
                        ),
                      );
                    }

                    // Normal view with reports
                    return SingleChildScrollView(
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
                              inspectionDate:
                                  firstReport['inspection_date']?.toString() ??
                                  firstReport['created_at']?.toString() ??
                                  DateTime.now().toIso8601String(),
                              additionalSpecs: _buildAdditionalSpecs(
                                firstReport,
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
                    );
                  },
                  loading: () => Center(
                    child: CircularProgressIndicator(
                      color: LaapakColors.primary,
                    ),
                  ),
                  error: (error, stackTrace) => SingleChildScrollView(
                    padding: Responsive.screenPadding,
                    child: Column(
                      children: [
                        SizedBox(height: Responsive.xl * 2),
                        EmptyState.error(
                          message: 'حدث خطأ في تحميل البيانات',
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
                        SizedBox(height: Responsive.xl * 2),
                        _buildLogoutButton(context),
                      ],
                    ),
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
          text: 'التقرير',
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

        SizedBox(height: Responsive.md),

        // Share Report Button
        _buildNavButton(
          icon: Icons.share_outlined,
          text: 'مشاركة التقرير',
          onPressed: firstReport != null
              ? () => _shareReport(context, firstReport)
              : null,
        ),

        SizedBox(height: Responsive.md),

        // Test Notification Button
        // _buildNavButton(
        //   icon: Icons.notifications_outlined,
        //   text: 'إشعار تجريبي',
        //   onPressed: () => _showTestNotification(context),
        // ),
      ],
    );
  }

  /// Build a navigation button
  /// Build a navigation button
  Widget _buildNavButton({
    required IconData icon,
    required String text,
    required VoidCallback? onPressed,
  }) {
    final isDisabled = onPressed == null;

    return SizedBox(
      height: Responsive.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: isDisabled ? LaapakColors.surfaceVariant : null,
          side: isDisabled
              ? BorderSide.none
              : BorderSide(color: LaapakColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.buttonRadius),
          ),
          padding: Responsive.buttonPadding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: LaapakTypography.button(
                color: isDisabled
                    ? LaapakColors.textDisabled
                    : LaapakColors.textPrimary,
              ),
            ),
            Icon(
              icon,
              size: Responsive.iconSizeMedium,
              color: isDisabled
                  ? LaapakColors.textDisabled
                  : LaapakColors.primary,
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
            AppConstants.errorInvoiceNotAvailable,
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
              AppConstants.errorUnauthorized,
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء فتح الفاتورة: ${e.toString()}',
              style: LaapakTypography.bodyMedium(
                color: LaapakColors.background,
              ),
            ),
            backgroundColor: LaapakColors.error,
          ),
        );
      }
    }
  }

  /// Show test notification
  Future<void> _showTestNotification(BuildContext context) async {
    try {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.showTestNotification();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppConstants.successNotificationSent,
              style: LaapakTypography.bodyMedium(
                color: LaapakColors.background,
              ),
            ),
            backgroundColor: LaapakColors.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء إرسال الإشعار: ${e.toString()}',
              style: LaapakTypography.bodyMedium(
                color: LaapakColors.background,
              ),
            ),
            backgroundColor: LaapakColors.error,
          ),
        );
      }
    }
  }

  /// Share report
  Future<void> _shareReport(
    BuildContext context,
    Map<String, dynamic> report,
  ) async {
    try {
      final shareService = ShareService.instance;
      await shareService.shareReport(
        reportId: report['id']?.toString() ?? '',
        deviceModel: report['device_model']?.toString() ?? 'غير محدد',
        serialNumber: report['serial_number']?.toString(),
        inspectionDate:
            report['inspection_date']?.toString() ??
            report['created_at']?.toString(),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء مشاركة التقرير',
              style: LaapakTypography.bodyMedium(
                color: LaapakColors.background,
              ),
            ),
            backgroundColor: LaapakColors.error,
          ),
        );
      }
    }
  }

  /// Build additional specs map from report data
  /// Only includes fields that are present and not null/empty
  Map<String, String>? _buildAdditionalSpecs(Map<String, dynamic> report) {
    final Map<String, String> specs = {};

    // Add CPU if available
    final cpu = report['cpu']?.toString();
    if (cpu != null && cpu.isNotEmpty && cpu != 'null') {
      specs['المعالج'] = cpu;
    }

    // Add GPU if available
    final gpu = report['gpu']?.toString();
    if (gpu != null && gpu.isNotEmpty && gpu != 'null') {
      specs['كرت الشاشة'] = gpu;
    }

    // Add RAM if available
    final ram = report['ram']?.toString();
    if (ram != null && ram.isNotEmpty && ram != 'null') {
      specs['الرامات'] = ram;
    }

    // Add Storage if available
    final storage = report['storage']?.toString();
    if (storage != null && storage.isNotEmpty && storage != 'null') {
      specs['التخزين'] = storage;
    }

    return specs.isNotEmpty ? specs : null;
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

  /// Open WhatsApp with support number
  Future<void> _openWhatsApp(BuildContext context) async {
    try {
      final phoneNumber = AppConstants.whatsappPhoneNumber;
      final message = Uri.encodeComponent('مرحباً، أنا عميل في لابك');

      // Try WhatsApp URL scheme first
      final whatsappUrl = 'whatsapp://send?phone=$phoneNumber&text=$message';
      final uri = Uri.parse(whatsappUrl);

      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri);
      } else {
        // Fallback to web WhatsApp
        final webUrl = 'https://wa.me/$phoneNumber?text=$message';
        await launchUrl(
          Uri.parse(webUrl),
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء فتح واتساب',
              style: LaapakTypography.bodyMedium(
                color: LaapakColors.background,
              ),
            ),
            backgroundColor: LaapakColors.error,
          ),
        );
      }
    }
  }

  /// Open Laapak website
  Future<void> _openWebsite(BuildContext context) async {
    try {
      final websiteUrl = AppConstants.appWebsite;
      final uri = Uri.parse(websiteUrl);

      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء فتح الموقع',
              style: LaapakTypography.bodyMedium(
                color: LaapakColors.background,
              ),
            ),
            backgroundColor: LaapakColors.error,
          ),
        );
      }
    }
  }
}
