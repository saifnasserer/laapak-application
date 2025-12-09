import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';

/// Loading Button Widget
///
/// A reusable button component that shows a Lottie loading animation
/// when in loading state. Follows DeepSeek style - calm and minimal.
///
/// Usage:
/// ```dart
/// LoadingButton(
///   text: 'سجل دخول',
///   isLoading: _isLoading,
///   onPressed: () async {
///     setState(() => _isLoading = true);
///     await yourAsyncOperation();
///     setState(() => _isLoading = false);
///   },
/// )
/// ```
class LoadingButton extends StatelessWidget {
  /// Button text
  final String text;

  /// Loading state
  final bool isLoading;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button height (default: Responsive.buttonHeight)
  final double? height;

  /// Custom text style
  final TextStyle? textStyle;

  /// Custom background color (default: LaapakColors.primary)
  final Color? backgroundColor;

  /// Custom text color (default: Colors.white)
  final Color? textColor;

  /// Loading animation size (default: 24)
  final double loadingSize;

  /// Loading animation asset path (default: gray loading animation)
  final String? loadingAsset;

  const LoadingButton({
    super.key,
    required this.text,
    required this.isLoading,
    this.onPressed,
    this.height,
    this.textStyle,
    this.backgroundColor,
    this.textColor,
    this.loadingSize = 24,
    this.loadingAsset,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? Responsive.buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style:
            ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? LaapakColors.primary,
              foregroundColor: textColor ?? Colors.white,
              // Global styling rule: All buttons have elevation 0 (flat design)
              elevation: 0,
              // Remove shadow on press
              shadowColor: Colors.transparent,
              // Remove splash/ripple effect (no shadow/ripple on click)
              splashFactory: NoSplash.splashFactory,
              disabledBackgroundColor: (backgroundColor ?? LaapakColors.primary)
                  .withValues(alpha: 0.7),
              disabledForegroundColor: textColor ?? Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Responsive.buttonRadius),
              ),
            ).copyWith(
              // Remove overlay color on press (no shadow/ripple effect)
              overlayColor: WidgetStateProperty.all(Colors.transparent),
            ),
        child: isLoading
            ? SizedBox(
                height: loadingSize,
                width: loadingSize,
                child:
                    (backgroundColor == null ||
                        backgroundColor == LaapakColors.primary)
                    ? ColorFiltered(
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcATop,
                        ),
                        child: Lottie.asset(
                          loadingAsset ?? 'assets/animation/loading_gray.json',
                          fit: BoxFit.contain,
                        ),
                      )
                    : Lottie.asset(
                        loadingAsset ?? 'assets/animation/loading_gray.json',
                        fit: BoxFit.contain,
                      ),
              )
            : Text(
                text,
                style:
                    textStyle ??
                    LaapakTypography.button(color: textColor ?? Colors.white),
              ),
      ),
    );
  }
}
