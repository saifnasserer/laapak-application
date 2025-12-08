import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:lottie/lottie.dart';
import '../../../theme/theme.dart';
import '../../../utils/responsive.dart';

/// External Inspection Step Widget
///
/// Displays videos first, then images from the external inspection
class ExternalInspectionStep extends StatelessWidget {
  final Map<String, dynamic> reportData;
  final Function(String, int) onVideoTap;
  final Function(List<String>, int) onImageTap;
  final VideoPlayerController? videoController;
  final ChewieController? chewieController;
  final int? currentVideoIndex;
  final bool isVideoPlayerSupported;

  const ExternalInspectionStep({
    super.key,
    required this.reportData,
    required this.onVideoTap,
    required this.onImageTap,
    required this.videoController,
    required this.chewieController,
    required this.currentVideoIndex,
    required this.isVideoPlayerSupported,
  });

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> allMedia = [];
    List<Map<String, dynamic>> videos = [];
    List<Map<String, dynamic>> images = [];

    try {
      // Try different possible field names
      final imagesJson =
          reportData['external_images'] as String? ??
          reportData['externalImages'] as String? ??
          reportData['external_images_json'] as String?;

      debugPrint('📊 External Images JSON: $imagesJson');

      if (imagesJson != null && imagesJson.isNotEmpty) {
        // Try parsing as JSON string
        final decoded = jsonDecode(imagesJson);
        if (decoded is List) {
          // Handle list of objects with {type, url} or list of strings
          allMedia = decoded.map((item) {
            if (item is Map<String, dynamic>) {
              return item;
            } else {
              // Convert string to object
              return {'type': 'image', 'url': item.toString()};
            }
          }).toList();
        }
        debugPrint('📊 Parsed Media: $allMedia');
      } else {
        // Try if it's already a list
        if (reportData['external_images'] is List) {
          final imagesList = reportData['external_images'] as List;
          allMedia = imagesList.map((item) {
            if (item is Map<String, dynamic>) {
              return item;
            } else {
              return {'type': 'image', 'url': item.toString()};
            }
          }).toList();
        }
      }

      // Separate videos and images
      for (var media in allMedia) {
        final type = media['type']?.toString().toLowerCase() ?? '';
        if (type == 'video') {
          videos.add(media);
        } else if (type == 'image' || type.isEmpty) {
          images.add(media);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing external_images: $e');
      debugPrint('   Stack trace: $stackTrace');
    }

    if (videos.isEmpty && images.isEmpty) {
      return Center(
        child: Padding(
          padding: Responsive.screenPaddingV,
          child: Text(
            'لا توجد معاينة خارجية متاحة',
            style: LaapakTypography.bodyMedium(
              color: LaapakColors.textSecondary,
            ),
          ),
        ),
      );
    }

    debugPrint(
      '📊 Displaying ${videos.length} videos and ${images.length} images',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: Responsive.lg),

        // Videos Section
        if (videos.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: Responsive.cardPaddingInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الفيديوهات',
                    style: LaapakTypography.titleLarge(
                      color: LaapakColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: Responsive.md),

                  // Video Player - 16:9 aspect ratio (1920x1080)
                  if (isVideoPlayerSupported &&
                      currentVideoIndex != null &&
                      chewieController != null &&
                      videoController != null &&
                      videoController!.value.isInitialized &&
                      !videoController!.value.hasError)
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      margin: EdgeInsets.only(bottom: Responsive.md),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(
                          Responsive.cardRadius,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          Responsive.cardRadius,
                        ),
                        child: AspectRatio(
                          aspectRatio: 1920 / 1080, // 16:9 aspect ratio
                          child: Chewie(controller: chewieController!),
                        ),
                      ),
                    )
                  else if (isVideoPlayerSupported &&
                      currentVideoIndex != null &&
                      (chewieController == null ||
                          videoController == null ||
                          !videoController!.value.isInitialized))
                    // Show placeholder while video is initializing
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      margin: EdgeInsets.only(bottom: Responsive.md),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(
                          Responsive.cardRadius,
                        ),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1920 / 1080, // 16:9 aspect ratio
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                'assets/animation/loading_gray.json',
                                width: 80,
                                height: 80,
                              ),
                              SizedBox(height: Responsive.md),
                              Text(
                                'جاري تحميل الفيديو...',
                                style: LaapakTypography.bodyMedium(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else if (currentVideoIndex != null && !isVideoPlayerSupported)
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.5,
                      ),
                      margin: EdgeInsets.only(bottom: Responsive.md),
                      decoration: BoxDecoration(
                        color: LaapakColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(
                          Responsive.cardRadius,
                        ),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1920 / 1080, // 16:9 aspect ratio
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.videocam_off,
                                size: Responsive.iconSizeXLarge,
                                color: LaapakColors.textSecondary,
                              ),
                              SizedBox(height: Responsive.md),
                              Text(
                                'تشغيل الفيديو غير متاح على هذه المنصة',
                                style: LaapakTypography.bodyMedium(
                                  color: LaapakColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: Responsive.sm),
                              Text(
                                'يرجى فتح الرابط في المتصفح',
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
                ],
              ),
            ),
          ),
          SizedBox(height: Responsive.md),
        ],

        // Images Section
        if (images.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: Responsive.cardPaddingInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الصور',
                    style: LaapakTypography.titleLarge(
                      color: LaapakColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: Responsive.md),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final image = images[index];
                      final imageUrl = image['url']?.toString() ?? '';
                      final imageUrls = images
                          .map((img) => img['url']?.toString() ?? '')
                          .where((url) => url.isNotEmpty)
                          .toList();

                      return GestureDetector(
                        onTap: () => onImageTap(imageUrls, index),
                        child: Container(
                          height: 200,
                          margin: EdgeInsets.only(bottom: Responsive.md),
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
                              imageUrl,
                              fit: BoxFit.cover,
                              headers: {'User-Agent': 'Mozilla/5.0'},
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: LaapakColors.surfaceVariant,
                                  child: Center(
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
                                );
                              },
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      color: LaapakColors.surfaceVariant,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2,
                                          color: LaapakColors.primary,
                                        ),
                                      ),
                                    );
                                  },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],

        SizedBox(height: Responsive.xl),
      ],
    );
  }
}
