import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Cached Network Image Widget
///
/// A reusable widget that wraps CachedNetworkImage with consistent styling
/// and error handling for the Laapak app.
class CachedImage extends StatelessWidget {
  /// Image URL
  final String imageUrl;

  /// Image width
  final double? width;

  /// Image height
  final double? height;

  /// Box fit
  final BoxFit fit;

  /// Border radius
  final BorderRadius? borderRadius;

  /// Placeholder widget
  final Widget? placeholder;

  /// Error widget
  final Widget? errorWidget;

  /// HTTP headers
  final Map<String, String>? headers;

  /// Mem cache width (for optimization)
  final int? memCacheWidth;

  /// Mem cache height (for optimization)
  final int? memCacheHeight;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.headers,
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      httpHeaders: headers,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      placeholder: (context, url) =>
          placeholder ??
          Container(
            width: width,
            height: height,
            color: LaapakColors.surfaceVariant,
            child: Center(
              child: CircularProgressIndicator(
                color: LaapakColors.primary,
                strokeWidth: 2,
              ),
            ),
          ),
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: LaapakColors.surfaceVariant,
            child: Icon(
              Icons.image_outlined,
              size: 48,
              color: LaapakColors.textSecondary,
            ),
          ),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }
}


