import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/dismiss_keyboard.dart';
import '../../widgets/device_specs_card.dart';
import '../reports/reports_screen.dart';
import '../warranty/warranty_screen.dart';

/// Order Screen
///
/// Main dashboard screen for users with orders.
/// Displays device information and navigation options.
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LaapakColors.background,
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

                  // Device Name
                  _buildDeviceName(),

                  SizedBox(height: Responsive.xl),

                  // Device Specs Card (using reusable component)
                  DeviceSpecsCard(
                    deviceModel: 'iPhone 15 Pro Max',
                    serialNumber: 'ABC123456789',
                    inspectionDate: '2024-01-15T10:00:00Z',
                    deviceStatus: 'جيد',
                  ),

                  SizedBox(height: Responsive.xl),

                  // Navigation Buttons
                  _buildNavigationButtons(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Device name section
  Widget _buildDeviceName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'iPhone 15 Pro Max',
          style: LaapakTypography.displaySmall(
            color: LaapakColors.textPrimary,
          ),
        ),
        SizedBox(height: Responsive.xs),
        Text(
          '256 GB - تيتانيوم أزرق',
          style: LaapakTypography.bodyMedium(
            color: LaapakColors.textSecondary,
          ),
        ),
      ],
    );
  }


  /// Navigation buttons section
  Widget _buildNavigationButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Reports Button
        _buildNavButton(
          icon: Icons.description_outlined,
          text: 'التقارير',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReportsScreen(),
              ),
            );
          },
        ),

        SizedBox(height: Responsive.md),

        // Warranty Button
        _buildNavButton(
          icon: Icons.verified_outlined,
          text: 'الضمان',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WarrantyScreen(),
              ),
            );
          },
        ),

        SizedBox(height: Responsive.md),

        // Download Invoice Button
        _buildNavButton(
          icon: Icons.download_outlined,
          text: 'تحميل الفاتورة',
          onPressed: () {
            // Download invoice (to be implemented)
          },
        ),
      ],
    );
  }

  /// Build a navigation button
  Widget _buildNavButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: Responsive.buttonHeight,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: LaapakColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.buttonRadius),
          ),
          padding: Responsive.buttonPadding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              size: Responsive.iconSizeMedium,
              color: LaapakColors.primary,
            ),
            Text(
              text,
              style: LaapakTypography.button(
                color: LaapakColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

