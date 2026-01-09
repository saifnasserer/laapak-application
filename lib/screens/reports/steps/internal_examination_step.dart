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
                clipBehavior: Clip.antiAlias,
                elevation: 0, // Removed cluttering shadow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Responsive.cardRadius),
                  side: BorderSide(
                    color: LaapakColors.border.withValues(alpha: 0.5),
                  ),
                ),
                margin: EdgeInsets.only(
                  bottom: Responsive.md,
                ), // Reduced margin
                child: Theme(
                  data: Theme.of(
                    context,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(
                      horizontal: Responsive.md,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: LaapakColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getComponentIcon(component),
                        color: LaapakColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      _getComponentLabel(component),
                      style: LaapakTypography.titleMedium(
                        color: LaapakColors.textPrimary,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                    children: [
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
                          height: 200, // Slightly reduced height
                          color: LaapakColors.surfaceVariant.withOpacity(0.5),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (imageUrl.isNotEmpty)
                                CachedImage(
                                  imageUrl: imageUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit
                                      .contain, // Changed to contain to show full screenshot
                                  placeholder: Center(
                                    child: CircularProgressIndicator(
                                      color: LaapakColors.primary,
                                    ),
                                  ),
                                  errorWidget: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.broken_image_rounded,
                                          color: LaapakColors.textDisabled,
                                          size: 48,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'تعذر تحميل الصورة',
                                          style: LaapakTypography.labelMedium(
                                            color: LaapakColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: LaapakColors.textDisabled,
                                    size: 48,
                                  ),
                                ),

                              // Expand hint overlay
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.zoom_in,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
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

                      // Description
                      if (description.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.all(Responsive.md),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 18,
                                color: LaapakColors.textSecondary,
                              ),
                              SizedBox(width: Responsive.sm),
                              Expanded(
                                child: Text(
                                  description,
                                  style: LaapakTypography.bodyMedium(
                                    color: LaapakColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(height: Responsive.sm),
                    ],
                  ),
                ),
              );
            },
          ),
        ],

        // Notes
        if (notes.isNotEmpty)
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Responsive.cardRadius),
            ),
            child: Padding(
              padding: Responsive.cardPaddingInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        color: LaapakColors.secondary,
                      ),
                      SizedBox(width: Responsive.sm),
                      Text(
                        'ملاحظات الفنى',
                        style: LaapakTypography.titleLarge(
                          color: LaapakColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.md),
                  Container(
                    padding: EdgeInsets.all(Responsive.md),
                    decoration: BoxDecoration(
                      color: LaapakColors.surfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(Responsive.sm),
                      border: Border.all(
                        color: LaapakColors.border.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      notes,
                      style: LaapakTypography.bodyMedium(
                        color: LaapakColors.textPrimary,
                      ).copyWith(height: 1.5),
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
              child: Column(
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 48,
                    color: LaapakColors.textDisabled,
                  ),
                  SizedBox(height: Responsive.md),
                  Text(
                    'لا توجد معلومات عن الفحص الداخلي',
                    style: LaapakTypography.bodyMedium(
                      color: LaapakColors.textSecondary,
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

  /// Get component label in Arabic
  String _getComponentLabel(String component) {
    final comp = component.toLowerCase();

    if (comp == 'info') {
      return 'تفاصيل اللابتوب';
    }
    if (comp.contains('cpu')) {
      return 'اختبار المعالج (CPU)';
    }
    if (comp.contains('gpu')) {
      return 'اختبار كارت الشاشة (GPU)';
    }
    if (comp.contains('hdd') || comp.contains('storage')) {
      return 'اختبار التخزين (HDD/SSD)';
    }
    if (comp.contains('battery')) {
      return 'اختبار البطارية';
    }
    if (comp.contains('keyboard')) {
      return 'اختبار لوحة المفاتيح';
    }
    if (comp.contains('dxdiag')) {
      return 'تقرير DxDiag';
    }
    if (comp.contains('screen')) {
      return 'اختبار الشاشة';
    }
    if (comp.contains('cam')) {
      return 'اختبار الكاميرا';
    }
    if (comp.contains('audio') || comp.contains('sound')) {
      return 'اختبار الصوت';
    }
    if (comp.contains('wifi') || comp.contains('net')) {
      return 'اختبار الشبكة';
    }
    if (comp.contains('usb') || comp.contains('port')) {
      return 'اختبار المنافذ';
    }

    return 'اختبار $component';
  }

  /// Get icon for component type
  IconData _getComponentIcon(String component) {
    final comp = component.toLowerCase();
    if (comp.contains('cpu')) {
      return Icons.memory;
    }
    if (comp.contains('gpu')) {
      return Icons.videogame_asset;
    }
    if (comp.contains('hdd') || comp.contains('storage')) {
      return Icons.storage;
    }
    if (comp.contains('battery')) {
      return Icons.battery_charging_full;
    }
    if (comp.contains('keyboard')) {
      return Icons.keyboard;
    }
    if (comp.contains('info')) {
      return Icons.info_outline;
    }
    if (comp.contains('dxdiag')) {
      return Icons.bug_report;
    }
    if (comp.contains('screen')) {
      return Icons.monitor;
    }
    if (comp.contains('cam')) {
      return Icons.camera_alt;
    }
    if (comp.contains('audio') || comp.contains('sound')) {
      return Icons.volume_up;
    }
    if (comp.contains('wifi') || comp.contains('net')) {
      return Icons.wifi;
    }
    if (comp.contains('usb') || comp.contains('port')) {
      return Icons.usb;
    }

    return Icons.screenshot_monitor;
  }

  /// Get description text for a test screenshot based on component or notes
  String _getTestDescription(Map<String, dynamic> item) {
    String descriptionText = '';

    // First check if there are notes
    if (item['notes'] != null &&
        item['notes'].toString().isNotEmpty &&
        item['notes'].toString() != 'null') {
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
