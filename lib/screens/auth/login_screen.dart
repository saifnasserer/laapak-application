import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/theme.dart';
import '../../utils/responsive.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/dismiss_keyboard.dart';
import '../../providers/auth_provider.dart';
import '../order/order_screen.dart';

/// Login Screen
///
/// Clean, minimal authentication screen following Laapak Design Guidelines.
/// Arabic-first design with RTL support.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Controllers for form fields
  final _phoneController = TextEditingController();
  final _orderCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Track validation state for real-time feedback
  bool _phoneValid = false;
  bool _orderCodeValid = false;

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhone);
    _orderCodeController.removeListener(_validateOrderCode);
    _phoneController.dispose();
    _orderCodeController.dispose();
    super.dispose();
  }

  /// Validate phone number in real-time
  void _validatePhone() {
    final value = _phoneController.text;
    if (value.isEmpty) {
      setState(() => _phoneValid = false);
      return;
    }
    final cleanedPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    setState(() => _phoneValid = AppConstants.phonePattern.hasMatch(cleanedPhone));
  }

  /// Validate order code in real-time
  void _validateOrderCode() {
    final value = _orderCodeController.text.trim();
    if (value.isEmpty) {
      setState(() => _orderCodeValid = false);
      return;
    }
    setState(() => _orderCodeValid = AppConstants.orderCodePattern.hasMatch(value.toUpperCase()));
  }

  @override
  void initState() {
    super.initState();
    
    // Add listeners for real-time validation
    _phoneController.addListener(_validatePhone);
    _orderCodeController.addListener(_validateOrderCode);
    
    // Listen to auth state changes
    ref.listenManual(authProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated != true) {
        // Navigate to order screen on successful login
        Future.microtask(() {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const OrderScreen(),
              ),
            );
          }
        });
      }

      // Show error if login fails
      if (next.error != null && next.error!.isNotEmpty) {
        Future.microtask(() {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.error!),
                backgroundColor: LaapakColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Clear error after showing
            ref.read(authProvider.notifier).clearError();
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LaapakColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: DismissKeyboard(
          child: Directionality(
            textDirection: TextDirection.rtl, // RTL for Arabic
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: Responsive.screenPadding,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      (Responsive.screenPaddingVertical * 2),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo/Brand Section
                      _buildHeader(),

                      SizedBox(height: Responsive.xxxl),

                      // Login Form Card
                      _buildLoginForm(),

                      SizedBox(height: Responsive.xl),

                      // Help Text
                      _buildHelpText(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Header with logo/brand area
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Image.asset(
          'assets/logo/logo.png',
          height: 100,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to mark logo if main logo fails
            return Image.asset(
              'assets/logo/cropped-Logo-mark.png.png',
              height: 100,
              fit: BoxFit.contain,
            );
          },
        ),
      ],
    );
  }

  /// Welcome section with title and description
  // Widget _buildWelcomeSection() {
  //   return Text(
  //     'سجل دخولك عشان تشوف التقارير والفواتير بتاعتك',
  //     style: LaapakTypography.bodyLarge(color: LaapakColors.textSecondary),
  //     textAlign: TextAlign.center,
  //   );
  // }

  /// Login form card
  Widget _buildLoginForm() {
    return Card(
      child: Padding(
        padding: Responsive.cardPaddingInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Phone Number Field
            _buildPhoneField(),

            SizedBox(height: Responsive.md),

            // Order Code Field
            _buildOrderCodeField(),

            SizedBox(height: Responsive.xl),

            // Login Button
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  /// Phone number input field
  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'رقم التليفون',
        //   style: LaapakTypography.labelLarge(color: LaapakColors.textPrimary),
        // ),
        // SizedBox(height: Responsive.xs),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: 'رقم الموبايل',
            prefixIcon: Icon(
              Icons.phone_outlined,
              color: LaapakColors.textSecondary,
            ),
            suffixIcon: _phoneController.text.isNotEmpty
                ? Icon(
                    _phoneValid ? Icons.check_circle : Icons.error,
                    color: _phoneValid
                        ? Colors.green
                        : LaapakColors.error,
                    size: Responsive.iconSizeSmall,
                  )
                : null,
          ),
          style: LaapakTypography.bodyMedium(color: LaapakColors.textPrimary),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppConstants.errorPhoneRequired;
            }
            // Remove any spaces or special characters for validation
            final cleanedPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
            if (!AppConstants.phonePattern.hasMatch(cleanedPhone)) {
              return AppConstants.errorPhoneInvalid;
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Order code input field
  Widget _buildOrderCodeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'كود الطلب',
        //   style: LaapakTypography.labelLarge(color: LaapakColors.textPrimary),
        // ),
        // SizedBox(height: Responsive.xs),
        TextFormField(
          controller: _orderCodeController,
          textInputAction: TextInputAction.done,
          textCapitalization: TextCapitalization.characters,
          decoration: InputDecoration(
            hintText: 'كود الطلب',
            prefixIcon: Icon(
              Icons.receipt_long_outlined,
              color: LaapakColors.textSecondary,
            ),
            suffixIcon: _orderCodeController.text.isNotEmpty
                ? Icon(
                    _orderCodeValid ? Icons.check_circle : Icons.error,
                    color: _orderCodeValid
                        ? Colors.green
                        : LaapakColors.error,
                    size: Responsive.iconSizeSmall,
                  )
                : null,
          ),
          style: LaapakTypography.bodyMedium(color: LaapakColors.textPrimary),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppConstants.errorOrderCodeRequired;
            }
            // Validate order code format
            final cleanedCode = value.trim().toUpperCase();
            if (!AppConstants.orderCodePattern.hasMatch(cleanedCode)) {
              return AppConstants.errorOrderCodeInvalid;
            }
            return null;
          },
          onFieldSubmitted: (_) {
            // Would trigger login here (no logic implemented)
          },
        ),
      ],
    );
  }

  /// Primary login button with solid color and loading state
  Widget _buildLoginButton() {
    final authState = ref.watch(authProvider);

    return LoadingButton(
      text: 'تسجل دخول',
      isLoading: authState.isLoading,
      onPressed: () {
        // Validate form
        if (_formKey.currentState?.validate() ?? false) {
          HapticFeedback.lightImpact();

          // Clean and normalize inputs
          final phone = _phoneController.text
              .replaceAll(RegExp(r'[\s\-\(\)]'), '')
              .trim();
          final orderCode = _orderCodeController.text.trim().toUpperCase();

          // Call login through Riverpod
          ref.read(authProvider.notifier).login(
                phone: phone,
                orderCode: orderCode,
              );
        }
      },
    );
  }

  /// Help text at the bottom
  Widget _buildHelpText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'مش فاكر كود الطلب؟',
          style: LaapakTypography.bodyMedium(color: LaapakColors.textSecondary),
        ),
        SizedBox(width: Responsive.xs),
        TextButton(
          onPressed: () {
            // Would show help/contact info (no logic implemented)
          },
          style: TextButton.styleFrom(padding: Responsive.spacingH(1)),
          child: Text(
            'كلمنا',
            style: LaapakTypography.labelLarge(color: LaapakColors.primary),
          ),
        ),
      ],
    );
  }
}
