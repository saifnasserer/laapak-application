import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';

/// Device Specs Card Widget
///
/// Reusable component for displaying device specifications.
/// Used in both order screen and reports screen.
class DeviceSpecsCard extends StatelessWidget {
  /// Device model
  final String? deviceModel;

  /// Serial number
  final String? serialNumber;

  /// Inspection date
  final String? inspectionDate;

  /// Device status
  final String? deviceStatus;

  /// Additional custom spec items
  final Map<String, String>? additionalSpecs;

  const DeviceSpecsCard({
    super.key,
    this.deviceModel,
    this.serialNumber,
    this.inspectionDate,
    this.deviceStatus,
    this.additionalSpecs,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: Responsive.cardPaddingInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'مواصفات الجهاز',
              style: LaapakTypography.titleLarge(
                color: LaapakColors.textPrimary,
              ),
            ),
            SizedBox(height: Responsive.md),
            if (deviceModel != null) ...[
              _buildSpecItem('الموديل', deviceModel!),
              SizedBox(height: Responsive.sm),
            ],
            if (serialNumber != null) ...[
              _buildSpecItem('الرقم التسلسلي', serialNumber!),
              SizedBox(height: Responsive.sm),
            ],
            if (inspectionDate != null) ...[
              _buildSpecItem('تاريخ الفحص', _formatDate(inspectionDate!)),
              SizedBox(height: Responsive.sm),
            ],
            if (deviceStatus != null) ...[
              _buildSpecItem('حالة الجهاز', deviceStatus!),
              if (additionalSpecs == null || additionalSpecs!.isEmpty)
                SizedBox(height: Responsive.sm),
            ],
            if (additionalSpecs != null && additionalSpecs!.isNotEmpty) ...[
              if (deviceStatus != null) SizedBox(height: Responsive.sm),
              ...additionalSpecs!.entries.map((entry) => Padding(
                    padding: EdgeInsets.only(bottom: Responsive.sm),
                    child: _buildSpecItem(entry.key, entry.value),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  /// Build a spec item row
  Widget _buildSpecItem(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: LaapakTypography.bodyMedium(
            color: LaapakColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: LaapakTypography.bodyMedium(
              color: LaapakColors.textPrimary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  /// Format date from ISO string or display as is
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      // Format as Arabic date
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

