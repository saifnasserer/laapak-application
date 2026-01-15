import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/theme.dart';
import '../../utils/responsive.dart';
import '../../models/product_model.dart';
import '../../widgets/cached_image.dart';
import '../../providers/notification_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/products_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/notification_permission_dialog.dart';

/// Device Care Screen
///
/// Displays step-by-step advice for maintaining the device
class DeviceCareScreen extends ConsumerStatefulWidget {
  final int? initialStep;

  final String? reportOrderNumber;
  final String? deviceName;

  const DeviceCareScreen({
    super.key,
    this.initialStep,
    this.reportOrderNumber,
    this.deviceName,
  });

  @override
  ConsumerState<DeviceCareScreen> createState() => _DeviceCareScreenState();
}

class _DeviceCareScreenState extends ConsumerState<DeviceCareScreen> {
  int _currentStep = 0;
  PageController? _pageControllerNullable;
  PageController get _pageController =>
      _pageControllerNullable ??= PageController(initialPage: _currentStep);

  static const int _totalSteps = 5; // Total number of care steps

  @override
  void initState() {
    super.initState();
    // Set initial step from widget parameter, default to 0
    final requestedStep = widget.initialStep ?? 0;
    // Ensure step is within valid range (0 to _totalSteps-1)
    _currentStep = requestedStep >= 0 && requestedStep < _totalSteps
        ? requestedStep
        : 0;
  }

