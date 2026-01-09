import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/theme.dart';
import '../../utils/constants.dart';
import '../../utils/responsive.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/dismiss_keyboard.dart';
import '../../providers/auth_provider.dart';
import '../order/order_screen.dart';

/// Login Screen
///
/// A modern, creative update to the authentication screen.
/// Features a dynamic curved background and a clean, floating interface.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controllers
  final _phoneController = TextEditingController();
  final _orderCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // State
  bool _phoneValid = false;
  bool _orderCodeValid = false;

  // Focus nodes
  final _phoneFocusNode = FocusNode();
  final _orderCodeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhone);
    _orderCodeController.addListener(_validateOrderCode);
    _phoneFocusNode.addListener(() => setState(() {}));
    _orderCodeFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _orderCodeController.dispose();
    _phoneFocusNode.dispose();
    _orderCodeFocusNode.dispose();
    super.dispose();
  }

  TextInputFormatter get _upperCaseFormatter =>
      TextInputFormatter.withFunction((oldValue, newValue) {
        return newValue.copyWith(text: newValue.text.toUpperCase());
      });

  void _validatePhone() {
    final value = _phoneController.text;
    if (value.isEmpty) {
      setState(() => _phoneValid = false);
      return;
    }
    final cleanedPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    setState(
      () => _phoneValid = AppConstants.phonePattern.hasMatch(cleanedPhone),
    );
  }

  void _validateOrderCode() {
    final value = _orderCodeController.text.trim();
    if (value.isEmpty) {
      setState(() => _orderCodeValid = false);
      return;
    }
    setState(
      () => _orderCodeValid = AppConstants.orderCodePattern.hasMatch(
        value.toUpperCase(),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.mediumImpact();
      final phone = _phoneController.text
          .replaceAll(RegExp(r'[\s\-\(\)]'), '')
          .trim();
      final orderCode = _orderCodeController.text.trim().toUpperCase();

      await ref
          .read(authProvider.notifier)
          .login(phone: phone, orderCode: orderCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated != true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OrderScreen()),
        );
      }

      if (next.error != null && next.error != previous?.error) {
        if (next.error!.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: LaapakColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          ref.read(authProvider.notifier).clearError();
        }
      }
    });

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: DismissKeyboard(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    _buildHeader(),

                    const SizedBox(height: 48),

                    // Login Form
                    _buildLoginForm(),

                    const SizedBox(height: 32),

                    // Support
                    _buildSupportOption(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: LaapakColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/logo/Logo-mark.png',
              height: 64,
              width: 64,
              errorBuilder: (ctx, err, stack) => Icon(
                Icons.widgets_rounded,
                size: 40,
                color: LaapakColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Column(
          children: [
            Text(
              'اهلاً بيك 👋',
              style: LaapakTypography.headlineMedium(
                color: LaapakColors.textPrimary,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'سجل دخول عشان تشوف التفاصيل كلها',
              style: LaapakTypography.bodyLarge(
                color: LaapakColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    final authState = ref.watch(authProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMinimalTextField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            hint: 'رقم تليفونك',
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            isValid: _phoneValid,
            validator: (val) {
              if (val == null || val.isEmpty) {
                return AppConstants.errorPhoneRequired;
              }
              final cleaned = val.replaceAll(RegExp(r'[\s\-\(\)]'), '');
              if (!AppConstants.phonePattern.hasMatch(cleaned)) {
                return AppConstants.errorPhoneInvalid;
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          _buildMinimalTextField(
            controller: _orderCodeController,
            focusNode: _orderCodeFocusNode,
            hint: 'الكود بتاعك (LPK123)',
            icon: Icons.qr_code_rounded,
            isValid: _orderCodeValid,
            isLast: true,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [_upperCaseFormatter],
            validator: (val) {
              if (val == null || val.isEmpty) {
                return AppConstants.errorOrderCodeRequired;
              }
              if (!AppConstants.orderCodePattern.hasMatch(
                val.toUpperCase().trim(),
              )) {
                return AppConstants.errorOrderCodeInvalid;
              }
              return null;
            },
          ),

          if (authState.error != null && authState.error!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: LaapakColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Responsive.buttonRadius),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: LaapakColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      authState.error!,
                      style: LaapakTypography.bodySmall(
                        color: LaapakColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 32),

          SizedBox(
            height: 56,
            child: LoadingButton(
              text: 'يلا بينا',
              isLoading: authState.isLoading,
              onPressed: _handleLogin,
              backgroundColor: LaapakColors.primary,
              textColor: Colors.white,
              // Uses default Responsive.buttonRadius (30.0) which is pill shaped
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    bool isValid = false,
    bool isLast = false,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    final isFocused = focusNode.hasFocus;
    final hasValue = controller.text.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Light grey fill
        borderRadius: BorderRadius.circular(Responsive.buttonRadius),
        border: Border.all(
          color: isFocused ? LaapakColors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        style: LaapakTypography.bodyLarge(
          color: LaapakColors.textPrimary,
        ).copyWith(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: LaapakColors.textSecondary.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: isFocused
                ? LaapakColors.primary
                : LaapakColors.textSecondary,
            size: 22,
          ),
          suffixIcon: hasValue
              ? Icon(
                  isValid ? Icons.check_circle : Icons.cancel,
                  color: isValid
                      ? LaapakColors.success
                      // : LaapakColors.textSecondary.withValues(alpha: 0.3),
                      : LaapakColors.error.withValues(alpha: 0.5),
                  size: 20,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24, // Wider padding for pill shape
            vertical: 18,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildSupportOption() {
    return Center(
      child: TextButton.icon(
        onPressed: () => _openWhatsAppSupport(context),
        style: TextButton.styleFrom(
          foregroundColor: LaapakColors.textSecondary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        icon: const Icon(Icons.help_outline_rounded, size: 18),
        label: Text(
          'في حاجة واقفة معاك؟ كلمنا',
          style: LaapakTypography.bodyMedium(color: LaapakColors.textSecondary),
        ),
      ),
    );
  }

  Future<void> _openWhatsAppSupport(BuildContext context) async {
    const phoneNumber = AppConstants.whatsappPhoneNumber;
    const message = 'مساء الخير يا هندسة، عندي مشكلة في الدخول';
    final url =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

    try {
      if (!await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      )) {
        // Handle error
      }
    } catch (_) {}
  }
}
