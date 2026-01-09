import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../theme/theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/dismiss_keyboard.dart';
import '../../providers/reports_provider.dart';
import 'steps/external_inspection_step.dart';
import 'steps/hardware_status_step.dart';
import 'steps/internal_examination_step.dart';
import 'steps/order_confirmation_step.dart';

/// Reports Screen
///
/// Main screen that connects all report steps together
class ReportsScreen extends ConsumerStatefulWidget {
  final String? reportId;

  const ReportsScreen({super.key, this.reportId});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _currentStep = 0;
  String? _reportId;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  int? _currentVideoIndex;
  PageController? _pageControllerNullable;
  PageController get _pageController =>
      _pageControllerNullable ??= PageController(initialPage: _currentStep);

  @override
  void initState() {
    super.initState();
    _reportId = widget.reportId;
    debugPrint('📊 Reports Screen initialized with reportId: $_reportId');
  }

  // ... (keep _initializeFirstVideo as is)

  @override
  void dispose() {
    _pageControllerNullable?.dispose();
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
    super.dispose();
  }

  // ...

  /// Step content based on current step
  Widget _buildStepContent(Map<String, dynamic> reportData, int stepIndex) {
    switch (stepIndex) {
      case 0:
        return ExternalInspectionStep(
          reportData: reportData,
          onVideoTap: _playVideo,
          onImageTap: _showImageGallery,
          videoController: _videoController,
          chewieController: _chewieController,
          currentVideoIndex: _currentVideoIndex,
          isVideoPlayerSupported: _isVideoPlayerSupported,
        );
      case 1:
        return HardwareStatusStep(reportData: reportData);
      case 2:
        return InternalExaminationStep(
          reportData: reportData,
          onImageTap: _showImageGallery,
        );
      case 3:
        return OrderConfirmationStep(reportData: reportData);
      default:
        return ExternalInspectionStep(
          reportData: reportData,
          onVideoTap: _playVideo,
          onImageTap: _showImageGallery,
          videoController: _videoController,
          chewieController: _chewieController,
          currentVideoIndex: _currentVideoIndex,
          isVideoPlayerSupported: _isVideoPlayerSupported,
        );
    }
  }