  @override
  void dispose() {
    _pageControllerNullable?.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _careSteps = [
    {
      'icon': Icons.shield_outlined,
      'title': 'خلي بالك على جهازك',
      'subtitle': 'نصايح بسيطة تحافظ بيها على اللابتوب أطول فترة ممكنة',
      'intro':
          'جهازك اتفحص قبل ما يتسلمك،\nوالنصايح دي هتساعدك تحافظ على كفاءته وجودته مع الاستخدام اليومي.',
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
      'solution':
          'التنظيف المنتظم بيساعد الجهاز يشتغل بكفاءة أفضل ولفترة أطول.',
      'warning': {
        'title': '❗ تنبيه مهم',
        'subtitle':
            'تجنب رش أي مواد سائلة للتنظيف على الكيبورد أو الجهاز بشكل مباشر',
        'problems': [
          'دخول السوائل للمفاتيح أو المكونات الداخلية',
          'أعطال مفاجئة يصعب إصلاحها',
        ],
        'solution':
            'دايمًا استخدم قطعة قماش مخصّصة أو رش السائل على القماش الأول، مش على الجهاز نفسه.',
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
      'solution':
          'الأسلوب البسيط ده بيساعد يحافظ على كفاءة البطارية وعمرها لأطول فترة ممكنة.',
    },

    {
      'icon': Icons.shopping_bag_outlined,
      'title': 'منتجات مفيدة',
      'subtitle': 'منتجات هتساعدك تحافظ على جهازك بشكل أفضل',
      'isProductsStep': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Pre-fetch products when screen opens so they're ready for step 7
    // Watching the provider here triggers it to start fetching immediately,
    // even if we're not on step 7 yet. The data will be cached and ready.
    ref.watch(careProductsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: LaapakColors.background,
        body: SafeArea(
          top: true,
          bottom: false,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // Sliver AppBar (scrollable header)
                SliverAppBar(
                  backgroundColor: LaapakColors.background,
                  elevation: 0,
                  pinned: false, // Allow it to scroll away completely
                  floating: true, // Snap back when scrolling up
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_outlined,
                      color: LaapakColors.textPrimary,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(
                    'ازاي تحافظ على جهازك؟',
                    style: LaapakTypography.titleLarge(
                      color: LaapakColors.textPrimary,
                    ),
                  ),
                ),

                // Step Indicator
                SliverToBoxAdapter(child: _buildStepIndicator()),
              ];
            },
            body: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              itemCount: _careSteps.length,
              itemBuilder: (context, index) {
                return SingleChildScrollView(
                  padding: Responsive.screenPadding,
                  child: Column(
                    children: [
                      _buildStepContent(index),
                      _buildNavigationButtons(index),
                      // Bottom padding to account for cart bottom bar
                      const SizedBox(height: 80),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Step indicator
  Widget _buildStepIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Responsive.md, horizontal: 40.0),
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
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
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
  Widget _buildStepContent(int stepIndex) {
    final step = _careSteps[stepIndex];

    if (stepIndex == 0) {
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
                color: LaapakColors.primary.withValues(alpha: 0.1),
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
              color: LaapakColors.primary.withValues(alpha: 0.1),
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
        if (step['isProductsStep'] == true) ...[
          _buildProductsList(),
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
              color: LaapakColors.info.withValues(alpha: 0.1),
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
              color: LaapakColors.success.withValues(alpha: 0.1),
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

          // Notification status card for cleaning step (step 2, index 1)
          if (stepIndex == 1) ...[
            SizedBox(height: Responsive.lg),
            _buildNotificationStatusCard(),
          ],

          // Warning section (for step 2)
          if (step['warning'] != null) ...[
            SizedBox(height: Responsive.lg),
            Card(
              color: LaapakColors.warning.withValues(alpha: 0.1),
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
                    ...((step['warning']['problems'] as List<String>).map((
                      problem,
                    ) {
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
  Widget _buildNavigationButtons(int stepIndex) {
    final totalSteps = _careSteps.length;
    final canGoPrevious = stepIndex > 0;
    final canGoNext = stepIndex < totalSteps - 1;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Responsive.lg,
        horizontal: Responsive.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          if (canGoPrevious)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: Responsive.sm),
                child: OutlinedButton.icon(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Responsive.buttonRadius,
                      ),
                    ),
                    side: BorderSide(color: LaapakColors.primary),
                  ),
                  icon: Icon(
                    Icons.arrow_forward,
                    color: LaapakColors.primary,
                  ), // RTL: Arrow forward points right (back)
                  label: Text(
                    'السابق',
                    style: LaapakTypography.titleMedium(
                      color: LaapakColors.primary,
                    ),
                  ),
                ),
              ),
            )
          else
            Spacer(),

          SizedBox(width: Responsive.md),

          // Next Button
          if (canGoNext)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: Responsive.sm),
                child: ElevatedButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Responsive.buttonRadius,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'التالي',
                        style: LaapakTypography.titleMedium(
                          color: Colors.white,
                        ).copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            )
          else
            // Finish Button
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: Responsive.sm),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LaapakColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    elevation: 4,
                    shadowColor: LaapakColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        Responsive.buttonRadius,
                      ),
                    ),
                  ),
                  icon: Icon(Icons.check, color: Colors.white),
                  label: Text(
                    'ضن',
                    style: LaapakTypography.titleMedium(
                      color: Colors.white,
                    ).copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build product card with image, description, and cart button
  Widget _buildProductCard(ProductModel product) {
    return Container(
      decoration: BoxDecoration(
        color: LaapakColors.surface,
        borderRadius: BorderRadius.circular(Responsive.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: LaapakColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Responsive.cardRadius),
              topRight: Radius.circular(Responsive.cardRadius),
            ),
            child: AspectRatio(
              aspectRatio: 1.2, // Slightly wider than square
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.white,
                  ), // White background for product images
                  Padding(
                    padding: EdgeInsets.all(Responsive.md),
                    child: CachedImage(
                      imageUrl: product.imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.contain,
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Product Info
          Padding(
            padding: EdgeInsets.all(Responsive.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  product.name,
                  style: LaapakTypography.titleMedium(
                    color: LaapakColors.textPrimary,
                  ).copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Responsive.xs),

                // Product Description
                Text(
                  product.description.replaceAll(
                    RegExp(r'<[^>]*>'),
                    '',
                  ), // Remove HTML tags
                  style: LaapakTypography.bodySmall(
                    color: LaapakColors.textSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: Responsive.md),

                // Price and Cart Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (product.price != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Responsive.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: LaapakColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${product.price!.toStringAsFixed(0)} ج.م',
                          style: LaapakTypography.titleSmall(
                            color: LaapakColors.primary,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),

                    // Add to Cart Button (Compact)
                    SizedBox(height: 40, child: _buildCartButton(product)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build products list from WooCommerce API
  Widget _buildProductsList() {
    final productsAsync = ref.watch(careProductsProvider);

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return Card(
            child: Padding(
              padding: Responsive.cardPaddingInsets,
              child: Text(
                'لا توجد منتجات متاحة حالياً',
                style: LaapakTypography.bodyMedium(
                  color: LaapakColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Column(
          children: products.map((product) {
            return Padding(
              padding: EdgeInsets.only(bottom: Responsive.md),
              child: _buildProductCard(product),
            );
          }).toList(),
        );
      },
      loading: () => Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Responsive.xl),
          child: Column(
            children: [
              CircularProgressIndicator(
                color: LaapakColors.primary,
                strokeWidth: 2,
              ),
              SizedBox(height: Responsive.md),
              Text(
                'جاري تحميل المنتجات...',
                style: LaapakTypography.bodyMedium(
                  color: LaapakColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stackTrace) {
        return Card(
          color: LaapakColors.error.withValues(alpha: 0.1),
          child: Padding(
            padding: Responsive.cardPaddingInsets,
            child: Column(
              children: [
                Icon(Icons.error_outline, color: LaapakColors.error, size: 48),
                SizedBox(height: Responsive.md),
                Text(
                  'حدث خطأ أثناء تحميل المنتجات',
                  style: LaapakTypography.titleSmall(color: LaapakColors.error),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Responsive.sm),
                Text(
                  'تأكد من اتصالك بالإنترنت وحاول مرة أخرى',
                  style: LaapakTypography.bodySmall(
                    color: LaapakColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Responsive.md),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(careProductsProvider);
                  },
                  icon: Icon(Icons.refresh, size: Responsive.iconSizeSmall),
                  label: Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LaapakColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build notification status card for cleaning reminders with toggle
  Widget _buildNotificationStatusCard() {
    final permissionStatusAsync = ref.watch(
      notificationPermissionsStatusProvider,
    );
    final preferenceAsync = ref.watch(notificationPreferenceProvider);

    return Card(
      child: Padding(
        padding: Responsive.cardPaddingInsets,
        child: permissionStatusAsync.when(
          data: (permissionGranted) {
            return preferenceAsync.when(
              data: (preferenceEnabled) {
                final hasPermission = permissionGranted == true;
                final isEnabled = hasPermission && preferenceEnabled;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isEnabled
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                          color: isEnabled
                              ? LaapakColors.success
                              : LaapakColors.textSecondary,
                          size: Responsive.iconSizeMedium,
                        ),
                        SizedBox(width: Responsive.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEnabled
                                    ? 'الإشعارات مفعلة'
                                    : 'الإشعارات معطلة',
                                style: LaapakTypography.titleSmall(
                                  color: LaapakColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: Responsive.xs),
                              Text(
                                isEnabled
                                    ? 'ستتلقى إشعاراً أسبوعياً لتذكيرك بتنظيف اللاب والحفاظ عليه!'
                                    : preferenceEnabled && !hasPermission
                                    ? 'يجب تفعيل صلاحيات الإشعارات أولاً'
                                    : 'فعّل الإشعارات لتلقي تذكير أسبوعي بتنظيف اللاب والحفاظ عليه.',
                                style: LaapakTypography.bodySmall(
                                  color: LaapakColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: preferenceEnabled,
                          onChanged: hasPermission
                              ? (value) async {
                                  // Update preference
                                  final storageServiceAsync = ref.read(
                                    storageServiceProvider,
                                  );
                                  final storageService =
                                      storageServiceAsync.value;
                                  if (storageService != null) {
                                    await storageService
                                        .setNotificationsEnabled(value);
                                    ref.invalidate(
                                      notificationPreferenceProvider,
                                    );

                                    final notificationService =
                                        NotificationService();
                                    await notificationService.initialize();

                                    if (value) {
                                      // Schedule notifications
                                      await notificationService
                                          .scheduledNotifications
                                          .scheduleWeeklyCleaningReminder();
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'تم تفعيل الإشعارات بنجاح',
                                            ),
                                            backgroundColor:
                                                LaapakColors.success,
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      // Cancel notifications
                                      await notificationService
                                          .scheduledNotifications
                                          .cancelWeeklyCleaningReminder();
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('تم إيقاف الإشعارات'),
                                            backgroundColor:
                                                LaapakColors.textSecondary,
                                            duration: const Duration(
                                              seconds: 2,
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                }
                              : null, // Disable toggle if no permission
                          activeThumbColor: LaapakColors.primary,
                        ),
                      ],
                    ),
                    if (!hasPermission) ...[
                      SizedBox(height: Responsive.md),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final notificationService = NotificationService();
                            await notificationService.initialize();

                            final result = await notificationService
                                .requestPermissions(forceRequest: true);

                            if (mounted) {
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                              ref.invalidate(
                                notificationPermissionsStatusProvider,
                              );

                              final isEnabled = await notificationService
                                  .areNotificationsEnabled();

                              if (result == true || isEnabled == true) {
                                // Schedule notifications if preference is enabled
                                final prefValue = preferenceAsync.value;
                                if (prefValue != null && prefValue == true) {
                                  await notificationService
                                      .scheduledNotifications
                                      .scheduleWeeklyCleaningReminder();
                                }
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'تم تفعيل صلاحيات الإشعارات',
                                      ),
                                      backgroundColor: LaapakColors.success,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
                              } else if (result == null) {
                                if (mounted) {
                                  await NotificationPermissionDialog.show(
                                    context,
                                  );
                                }
                              }
                            }
                          },
                          icon: Icon(
                            Icons.notifications_active,
                            size: Responsive.iconSizeSmall,
                          ),
                          label: Text('تفعيل صلاحيات الإشعارات'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: LaapakColors.primary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
              loading: () => Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: Responsive.md),
                  child: CircularProgressIndicator(
                    color: LaapakColors.primary,
                    strokeWidth: 2,
                  ),
                ),
              ),
              error: (error, stackTrace) {
                return Text(
                  'خطأ في تحميل إعدادات الإشعارات',
                  style: LaapakTypography.bodySmall(color: LaapakColors.error),
                );
              },
            );
          },
          loading: () => Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: Responsive.md),
              child: CircularProgressIndicator(
                color: LaapakColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),
          error: (error, stackTrace) {
            return Text(
              'خطأ في تحميل حالة الإشعارات',
              style: LaapakTypography.bodySmall(color: LaapakColors.error),
            );
          },
        ),
      ),
    );
  }

  /// Build cart button (shows added state if item is in cart)
  Widget _buildCartButton(ProductModel product) {
    final cartState = ref.watch(cartProvider);
    final isInCart = cartState.items.any(
      (item) => item.product.id == product.id,
    );

    if (isInCart) {
      return ElevatedButton.icon(
        onPressed: () {
          ref.read(cartProvider.notifier).removeFromCart(product.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم إزالة ${product.name} من السلة',
                style: LaapakTypography.bodyMedium(
                  color: LaapakColors.background,
                ),
              ),
              backgroundColor: LaapakColors.textSecondary,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        icon: Icon(Icons.check_circle, size: 18, color: Colors.white),
        label: Text(
          'تمت الإضافة',
          style: LaapakTypography.labelMedium(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: LaapakColors.success,
          elevation: 0,
          shadowColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.sm,
            vertical: Responsive.xs,
          ),
        ).copyWith(overlayColor: WidgetStateProperty.all(Colors.transparent)),
      );
    }

    return ElevatedButton.icon(
      onPressed: () {
        ref
            .read(cartProvider.notifier)
            .addToCart(
              product,
              reportOrderNumber: widget.reportOrderNumber,
              deviceName: widget.deviceName,
            );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إضافة ${product.name} للسلة',
              style: LaapakTypography.bodyMedium(
                color: LaapakColors.background,
              ),
            ),
            backgroundColor: LaapakColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      icon: Icon(Icons.shopping_cart_outlined, size: 18, color: Colors.white),
      label: Text(
        'أضف للسلة',
        style: LaapakTypography.labelMedium(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: LaapakColors.primary,
        elevation: 0,
        shadowColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.sm,
          vertical: Responsive.xs,
        ),
      ).copyWith(overlayColor: WidgetStateProperty.all(Colors.transparent)),
    );
  }
}
