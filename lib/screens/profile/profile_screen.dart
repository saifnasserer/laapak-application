import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../theme/theme.dart';
import '../../utils/responsive.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/dismiss_keyboard.dart';

/// Profile Screen
///
/// View-only profile screen displaying client information and app details
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    } catch (e) {
      setState(() {
        _appVersion = 'غير متاح';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final client = authState.client;

    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: LaapakColors.background,
        appBar: AppBar(
          title: Text(
            'الملف الشخصي',
            style: LaapakTypography.headlineSmall(
              color: LaapakColors.textPrimary,
            ),
          ),
          backgroundColor: LaapakColors.surface,
          elevation: 0,
          iconTheme: IconThemeData(color: LaapakColors.textPrimary),
        ),
        body: client == null
            ? Center(
                child: Text(
                  'لا توجد بيانات متاحة',
                  style: LaapakTypography.bodyLarge(
                    color: LaapakColors.textSecondary,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: Responsive.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    _buildProfileHeader(client.name),
                    SizedBox(height: Responsive.lg),

                    // Contact Information Section
                    _buildSectionTitle('معلومات الاتصال'),
                    SizedBox(height: Responsive.sm),
                    _buildInfoCard([
                      _buildInfoRow(
                        icon: Icons.phone_outlined,
                        label: 'رقم الهاتف',
                        value: client.phone,
                      ),
                      if (client.email != null && client.email!.isNotEmpty) ...[
                        Divider(color: LaapakColors.borderLight),
                        _buildInfoRow(
                          icon: Icons.email_outlined,
                          label: 'البريد الإلكتروني',
                          value: client.email!,
                        ),
                      ],
                      if (client.address != null &&
                          client.address!.isNotEmpty) ...[
                        Divider(color: LaapakColors.borderLight),
                        _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          label: 'العنوان',
                          value: client.address!,
                        ),
                      ],
                    ]),
                    SizedBox(height: Responsive.lg),

                    // Account Information Section
                    _buildSectionTitle('معلومات الحساب'),
                    SizedBox(height: Responsive.sm),
                    _buildInfoCard([
                      _buildInfoRow(
                        icon: Icons.qr_code,
                        label: 'كود الطلب',
                        value: client.orderCode,
                      ),
                      Divider(color: LaapakColors.borderLight),
                      _buildInfoRow(
                        icon: Icons.badge_outlined,
                        label: 'رقم العميل',
                        value: '#${client.id}',
                      ),
                      if (client.status != null &&
                          client.status!.isNotEmpty) ...[
                        Divider(color: LaapakColors.borderLight),
                        _buildInfoRow(
                          icon: Icons.check_circle_outline,
                          label: 'حالة الحساب',
                          value: _translateStatus(client.status!),
                        ),
                      ],
                      if (client.createdAt != null) ...[
                        Divider(color: LaapakColors.borderLight),
                        _buildInfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'تاريخ التسجيل',
                          value: _formatDate(client.createdAt!),
                        ),
                      ],
                    ]),
                    SizedBox(height: Responsive.lg),

                    // App Information Section
                    _buildSectionTitle('معلومات التطبيق'),
                    SizedBox(height: Responsive.sm),
                    _buildInfoCard([
                      _buildInfoRow(
                        icon: Icons.info_outline,
                        label: 'الإصدار',
                        value: _appVersion,
                      ),
                      Divider(color: LaapakColors.borderLight),
                      _buildInfoRow(
                        icon: Icons.business_outlined,
                        label: 'الشركة',
                        value: 'Laapak',
                      ),
                    ]),
                    SizedBox(height: Responsive.xl),

                    // Logout Button
                    _buildLogoutButton(),
                    SizedBox(height: Responsive.lg),
                  ],
                ),
              ),
      ),
    );
  }

  /// Build profile header with name
  Widget _buildProfileHeader(String name) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.lg),
      decoration: BoxDecoration(
        color: LaapakColors.surface,
        borderRadius: BorderRadius.circular(Responsive.cardRadius),
        border: Border.all(color: LaapakColors.borderLight),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: LaapakColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, size: 40, color: LaapakColors.primary),
          ),
          SizedBox(height: Responsive.md),
          Text(
            name,
            style: LaapakTypography.headlineMedium(
              color: LaapakColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Build section title
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: LaapakTypography.titleMedium(color: LaapakColors.textPrimary),
    );
  }

  /// Build info card containing multiple info rows
  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(Responsive.md),
      decoration: BoxDecoration(
        color: LaapakColors.surface,
        borderRadius: BorderRadius.circular(Responsive.cardRadius),
        border: Border.all(color: LaapakColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  /// Build individual info row
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: Responsive.iconSizeSmall,
            color: LaapakColors.primary,
          ),
          SizedBox(width: Responsive.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: LaapakTypography.labelSmall(
                    color: LaapakColors.textSecondary,
                  ),
                ),
                SizedBox(height: Responsive.xs),
                Text(
                  value,
                  style: LaapakTypography.bodyMedium(
                    color: LaapakColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Copy button for text values
          IconButton(
            icon: Icon(
              Icons.copy,
              size: Responsive.iconSizeSmall,
              color: LaapakColors.textSecondary,
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم نسخ: $label'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: LaapakColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build logout button
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Show confirmation dialog
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'تسجيل الخروج',
                style: LaapakTypography.titleMedium(
                  color: LaapakColors.textPrimary,
                ),
              ),
              content: Text(
                'هل أنت متأكد أنك تريد تسجيل الخروج؟',
                style: LaapakTypography.bodyMedium(
                  color: LaapakColors.textSecondary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'إلغاء',
                    style: LaapakTypography.button(
                      color: LaapakColors.textSecondary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LaapakColors.error,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    'تسجيل الخروج',
                    style: LaapakTypography.button(color: Colors.white),
                  ),
                ),
              ],
            ),
          );

          if (confirmed == true && mounted) {
            // Perform logout
            await ref.read(authProvider.notifier).logout();
          }
        },
        icon: Icon(Icons.logout, color: Colors.white),
        label: Text(
          'تسجيل الخروج',
          style: LaapakTypography.button(color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: LaapakColors.error,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: Responsive.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Responsive.buttonRadius),
          ),
        ),
      ),
    );
  }

  /// Translate status to Arabic
  String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return 'نشط';
      case 'inactive':
        return 'غير نشط';
      case 'pending':
        return 'قيد الانتظار';
      default:
        return status;
    }
  }

  /// Format date to Arabic-friendly format
  String _formatDate(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
