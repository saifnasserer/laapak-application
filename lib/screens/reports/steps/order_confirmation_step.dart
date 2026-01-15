import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/theme.dart';
import '../../../utils/responsive.dart';
import '../../../utils/constants.dart';
import '../../device_care/device_care_screen.dart';

/// Order Confirmation Step Widget
///
/// Displays order confirmation details
class OrderConfirmationStep extends StatefulWidget {
  final Map<String, dynamic> reportData;

  const OrderConfirmationStep({super.key, required this.reportData});

  @override
  State<OrderConfirmationStep> createState() => _OrderConfirmationStepState();
}

class _OrderConfirmationStepState extends State<OrderConfirmationStep>
    with AutomaticKeepAliveClientMixin {
  bool _isConfirmed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final reportData = widget.reportData;
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
    final normalizedStatus = status.toLowerCase();
    switch (normalizedStatus) {
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

    final isReportCompleted = normalizedStatus == 'completed';

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
                _buildInfoRow(
                  'رقم الطلب',
                  orderNumber,
                  Icons.confirmation_number_outlined,
                ),
                SizedBox(height: Responsive.md),

                // Device Model
                _buildInfoRow(
                  'موديل الجهاز',
                  deviceModel,
                  Icons.laptop_mac_outlined,
                ),
                SizedBox(height: Responsive.md),

                // Serial Number
                _buildInfoRow(
                  'الرقم التسلسلي',
                  serialNumber,
                  Icons.qr_code_outlined,
                ),
                SizedBox(height: Responsive.md),

                // Inspection Date
                _buildInfoRow(
                  'تاريخ المعاينة',
                  formattedDate,
                  Icons.calendar_today_outlined,
                ),
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
              ],
            ),
          ),
        ),
        SizedBox(height: Responsive.lg),

        // Order Confirmation Button (WhatsApp)
        SizedBox(
          height: Responsive.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: isReportCompleted ? null : () => _confirmOrder(context),
            icon: Icon(
              (isReportCompleted || _isConfirmed)
                  ? Icons.check_circle
                  : Icons.check_circle_outline,
              size: Responsive.iconSizeMedium,
              color: Colors.white,
            ),
            label: Text(
              isReportCompleted
                  ? 'تم اكتمال الطلب'
                  : (_isConfirmed ? 'تم التأكيد' : 'تأكيد الطلب'),
              style: LaapakTypography.button(color: Colors.white),
            ),
            style:
                ElevatedButton.styleFrom(
                  backgroundColor: (isReportCompleted || _isConfirmed)
                      ? LaapakColors.success
                      : LaapakColors.primary,
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
                  builder: (context) => DeviceCareScreen(
                    reportOrderNumber: orderNumber,
                    deviceName: deviceModel,
                  ),
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
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: LaapakColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: LaapakColors.textSecondary),
              ),
              SizedBox(width: Responsive.md),
              Text(
                label,
                style: LaapakTypography.bodyMedium(
                  color: LaapakColors.textSecondary,
                ),
              ),
            ],
          ),
          Expanded(
            child: Text(
              value,
              style: LaapakTypography.titleSmall(
                color: LaapakColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to handle order confirmation
  void _confirmOrder(BuildContext context) {
    setState(() {
      _isConfirmed = true;
    });
    _confirmOrderOnWhatsApp(context);
  }

  /// Open WhatsApp to confirm order
  Future<void> _confirmOrderOnWhatsApp(BuildContext context) async {
    const phoneNumber = AppConstants.whatsappPhoneNumber;
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
