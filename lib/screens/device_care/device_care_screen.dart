import 'package:flutter/material.dart';
import '../../theme/theme.dart';
import '../../utils/responsive.dart';

/// Device Care Screen
///
/// Displays step-by-step advice for maintaining the device
class DeviceCareScreen extends StatefulWidget {
  const DeviceCareScreen({super.key});

  @override
  State<DeviceCareScreen> createState() => _DeviceCareScreenState();
}

class _DeviceCareScreenState extends State<DeviceCareScreen> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _careSteps = [
    {
      'icon': Icons.shield_outlined,
      'title': 'خلي بالك على جهازك',
      'subtitle': 'نصايح بسيطة تحافظ بيها على اللابتوب أطول فترة ممكنة',
      'intro': 'جهازك اتفحص قبل ما يتسلمك،\nوالنصايح دي هتساعدك تحافظ على كفاءته وجودته مع الاستخدام اليومي.',
    },
    {
      'icon': Icons.cleaning_services_outlined,
      'title': 'تنظيف الجهاز',
      'subtitle': 'تجنب إهمال تنظيف جهازك بشكل عام',
      'problems': [
        'ضعف في التبريد وزيادة درجة الحرارة',
        'دخول أتربة للمراوح ومخارج الهواء',
        'بهتان في شكل الجهاز وتقليل عمره الافتراضي',
      ],
      'solution': 'التنظيف المنتظم بيساعد الجهاز يشتغل بكفاءة أفضل ولفترة أطول.',
      'warning': {
        'title': '❗ تنبيه مهم',
        'subtitle': 'تجنب رش أي مواد سائلة للتنظيف على الكيبورد أو الجهاز بشكل مباشر',
        'problems': [
          'دخول السوائل للمفاتيح أو المكونات الداخلية',
          'أعطال مفاجئة يصعب إصلاحها',
        ],
        'solution': 'دايمًا استخدم قطعة قماش مخصّصة أو رش السائل على القماش الأول، مش على الجهاز نفسه.',
      },
    },
    {
      'icon': Icons.thermostat_outlined,
      'title': 'درجة حرارة الجهاز',
      'subtitle': 'تجنب استخدام اللابتوب على سطح مغلق أو غير مستوٍ',
      'problems': [
        'ارتفاع حرارة الجهاز',
        'بطء في الأداء',
        'تقليل العمر الافتراضي للمكونات',
      ],
      'solution': 'دايمًا استخدم الجهاز على سطح يسمح بمرور الهواء.',
    },
    {
      'icon': Icons.water_drop_outlined,
      'title': 'السوائل والأكل',
      'subtitle': 'إبعاد السوائل عن الجهاز قدر الإمكان',
      'problems': [
        'تلف مفاجئ',
        'أعطال غير قابلة للإصلاح أحيانًا',
      ],
      'solution': 'خليك حريص إن الأكل والمشروبات بعيد عن الجهاز.',
    },
    {
      'icon': Icons.power_outlined,
      'title': 'الشاحن والبطارية',
      'subtitle': 'استخدم الشاحن المناسب وراعي أسلوب الشحن',
      'problems': [
        'يضر بالبطارية على المدى الطويل',
        'يسبب عدم استقرار في الكهرباء',
        'يأثر على الماذربورد',
      ],
      'tips': [
        'تجنب سيب الجهاز على الشاحن فترات طويلة وهو 100٪',
        'يفضّل إن نسبة الشحن تكون غالبًا بين 20٪ و 80٪',
        'لو الجهاز سخن، افصله شوية وخليه يبرد قبل ما تشحنه تاني',
      ],
      'solution': 'الأسلوب البسيط ده بيساعد يحافظ على كفاءة البطارية وعمرها لأطول فترة ممكنة.',
    },
    {
      'icon': Icons.luggage_outlined,
      'title': 'الحمل والتنقل',
      'subtitle': 'تجنب وضع الجهاز داخل شنطة غير مبطنة',
      'problems': [
        'تكسر مفصلات الشاشة',
        'تأثر على الهارد أو البوردة',
      ],
      'solution': 'استخدم شنطة مخصصة لحماية الجهاز أثناء التنقل.',
    },
    {
      'icon': Icons.shopping_bag_outlined,
      'title': 'منتجات مفيدة',
      'subtitle': 'منتجات هتساعدك تحافظ على جهازك بشكل أفضل',
      'products': [
        {
          'name': 'مواد تنظيف مخصصة للشاشات',
          'description': 'مناديل وسوائل تنظيف آمنة على الشاشات',
        },
        {
          'name': 'شنطة حماية مبطنة',
          'description': 'شنطة مخصصة للابتوب بحماية من الصدمات',
        },
        {
          'name': 'قاعدة تبريد',
          'description': 'قاعدة تبريد لتحسين تدفق الهواء وتقليل الحرارة',
        },
        {
          'name': 'غطاء حماية للكيبورد',
          'description': 'غطاء سيليكون لحماية الكيبورد من الأتربة والسوائل',
        },
        {
          'name': 'شاحن احتياطي أصلي',
          'description': 'شاحن احتياطي أصلي متوافق مع جهازك',
        },
        {
          'name': 'حقيبة حماية للشاحن',
          'description': 'حقيبة لحماية كابل الشاحن من التلف',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: LaapakColors.background,
        appBar: AppBar(
          backgroundColor: LaapakColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_outlined,
              color: LaapakColors.textPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'صيانة الجهاز',
            style: LaapakTypography.titleLarge(color: LaapakColors.textPrimary),
          ),
        ),
        body: Column(
          children: [
            // Step Indicator
            _buildStepIndicator(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: Responsive.screenPadding,
                child: _buildStepContent(),
              ),
            ),

            // Navigation Buttons
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  /// Step indicator
  Widget _buildStepIndicator() {
    return Container(
      padding: Responsive.screenPaddingV,
      decoration: BoxDecoration(
        color: LaapakColors.surface,
        border: Border(bottom: BorderSide(color: LaapakColors.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_careSteps.length, (index) {
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
                ],
              ),
            ),
          );
        }),
      ),
    );
  }


  /// Build step content
  Widget _buildStepContent() {
    final step = _careSteps[_currentStep];

    if (_currentStep == 0) {
      // Introduction step
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: Responsive.lg),
          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: LaapakColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                step['icon'] as IconData,
                size: 40,
                color: LaapakColors.primary,
              ),
            ),
          ),
          SizedBox(height: Responsive.xl),
          // Title
          Text(
            step['title'] as String,
            style: LaapakTypography.headlineMedium(
              color: LaapakColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Responsive.md),
          // Subtitle
          Text(
            step['subtitle'] as String,
            style: LaapakTypography.titleMedium(
              color: LaapakColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Responsive.xl),
          // Intro text
          Card(
            child: Padding(
              padding: Responsive.cardPaddingInsets,
              child: Text(
                step['intro'] as String,
                style: LaapakTypography.bodyLarge(
                  color: LaapakColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );
    }

    // Regular care step
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: Responsive.lg),
        // Icon
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: LaapakColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              step['icon'] as IconData,
              size: 40,
              color: LaapakColors.primary,
            ),
          ),
        ),
        SizedBox(height: Responsive.xl),
        // Title
        Text(
          step['title'] as String,
          style: LaapakTypography.headlineMedium(
            color: LaapakColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Responsive.md),
        // Subtitle
        Text(
          step['subtitle'] as String,
          style: LaapakTypography.titleMedium(
            color: LaapakColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: Responsive.xl),
        
        // Products list (for step 7)
        if (step['products'] != null) ...[
          ...((step['products'] as List<Map<String, dynamic>>).map((product) {
            return Padding(
              padding: EdgeInsets.only(bottom: Responsive.md),
              child: Card(
                child: Padding(
                  padding: Responsive.cardPaddingInsets,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 20,
                            color: LaapakColors.primary,
                          ),
                          SizedBox(width: Responsive.sm),
                          Expanded(
                            child: Text(
                              product['name'] as String,
                              style: LaapakTypography.titleSmall(
                                color: LaapakColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (product['description'] != null) ...[
                        SizedBox(height: Responsive.xs),
                        Padding(
                          padding: EdgeInsets.only(right: Responsive.md + Responsive.sm),
                          child: Text(
                            product['description'] as String,
                            style: LaapakTypography.bodyMedium(
                              color: LaapakColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          })),
          SizedBox(height: Responsive.xl),
        ] else ...[
          // Problems card
          if (step['problems'] != null) ...[
            Card(
              child: Padding(
                padding: Responsive.cardPaddingInsets,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ده ممكن يؤدي إلى:',
                      style: LaapakTypography.titleSmall(
                        color: LaapakColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: Responsive.md),
                    ...((step['problems'] as List<String>).map((problem) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: Responsive.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 20,
                              color: LaapakColors.warning,
                            ),
                            SizedBox(width: Responsive.sm),
                            Expanded(
                              child: Text(
                                problem,
                                style: LaapakTypography.bodyMedium(
                                  color: LaapakColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    })),
                  ],
                ),
              ),
            ),
            SizedBox(height: Responsive.lg),
          ],
          
          // Tips section (for step 5)
          if (step['tips'] != null) ...[
            Card(
              color: LaapakColors.info.withOpacity(0.1),
              child: Padding(
                padding: Responsive.cardPaddingInsets,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'كمان، طريقة الشحن نفسها بتفرق 👇',
                      style: LaapakTypography.titleSmall(
                        color: LaapakColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: Responsive.md),
                    ...((step['tips'] as List<String>).map((tip) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: Responsive.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: LaapakColors.info,
                            ),
                            SizedBox(width: Responsive.sm),
                            Expanded(
                              child: Text(
                                tip,
                                style: LaapakTypography.bodyMedium(
                                  color: LaapakColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    })),
                  ],
                ),
              ),
            ),
            SizedBox(height: Responsive.lg),
          ],
          
          // Solution card
          if (step['solution'] != null)
            Card(
              color: LaapakColors.success.withOpacity(0.1),
              child: Padding(
                padding: Responsive.cardPaddingInsets,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 24,
                      color: LaapakColors.success,
                    ),
                    SizedBox(width: Responsive.sm),
                    Expanded(
                      child: Text(
                        step['solution'] as String,
                        style: LaapakTypography.bodyLarge(
                          color: LaapakColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Warning section (for step 2)
          if (step['warning'] != null) ...[
            SizedBox(height: Responsive.lg),
            Card(
              color: LaapakColors.warning.withOpacity(0.1),
              child: Padding(
                padding: Responsive.cardPaddingInsets,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['warning']['title'] as String,
                      style: LaapakTypography.titleSmall(
                        color: LaapakColors.warning,
                      ),
                    ),
                    SizedBox(height: Responsive.sm),
                    Text(
                      step['warning']['subtitle'] as String,
                      style: LaapakTypography.bodyMedium(
                        color: LaapakColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: Responsive.md),
                    Text(
                      'ده ممكن يؤدي إلى:',
                      style: LaapakTypography.labelLarge(
                        color: LaapakColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: Responsive.sm),
                    ...((step['warning']['problems'] as List<String>).map((problem) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: Responsive.xs),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 18,
                              color: LaapakColors.warning,
                            ),
                            SizedBox(width: Responsive.sm),
                            Expanded(
                              child: Text(
                                problem,
                                style: LaapakTypography.bodySmall(
                                  color: LaapakColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    })),
                    SizedBox(height: Responsive.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 20,
                          color: LaapakColors.success,
                        ),
                        SizedBox(width: Responsive.sm),
                        Expanded(
                          child: Text(
                            step['warning']['solution'] as String,
                            style: LaapakTypography.bodyMedium(
                              color: LaapakColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: Responsive.xl),
        ],
      ],
    );
  }

  /// Navigation buttons (Previous/Next)
  Widget _buildNavigationButtons() {
    final totalSteps = _careSteps.length;
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
      child: IconButton(
        icon: Icon(
          icon,
          color: onPressed != null ? Colors.white : LaapakColors.textDisabled,
          size: 20,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

