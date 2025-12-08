import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import '../providers/auth_provider.dart';

/// App Drawer
///
/// Sidebar drawer with logout functionality
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final client = authState.client;

    return Directionality(
      textDirection: TextDirection.rtl, // RTL for Arabic
      child: Drawer(
        backgroundColor: LaapakColors.background,
        child: SafeArea(
          child: Column(
            children: [
              // Header with user info
              Container(
                width: double.infinity,
                padding: Responsive.cardPaddingInsets,
                decoration: BoxDecoration(
                  color: LaapakColors.primary.withOpacity(0.1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Responsive.md),
                    Icon(
                      Icons.person_outline,
                      size: Responsive.iconSizeXLarge,
                      color: LaapakColors.primary,
                    ),
                    SizedBox(height: Responsive.sm),
                    Text(
                      client?.name ?? 'المستخدم',
                      style: LaapakTypography.titleMedium(
                        color: LaapakColors.textPrimary,
                      ),
                    ),
                    if (client?.phone != null) ...[
                      SizedBox(height: Responsive.xs),
                      Text(
                        client!.phone,
                        style: LaapakTypography.bodySmall(
                          color: LaapakColors.textSecondary,
                        ),
                      ),
                    ],
                    SizedBox(height: Responsive.md),
                  ],
                ),
              ),

              // Spacer
              SizedBox(height: Responsive.lg),

              // Logout Button
              Padding(
                padding: Responsive.screenPaddingH,
                child: SizedBox(
                  width: double.infinity,
                  height: Responsive.buttonHeight,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      // Show confirmation dialog first (before closing drawer)
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: AlertDialog(
                            backgroundColor: LaapakColors.background,
                            title: Text(
                              'تأكيد تسجيل الخروج',
                              style: LaapakTypography.titleMedium(
                                color: LaapakColors.textPrimary,
                              ),
                            ),
                            content: Text(
                              'هل أنت متأكد من تسجيل الخروج؟',
                              style: LaapakTypography.bodyMedium(
                                color: LaapakColors.textSecondary,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(false),
                                child: Text(
                                  'إلغاء',
                                  style: LaapakTypography.button(
                                    color: LaapakColors.textSecondary,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(dialogContext).pop(true),
                                style: TextButton.styleFrom(
                                  foregroundColor: LaapakColors.error,
                                ),
                                child: Text(
                                  'تسجيل الخروج',
                                  style: LaapakTypography.button(
                                    color: LaapakColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );

                      // Close drawer
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }

                      if (shouldLogout == true) {
                        // Perform logout - use ref directly here
                        // The widget is still mounted at this point
                        await ref.read(authProvider.notifier).logout();
                        
                        // The main.dart will automatically navigate to LoginScreen
                        // when authState.isAuthenticated becomes false
                      }
                    },
                    icon: Icon(
                      Icons.logout,
                      size: Responsive.iconSizeMedium,
                      color: LaapakColors.error,
                    ),
                    label: Text(
                      'تسجيل الخروج',
                      style: LaapakTypography.button(
                        color: LaapakColors.error,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: LaapakColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          Responsive.buttonRadius,
                        ),
                      ),
                      padding: Responsive.buttonPadding,
                    ),
                  ),
                ),
              ),

              // Spacer to push content to top
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