  /// Initialize first video automatically when report data is available
  void _initializeFirstVideo(Map<String, dynamic> reportData) {
    // Only initialize if we're on step 0 (external inspection) and no video is currently playing
    if (_currentStep != 0 || _currentVideoIndex != null) return;

    try {
      // Parse external images to find videos
      List<Map<String, dynamic>> allMedia = [];
      final imagesJson =
          reportData['external_images'] as String? ??
          reportData['externalImages'] as String? ??
          reportData['external_images_json'] as String?;

      if (imagesJson != null && imagesJson.isNotEmpty) {
        final decoded = jsonDecode(imagesJson);
        if (decoded is List) {
          allMedia = decoded.map((item) {
            if (item is Map<String, dynamic>) {
              return item;
            } else {
              return {'type': 'image', 'url': item.toString()};
            }
          }).toList();
        }
      } else if (reportData['external_images'] is List) {
        final imagesList = reportData['external_images'] as List;
        allMedia = imagesList.map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          } else {
            return {'type': 'image', 'url': item.toString()};
          }
        }).toList();
      }

      // Find first video
      for (var media in allMedia) {
        final type = media['type']?.toString().toLowerCase() ?? '';
        if (type == 'video') {
          final videoUrl = media['url']?.toString() ?? '';
          if (videoUrl.isNotEmpty) {
            debugPrint('📹 Auto-initializing first video: $videoUrl');
            _playVideo(videoUrl, 0);
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error auto-initializing video: $e');
    }
  }

  bool get _isVideoPlayerSupported {
    // Video player is supported on mobile platforms and web
    if (kIsWeb) return true;
    if (Platform.isAndroid || Platform.isIOS) return true;
    // Not supported on desktop platforms (Linux, Windows, macOS)
    return false;
  }

  void _playVideo(String videoUrl, int index) {
    if (!_isVideoPlayerSupported) {
      // Show a dialog or snackbar that video playback isn't supported on this platform
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تشغيل الفيديو غير متاح على هذه المنصة. يرجى فتح الرابط في المتصفح.',
            style: LaapakTypography.bodyMedium(color: Colors.white),
          ),
          backgroundColor: LaapakColors.error,
          action: SnackBarAction(
            label: 'فتح الرابط',
            textColor: Colors.white,
            onPressed: () {
              // You can use url_launcher package to open the video URL
              debugPrint('Opening video URL: $videoUrl');
            },
          ),
        ),
      );
      return;
    }

    // Dispose previous controllers before creating new ones
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;

    setState(() {
      _currentVideoIndex = index;
    });

    try {
      debugPrint('📹 Initializing video player for: $videoUrl');

      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        httpHeaders: {'User-Agent': 'Mozilla/5.0'},
      );

      _videoController!
          .initialize()
          .timeout(
            const Duration(seconds: 60), // Increased to 60s
            onTimeout: () {
              // Just return normally on timeout to let catchError handle it
              // without crashing the app or printing scary red error logs prematurely
              if (!mounted || _currentStep != 0) return;
              debugPrint('⚠️ Video initialization timed out after 60s');
              throw TimeoutException(
                'Video loading timeout',
                const Duration(seconds: 60),
              );
            },
          )
          .then((_) {
            if (!mounted || _currentStep != 0) return;

            debugPrint('✅ Video initialized successfully');

            _chewieController = ChewieController(
              videoPlayerController: _videoController!,
              autoPlay: true,
              looping: false,
              allowFullScreen: true,
              allowMuting: true,
              allowPlaybackSpeedChanging: true,
              showControls: true,
              aspectRatio: 1920 / 1080, // 16:9 aspect ratio
              materialProgressColors: ChewieProgressColors(
                playedColor: LaapakColors.primary,
                handleColor: LaapakColors.primary,
                backgroundColor: LaapakColors.surfaceVariant,
                bufferedColor: LaapakColors.borderLight,
              ),
              placeholder: Container(
                color: LaapakColors.surfaceVariant,
                child: Center(
                  child: CircularProgressIndicator(color: LaapakColors.primary),
                ),
              ),
              errorBuilder: (context, errorMessage) {
                debugPrint('❌ Chewie error: $errorMessage');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: LaapakColors.error,
                        size: Responsive.iconSizeXLarge,
                      ),
                      SizedBox(height: Responsive.sm),
                      Text(
                        'فشل تحميل الفيديو',
                        style: LaapakTypography.bodyMedium(
                          color: LaapakColors.error,
                        ),
                      ),
                      if (errorMessage.isNotEmpty) ...[
                        SizedBox(height: Responsive.xs),
                        Text(
                          errorMessage,
                          style: LaapakTypography.bodySmall(
                            color: LaapakColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                );
              },
            );

            if (mounted) {
              setState(() {});
            }
          })
          .catchError((error, stackTrace) {
            debugPrint('❌ Error initializing video: $error');
            debugPrint('   Stack trace: $stackTrace');
            debugPrint('   Video URL: $videoUrl');

            debugPrint('   Video URL: $videoUrl');

            if (mounted && _currentStep == 0) {
              _chewieController?.dispose();
              _videoController?.dispose();
              _chewieController = null;
              _videoController = null;
              setState(() {
                _currentVideoIndex = null;
              });

              String errorMessage = 'فشل تحميل الفيديو';
              if (error is TimeoutException) {
                errorMessage = 'انتهت مهلة التحميل. تحقق من الاتصال بالإنترنت.';
              } else if (error.toString().contains('network')) {
                errorMessage = 'مشكلة في الاتصال. تحقق من الإنترنت.';
              } else if (error.toString().contains('format') ||
                  error.toString().contains('codec')) {
                errorMessage = 'تنسيق الفيديو غير مدعوم.';
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    errorMessage,
                    style: LaapakTypography.bodyMedium(color: Colors.white),
                  ),
                  backgroundColor: LaapakColors.error,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'إعادة المحاولة',
                    textColor: Colors.white,
                    onPressed: () => _playVideo(videoUrl, index),
                  ),
                ),
              );
            }
          });
    } catch (e, stackTrace) {
      debugPrint('❌ Error creating video controller: $e');
      debugPrint('   Stack trace: $stackTrace');
      if (mounted) {
        _chewieController?.dispose();
        _videoController?.dispose();
        _chewieController = null;
        _videoController = null;
        setState(() {
          _currentVideoIndex = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'خطأ في تشغيل الفيديو',
              style: LaapakTypography.bodyMedium(color: Colors.white),
            ),
            backgroundColor: LaapakColors.error,
          ),
        );
      }
    }
  }

  void _showImageGallery(List<String> imageUrls, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(imageUrls[index]),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                );
              },
              itemCount: imageUrls.length,
              loadingBuilder: (context, event) {
                if (event == null) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: LaapakColors.primary,
                    ),
                  );
                }
                return Center(
                  child: CircularProgressIndicator(
                    value: event.expectedTotalBytes != null
                        ? event.cumulativeBytesLoaded /
                              event.expectedTotalBytes!
                        : null,
                    color: LaapakColors.primary,
                  ),
                );
              },
              pageController: PageController(initialPage: initialIndex),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + Responsive.sm,
              right: Responsive.md,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get report ID from route arguments or use provided one
    final reportId =
        _reportId ??
        (ModalRoute.of(context)?.settings.arguments as String?) ??
        'RPT123456'; // Fallback for testing

    debugPrint('📊 Reports Screen - Using reportId: $reportId');
    final reportAsync = ref.watch(reportsProvider(reportId));

    return Scaffold(
      backgroundColor: LaapakColors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: DismissKeyboard(
          child: Directionality(
            textDirection: TextDirection.rtl, // RTL for Arabic
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  // Sliver AppBar (scrollable header)
                  SliverAppBar(
                    backgroundColor: LaapakColors.background,
                    elevation: 0,
                    pinned: false, // Allow it to scroll away completely
                    floating: true, // Snap back when scrolling up
                    centerTitle: true,
                    leading: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_outlined,
                        color: LaapakColors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: Text(
                      'التقرير',
                      style: LaapakTypography.titleLarge(
                        color: LaapakColors.textPrimary,
                      ),
                    ),
                  ),

                  // Step Indicator
                  SliverToBoxAdapter(child: _buildStepIndicator()),
                ];
              },
              body: reportAsync.when(
                data: (reportData) {
                  if (reportData == null) {
                    return Center(
                      child: Padding(
                        padding: Responsive.screenPaddingV,
                        child: Text(
                          'التقرير غير موجود',
                          style: LaapakTypography.bodyMedium(
                            color: LaapakColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }

                  // Auto-initialize first video if on external inspection step
                  // This runs on initial build if step is 0
                  if (_currentStep == 0) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _initializeFirstVideo(reportData);
                    });
                  }

                  return PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      final previousStep = _currentStep;
                      setState(() {
                        _currentStep = index;
                        // Reset video when switching away from step 0
                        if (previousStep == 0 && index != 0) {
                          _chewieController?.dispose();
                          _videoController?.dispose();
                          _chewieController = null;
                          _videoController = null;
                          _currentVideoIndex = null;
                        }
                      });

                      // Auto-initialize video if switching back to step 0
                      if (index == 0 && previousStep != 0) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _initializeFirstVideo(reportData);
                        });
                      }
                    },
                    itemCount: 4, // Total steps
                    itemBuilder: (context, index) {
                      return SingleChildScrollView(
                        padding: Responsive.screenPadding,
                        child: Column(
                          children: [
                            _buildStepContent(reportData, index),
                            _buildNavigationButtons(index),
                            // Bottom padding
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  );
                },
                loading: () => Center(
                  child: CircularProgressIndicator(color: LaapakColors.primary),
                ),
                error: (error, stackTrace) => Center(
                  child: Padding(
                    padding: Responsive.screenPaddingV,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: Responsive.iconSizeXLarge,
                          color: LaapakColors.error,
                        ),
                        SizedBox(height: Responsive.md),
                        Text(
                          'حدث خطأ في تحميل التقرير',
                          style: LaapakTypography.bodyMedium(
                            color: LaapakColors.error,
                          ),
                        ),
                        SizedBox(height: Responsive.sm),
                        Text(
                          error.toString(),
                          style: LaapakTypography.bodySmall(
                            color: LaapakColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Step indicator
  Widget _buildStepIndicator() {
    final steps = [
      'المعاينة الخارجية',
      'حالة المكونات',
      'الفحص الداخلي',
      'تأكيد الطلب',
    ];

    return Container(
      padding: EdgeInsets.symmetric(vertical: Responsive.md, horizontal: 40.0),
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

  /// Navigation buttons (Previous/Next)
  Widget _buildNavigationButtons(int stepIndex) {
    final totalSteps = 4;
    final canGoPrevious = stepIndex > 0;
    final canGoNext = stepIndex < totalSteps - 1;

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
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
          ),

          // Step Indicator Text
          Text(
            '${stepIndex + 1} / $totalSteps',
            style: LaapakTypography.bodyMedium(
              color: LaapakColors.textSecondary,
            ),
          ),

          // Next Button
          _buildNavIconButton(
            icon: Icons.arrow_forward_ios_outlined,
            onPressed: canGoNext
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
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
