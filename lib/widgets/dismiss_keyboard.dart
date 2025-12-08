import 'package:flutter/material.dart';

/// Dismiss Keyboard Widget
///
/// A reusable widget that wraps content and automatically dismisses
/// the keyboard when tapping outside text fields.
/// This is a global styling rule for all text fields in the app.
///
/// Usage:
/// ```dart
/// DismissKeyboard(
///   child: YourContent(),
/// )
/// ```
class DismissKeyboard extends StatelessWidget {
  /// Child widget to wrap
  final Widget child;

  const DismissKeyboard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
