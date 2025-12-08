import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/theme.dart';
import '../../../utils/responsive.dart';
import '../../device_care/device_care_screen.dart';

/// Order Confirmation Step Widget
///
/// Displays order confirmation details
class OrderConfirmationStep extends StatelessWidget {
  final Map<String, dynamic> reportData;

  const OrderConfirmationStep({super.key, required this.reportData});

  @override
  Widget build(BuildContext context) {
    final deviceModel = reportData['device_model']?.toString() ?? 'غير محدد';
    final serialNumber = reportData['serial_number']?.toString() ?? 'غير محدد';
    final inspectionDate =
        reportData['inspection_date']?.toString() ??
        reportData['created_at']?.toString() ??
        '';
    final status = reportData['status']?.toString() ?? 'غير محدد';
    final orderNumber =
        reportData['order_number']?.toString() ??
        reportData['orderCode']?.toString() ??
        'غير محدد';

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

    // Status text in Arabic
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
                  'تأكيد الطلب',
                  style: LaapakTypography.titleLarge(
                    color: LaapakColors.textPrimary,
                  ),
                ),
                SizedBox(height: Responsive.lg),

                // Order Number
                _buildInfoRow('رقم الطلب', orderNumber),
                SizedBox(height: Responsive.md),

                // Device Model
                _buildInfoRow('موديل الجهاز', deviceModel),
                SizedBox(height: Responsive.md),

                // Serial Number
                _buildInfoRow('الرقم التسلسلي', serialNumber),
                SizedBox(height: Responsive.md),

                // Inspection Date
                _buildInfoRow('تاريخ المعاينة', formattedDate),
                SizedBox(height: Responsive.md),

                // Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الحالة',
                      style: LaapakTypography.bodyMedium(
                        color: LaapakColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.sm,
                        vertical: Responsive.xs,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText,
                        style: LaapakTypography.labelSmall(color: statusColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: Responsive.lg),

        // Order Confirmation Button (WhatsApp)
        SizedBox(
          height: Responsive.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: () => _confirmOrderOnWhatsApp(context),
            icon: Icon(
              Icons.check_circle_outline,
              size: Responsive.iconSizeMedium,
              color: Colors.white,
            ),
            label: Text(
              'تأكيد الطلب',
              style: LaapakTypography.button(color: Colors.white),
            ),
            style:
                ElevatedButton.styleFrom(
                  backgroundColor: LaapakColors.primary,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      Responsive.buttonRadius,
                    ),
                  ),
                  padding: Responsive.buttonPadding,
                ).copyWith(
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                ),
          ),
        ),
        SizedBox(height: Responsive.md),

        // Device Care Button
        SizedBox(
          height: Responsive.buttonHeight,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeviceCareScreen(),
                ),
              );
            },
            icon: Icon(
              Icons.shield_outlined,
              size: Responsive.iconSizeMedium,
              color: LaapakColors.primary,
            ),
            label: Text(
              'ازاي تحافظ علي جهازك',
              style: LaapakTypography.button(color: LaapakColors.textPrimary),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: LaapakColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.buttonRadius),
              ),
              padding: Responsive.buttonPadding,
            ),
          ),
        ),
        SizedBox(height: Responsive.xl),
      ],
    );
  }

  /// Build info row for order confirmation
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: LaapakTypography.bodyMedium(color: LaapakColors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: LaapakTypography.bodyMedium(color: LaapakColors.textPrimary),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  /// Open WhatsApp to confirm order
  Future<void> _confirmOrderOnWhatsApp(BuildContext context) async {
    const phoneNumber = '+201013148007';
    const message =
        'انا راجعت التقرير وحابب أاكد الاوردر دلوقتي، ممكن اعرف هيوصل امتى؟';

    // Encode the message for URL
    final encodedMessage = Uri.encodeComponent(message);
    final whatsappUrl = 'https://wa.me/$phoneNumber?text=$encodedMessage';

    try {
      final uri = Uri.parse(whatsappUrl);

      // Try to launch directly - canLaunchUrl can be unreliable on Android
      // The "component name is null" warning is common but doesn't prevent launching
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (launchError) {
        // If direct launch fails, try with platformDefault mode
        try {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        } catch (e) {
          // If both fail, show error message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'لا يمكن فتح واتساب. يرجى التأكد من تثبيت التطبيق.',
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
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'حدث خطأ أثناء فتح واتساب. يرجى المحاولة مرة أخرى.',
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
