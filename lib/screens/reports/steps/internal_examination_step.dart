import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../theme/theme.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/cached_image.dart';

/// Internal Examination Step Widget
///
/// Displays test screenshots with descriptions
class InternalExaminationStep extends StatelessWidget {
  final Map<String, dynamic> reportData;
  final Function(List<String>, int) onImageTap;

  const InternalExaminationStep({
    super.key,
    required this.reportData,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    // Get test screenshots (internal examination images)
    List<Map<String, dynamic>> testScreenshots = [];

    try {
      final imagesJson =
          reportData['external_images'] as String? ??
          reportData['externalImages'] as String? ??
          reportData['external_images_json'] as String?;

      if (imagesJson != null && imagesJson.isNotEmpty) {
        final decoded = jsonDecode(imagesJson);
        if (decoded is List) {
          for (var item in decoded) {
            if (item is Map<String, dynamic>) {
              final type = item['type']?.toString().toLowerCase() ?? '';
              if (type == 'test_screenshot') {
                testScreenshots.add(item);
              }
            }
          }
        }
      } else if (reportData['external_images'] is List) {
        final imagesList = reportData['external_images'] as List;
        for (var item in imagesList) {
          if (item is Map<String, dynamic>) {
            final type = item['type']?.toString().toLowerCase() ?? '';
            if (type == 'test_screenshot') {
              testScreenshots.add(item);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error parsing test screenshots: $e');
    }

    final notes = reportData['notes']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: Responsive.lg),

        // Test Screenshots - Improved Structure
        if (testScreenshots.isNotEmpty) ...[
          Text(
            'لقطات الفحص الداخلي',
            style: LaapakTypography.titleLarge(color: LaapakColors.textPrimary),
          ),
          SizedBox(height: Responsive.md),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: testScreenshots.length,
            itemBuilder: (context, index) {
              final screenshot = testScreenshots[index];
              final imageUrl = screenshot['url']?.toString() ?? '';
              final component = screenshot['component']?.toString() ?? '';
              final description = _getTestDescription(screenshot);

              return Card(
                margin: EdgeInsets.only(bottom: Responsive.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with Component Name
                    if (component.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.md,
                          vertical: Responsive.sm,
                        ),
                        decoration: BoxDecoration(
                          color: LaapakColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(Responsive.cardRadius),
                            topRight: Radius.circular(Responsive.cardRadius),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _getComponentIcon(component),
                              color: LaapakColors.primary,
                              size: Responsive.iconSizeMedium,
                            ),
                            SizedBox(width: Responsive.sm),
                            Expanded(
                              child: Text(
                                _getComponentLabel(component),
                                style: LaapakTypography.titleMedium(
                                  color: LaapakColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Screenshot Image - Expandable
                    GestureDetector(
                      onTap: () {
                        // Show full screen image
                        final imageUrls = testScreenshots
                            .map((img) => img['url']?.toString() ?? '')
                            .where((url) => url.isNotEmpty)
                            .toList();
                        onImageTap(imageUrls, index);
                      },
                      child: Container(
                        height: 300,
                        decoration: BoxDecoration(
                          color: LaapakColors.surfaceVariant,
                          borderRadius: component.isNotEmpty
                              ? null
                              : BorderRadius.only(
                                  topLeft: Radius.circular(
                                    Responsive.cardRadius,
                                  ),
                                  topRight: Radius.circular(
                                    Responsive.cardRadius,
                                  ),
                                ),
                        ),
                        child: ClipRRect(
                          borderRadius: component.isNotEmpty
                              ? BorderRadius.zero
                              : BorderRadius.only(
                                  topLeft: Radius.circular(
                                    Responsive.cardRadius,
                                  ),
                                  topRight: Radius.circular(
                                    Responsive.cardRadius,
                                  ),
                                ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CachedImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.contain,
                                headers: {'User-Agent': 'Mozilla/5.0'},
                                errorWidget: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported_outlined,
                                        color: LaapakColors.textSecondary,
                                        size: Responsive.iconSizeLarge,
                                      ),
                                      SizedBox(height: Responsive.xs),
                                      Text(
                                        'فشل تحميل الصورة',
                                        style: LaapakTypography.labelSmall(
                                          color: LaapakColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Tap to expand hint
                              Positioned(
                                bottom: Responsive.sm,
                                left: Responsive.sm,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Responsive.sm,
                                    vertical: Responsive.xs,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.fullscreen,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: Responsive.xs),
                                      Text(
                                        'اضغط للتكبير',
                                        style: LaapakTypography.labelSmall(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Description Section
                    Container(
                      padding: Responsive.cardPaddingInsets,
                      decoration: BoxDecoration(
                        color: LaapakColors.surface,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(Responsive.cardRadius),
                          bottomRight: Radius.circular(Responsive.cardRadius),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: LaapakColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              SizedBox(width: Responsive.sm),
                              Text(
                                'شرح الاختبار',
                                style: LaapakTypography.titleSmall(
                                  color: LaapakColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Responsive.sm),
                          Text(
                            description,
                            style: LaapakTypography.bodyMedium(
                              color: LaapakColors.textPrimary,
                            ).copyWith(height: 1.6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],

        // Notes
        if (notes.isNotEmpty)
          Card(
            child: Padding(
              padding: Responsive.cardPaddingInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ملاحظات الفحص',
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
        else if (testScreenshots.isEmpty)
          Center(
            child: Padding(
              padding: Responsive.screenPaddingV,
              child: Text(
                'لا توجد معلومات عن الفحص الداخلي',
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

  /// Get component label in Arabic
  String _getComponentLabel(String component) {
    final comp = component.toLowerCase();
    
    if (comp == 'info') {
      return 'تفاصيل اللابتوب';
    } else if (comp == 'cpu') {
      return 'اختبار البروسيسور';
    } else if (comp == 'gpu') {
      return 'اختبار كارت الشاشة';
    } else if (comp.contains('hdd') || comp.contains('storage')) {
      return 'اختبار الهارد';
    } else if (comp == 'battery') {
      return 'اختبار البطارية';
    } else if (comp == 'keyboard') {
      return 'اختبار الكيبورد';
    } else if (comp == 'dxdiag') {
      return 'اختبار DxDiag';
    } else {
      return 'اختبار $component';
    }
  }

  /// Get icon for component type
  IconData _getComponentIcon(String component) {
    final comp = component.toLowerCase();
    if (comp.contains('cpu')) {
      return Icons.memory;
    } else if (comp.contains('gpu')) {
      return Icons.videogame_asset;
    } else if (comp.contains('hdd') || comp.contains('storage')) {
      return Icons.storage;
    } else if (comp.contains('battery')) {
      return Icons.battery_charging_full;
    } else if (comp.contains('keyboard')) {
      return Icons.keyboard;
    } else if (comp.contains('info')) {
      return Icons.info_outline;
    } else if (comp.contains('dxdiag')) {
      return Icons.bug_report;
    } else {
      return Icons.screenshot_monitor;
    }
  }

  /// Get description text for a test screenshot based on component or notes
  String _getTestDescription(Map<String, dynamic> item) {
    String descriptionText = '';

    // First check if there are notes
    if (item['notes'] != null && item['notes'].toString().isNotEmpty) {
      descriptionText = item['notes'].toString();
    } else if (item['component'] != null) {
      final comp = item['component'].toString().toLowerCase();

      if (comp.contains('cpu')) {
        descriptionText =
            'لـ Stress Test للبروسيسور بيختبر قوة المعالج تحت ضغط تقيل، علشان يشوف لو هيقدر يشتغل بكفاءة في أقصى ظروف، وبيكشف لو في مشاكل زي السخونية أو الأداء الضعيف. يعني كأنك بتحط المعالج في "تمرين شاق" علشان تشوف هيستحمل ولا لأ..';
      } else if (comp.contains('gpu')) {
        descriptionText =
            'برنامج FurMark بيعمل stress test لكارت الشاشة، يعني بيشغله بأقصى طاقته علشان يشوف هيسخن قد إيه ويقدر يستحمل الضغط ولا لأ. مفيد علشان تختبر التبريد وتشوف لو في مشاكل زي الحرارة العالية أو تهنيج الجهاز أثناء الألعاب او وقت الضغط.';
      } else if (comp.contains('hdd') || comp.contains('storage')) {
        descriptionText =
            'برنامج Hard Disk Sentinel بيكشف حالة الهارد، سواء HDD أو SSD، وبيقولك لو في مشاكل زي الباد سيكتور أو أداء ضعيف. كأنك بتعمل كشف شامل للهارد علشان تطمن إنه شغال تمام ومش هيفاجئك بعطل مفاجئ.';
      } else if (comp.contains('battery')) {
        descriptionText =
            'الصورة دي لقطة من شاشة بتبين تفاصيل حالة بطارية اللابتوب، من خلال الـ BIOS.\n\nليه بنعمل الاختبار؟\n\nالهدف إنك تتأكد إن البطارية شغالة كويس وسليمة، يعني مش بتسخن أكتر من اللازم، ومش بتفقد شحن بسرعة، وبتدي الأداء اللي المفروض.\n\nتبص على إيه؟\n\nالحالة العامة: لو مكتوب إن البطارية سليمة، يبقى تمام.\nالسعة الحالية: لو السعة قليلة جدًا، يبقى البطارية بقت ضعيفة.\nلو فيه رسايل تحذير أو مشاكل، يعني فيه عيب في البطارية.\nالمخرجات إيه؟\n\nالحالة: (ممتاز) البطارية سليمة وسعتها كويسة،وبتعدي اقل وقت استخدام داخل الضمان ساعتين.';
      } else if (comp.contains('keyboard')) {
        descriptionText =
            'اختبار زرار الكيبورد بيشوف إذا كانت كل الزراير شغالة صح ولا لأ. بتضغط على كل زر وبتشوف لو الجهاز بيستجيب، وده مفيد في ان نتأكد لو في زراير مش شغالة أو بتعلق.';
      } else if (comp.contains('info')) {
        descriptionText =
            'الشاشة اللي بتعرض معلومات الجهاز بتوريك حاجات زي ال (Serial Number) واللي عامل زي البصمة لكل لابتوب، نوع المعالج (CPU)، الرامات (Memory)، كارت الشاشة (GPU)، نسخة الـ BIOS، وكمان شوية معلومات عن النظام والتعريفات. يعني بتديك نظرة سريعة وشاملة عن مكونات الجهاز وتفاصيلة كاملة.';
      } else if (comp.contains('dxdiag')) {
        descriptionText =
            'أداة dxdiag بتجمعلك معلومات عن الجهاز، زي كارت الشاشة، المعالج، الرامات، ونظام التشغيل، وكمان بتكشف لو في مشاكل في الـ DirectX. يعني باختصار، بتديك تقرير سريع عن حالة الجهاز، خصوصًا لو في مشكلة في الألعاب أو الجرافيكس.';
      } else {
        descriptionText =
            'الصورة دي بتوضح نتايج الاختبارات اللي اتعملت على الجهاز عشان نقيس الأداء ونتأكد إن كل حاجة حالتها ممتازة.';
      }
    } else {
      descriptionText =
          'الصورة دي بتوضح نتايج الاختبارات اللي اتعملت على الجهاز عشان نقيس الأداء ونتأكد إن كل حاجة حالتها ممتازة.';
    }

    return descriptionText;
  }
}

