import 'dart:convert';
import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/dismiss_keyboard.dart';

/// Reports Screen
///
/// Displays detailed report information in steps including device status,
/// hardware components, images, and notes.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _currentStep = 0;

  // Mock data - replace with actual API data
  final Map<String, dynamic> reportData = {
    'id': 'RPT123456',
    'device_model': 'iPhone 15 Pro Max',
    'serial_number': 'ABC123456789',
    'inspection_date': '2024-01-15T10:00:00Z',
    'hardware_status':
        '[{"component": "screen", "status": "good"}, {"component": "battery", "status": "excellent"}, {"component": "camera", "status": "good"}]',
    'external_images': '["image1.jpg", "image2.jpg"]',
    'notes': 'الشاشة فيها خدوش بسيطة',
    'status': 'active',
    'billing_enabled': true,
    'amount': '500.00',
    'invoice_created': true,
    'invoice_id': 'INV123456',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LaapakColors.background,
      appBar: AppBar(
        title: Text(
          'التقرير',
          style: LaapakTypography.titleLarge(color: LaapakColors.textPrimary),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: DismissKeyboard(
          child: Directionality(
            textDirection: TextDirection.rtl, // RTL for Arabic
            child: Column(
              children: [
                // Step Indicator
                _buildStepIndicator(),

                // Step Content
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: Responsive.screenPadding,
                    child: _buildStepContent(),
                  ),
                ),

                // Navigation Buttons
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Step indicator
  Widget _buildStepIndicator() {
    final steps = ['حالة المكونات', 'صور الجهاز', 'ملاحظات'];

    return Container(
      padding: Responsive.screenPaddingV,
      decoration: BoxDecoration(
        color: LaapakColors.surface,
        border: Border(bottom: BorderSide(color: LaapakColors.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(steps.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _currentStep = index;
                });
              },
              child: Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isActive || isCompleted
                          ? LaapakColors.primary
                          : LaapakColors.surfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: isCompleted
                          ? Icon(Icons.check, color: Colors.white, size: 18)
                          : Text(
                              '${index + 1}',
                              style: LaapakTypography.labelMedium(
                                color: isActive
                                    ? Colors.white
                                    : LaapakColors.textSecondary,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: Responsive.xs),
                  Text(
                    steps[index],
                    style: LaapakTypography.labelSmall(
                      color: isActive
                          ? LaapakColors.primary
                          : LaapakColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Step content based on current step
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildHardwareStatusStep();
      case 1:
        return _buildExternalImagesStep();
      case 2:
        return _buildNotesStep();
      default:
        return _buildHardwareStatusStep();
    }
  }

  /// Step 1: Hardware Status
  Widget _buildHardwareStatusStep() {
    List<Map<String, dynamic>> hardwareStatus = [];

    try {
      final statusJson = reportData['hardware_status'] as String?;
      if (statusJson != null && statusJson.isNotEmpty) {
        hardwareStatus = List<Map<String, dynamic>>.from(
          jsonDecode(statusJson),
        );
      }
    } catch (e) {
      // Handle JSON parse error
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
        SizedBox(height: Responsive.xl),
      ],
    );
  }

  /// Step 2: External Images
  Widget _buildExternalImagesStep() {
    List<String> images = [];

    try {
      final imagesJson = reportData['external_images'] as String?;
      if (imagesJson != null && imagesJson.isNotEmpty) {
        images = List<String>.from(jsonDecode(imagesJson));
      }
    } catch (e) {
      // Handle JSON parse error
    }

    if (images.isEmpty) {
      return Center(
        child: Padding(
          padding: Responsive.screenPaddingV,
          child: Text(
            'لا توجد صور متاحة',
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
                  'صور الجهاز',
                  style: LaapakTypography.titleLarge(
                    color: LaapakColors.textPrimary,
                  ),
                ),
                SizedBox(height: Responsive.md),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 200,
                        margin: EdgeInsets.only(
                          left: index == 0 ? 0 : Responsive.sm,
                          right: index == images.length - 1 ? 0 : Responsive.sm,
                        ),
                        decoration: BoxDecoration(
                          color: LaapakColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(
                            Responsive.cardRadius,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            Responsive.cardRadius,
                          ),
                          child: Image.network(
                            images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  color: LaapakColors.textSecondary,
                                  size: Responsive.iconSizeLarge,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  color: LaapakColors.primary,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
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

  /// Step 3: Notes
  Widget _buildNotesStep() {
    final notes = reportData['notes']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: Responsive.lg),
        if (notes.isNotEmpty)
          Card(
            child: Padding(
              padding: Responsive.cardPaddingInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ملاحظات',
                    style: LaapakTypography.titleLarge(
                      color: LaapakColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: Responsive.md),
                  Text(
                    notes,
                    style: LaapakTypography.bodyMedium(
                      color: LaapakColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Center(
            child: Padding(
              padding: Responsive.screenPaddingV,
              child: Text(
                'لا توجد ملاحظات',
                style: LaapakTypography.bodyMedium(
                  color: LaapakColors.textSecondary,
                ),
              ),
            ),
          ),
        SizedBox(height: Responsive.xl),
      ],
    );
  }

  /// Build component status row
  Widget _buildComponentStatus(Map<String, dynamic> component) {
    final componentName = component['component'] ?? 'Unknown';
    final status = component['status'] ?? 'unknown';

    String statusText;
    Color statusColor;

    switch (status.toLowerCase()) {
      case 'excellent':
      case 'good':
        statusText = 'جيد';
        statusColor = LaapakColors.success;
        break;
      case 'fair':
        statusText = 'مقبول';
        statusColor = LaapakColors.warning;
        break;
      case 'poor':
      case 'bad':
        statusText = 'ضعيف';
        statusColor = LaapakColors.error;
        break;
      default:
        statusText = status;
        statusColor = LaapakColors.textSecondary;
    }

    // Map component names to Arabic
    final componentNames = {
      'screen': 'الشاشة',
      'battery': 'البطارية',
      'camera': 'الكاميرا',
      'speaker': 'مكبر الصوت',
      'microphone': 'الميكروفون',
      'charging_port': 'منفذ الشحن',
      'buttons': 'الأزرار',
      'housing': 'الهيكل',
    };

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          componentNames[componentName] ?? componentName,
          style: LaapakTypography.bodyMedium(color: LaapakColors.textPrimary),
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
    );
  }

  /// Navigation buttons (Previous/Next)
  Widget _buildNavigationButtons() {
    final totalSteps = 3;
    final canGoPrevious = _currentStep > 0;
    final canGoNext = _currentStep < totalSteps - 1;

    return Container(
      padding: Responsive.screenPadding,
      decoration: BoxDecoration(
        color: LaapakColors.surface,
        border: Border(top: BorderSide(color: LaapakColors.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          _buildNavIconButton(
            icon: Icons.arrow_back_ios_outlined,
            onPressed: canGoPrevious
                ? () {
                    setState(() {
                      _currentStep--;
                    });
                  }
                : null,
          ),

          // Step Indicator Text
          Text(
            '${_currentStep + 1} / $totalSteps',
            style: LaapakTypography.bodyMedium(
              color: LaapakColors.textSecondary,
            ),
          ),

          // Next Button
          _buildNavIconButton(
            icon: Icons.arrow_forward_ios_outlined,
            onPressed: canGoNext
                ? () {
                    setState(() {
                      _currentStep++;
                    });
                  }
                : null,
          ),
        ],
      ),
    );
  }

  /// Build circular navigation icon button
  Widget _buildNavIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: onPressed != null
            ? LaapakColors.primary
            : LaapakColors.surfaceVariant,
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Center(
            child: Icon(
              icon,
              color: onPressed != null
                  ? Colors.white
                  : LaapakColors.textDisabled,
              size: Responsive.iconSizeMedium,
            ),
          ),
        ),
      ),
    );
  }
}
