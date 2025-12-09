import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';

/// Empty State Widget
///
/// A reusable empty state widget for displaying when there's no data.
class EmptyState extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Title text
  final String title;

  /// Subtitle/description text
  final String? subtitle;

  /// Action button (optional)
  final Widget? action;

  /// Custom icon size
  final double? iconSize;

  /// Custom icon color
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.iconSize,
    this.iconColor,
  });

  /// Empty state for no reports
  factory EmptyState.noReports({Widget? action}) {
    return EmptyState(
      icon: Icons.description_outlined,
      title: 'لا توجد تقارير متاحة',
      subtitle: 'لم يتم العثور على أي تقارير في حسابك',
      action: action,
    );
  }

  /// Empty state for no invoices
  factory EmptyState.noInvoices({Widget? action}) {
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'لا توجد فواتير متاحة',
      subtitle: 'لم يتم العثور على أي فواتير في حسابك',
      action: action,
    );
  }

  /// Empty state for no warranty
  factory EmptyState.noWarranty({Widget? action}) {
    return EmptyState(
      icon: Icons.verified_outlined,
      title: 'لا يوجد ضمان متاح',
      subtitle: 'لا يوجد ضمان مسجل لهذا الجهاز',
      action: action,
    );
  }

  /// Empty state for network error
  factory EmptyState.networkError({Widget? action}) {
    return EmptyState(
      icon: Icons.wifi_off_outlined,
      title: 'مشكلة في الاتصال',
      subtitle: 'تحقق من اتصالك بالإنترنت وحاول مرة أخرى',
      action: action,
      iconColor: LaapakColors.error,
    );
  }

  /// Empty state for error
  factory EmptyState.error({
    String? message,
    Widget? action,
  }) {
    return EmptyState(
      icon: Icons.error_outline,
      title: 'حدث خطأ',
      subtitle: message ?? 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى',
      action: action,
      iconColor: LaapakColors.error,
    );
  }

  /// Empty state for loading
  factory EmptyState.loading() {
    return const EmptyState(
      icon: Icons.hourglass_empty_outlined,
      title: 'جاري التحميل...',
      subtitle: 'يرجى الانتظار',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: Responsive.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize ?? Responsive.iconSizeXLarge,
              color: iconColor ?? LaapakColors.textSecondary,
            ),
            SizedBox(height: Responsive.lg),
            Text(
              title,
              style: LaapakTypography.titleMedium(
                color: LaapakColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: Responsive.sm),
              Text(
                subtitle!,
                style: LaapakTypography.bodyMedium(
                  color: LaapakColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(height: Responsive.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}


