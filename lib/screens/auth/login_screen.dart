import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme.dart';
import '../../utils/responsive.dart';
import '../../widgets/loading_button.dart';
import '../../widgets/dismiss_keyboard.dart';

/// Login Screen
///
/// Clean, minimal authentication screen following Laapak Design Guidelines.
/// Arabic-first design with RTL support.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for form fields (UI only, no logic)
  final _phoneController = TextEditingController();
  final _orderCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _orderCodeController.dispose();
    super.dispose();
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
          ),
          style: LaapakTypography.bodyMedium(color: LaapakColors.textPrimary),
          validator: (value) {
            // UI validation only (no logic)
            if (value == null || value.isEmpty) {
              return 'لو سمحت أدخل رقم التليفون';
            }
            if (value.length < 10) {
              return 'رقم التليفون مش صحيح';
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
          ),
          style: LaapakTypography.bodyMedium(color: LaapakColors.textPrimary),
          validator: (value) {
            // UI validation only (no logic)
            if (value == null || value.isEmpty) {
              return 'لو سمحت أدخل كود الطلب';
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
    return LoadingButton(
      text: 'تسجل دخول',
      isLoading: _isLoading,
      onPressed: () {
        // Validate form
        if (_formKey.currentState?.validate() ?? false) {
          // Defer setState to avoid build conflicts
          Future.microtask(() {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });

              HapticFeedback.lightImpact();

              // Simulate login process (replace with actual API call)
              Future.delayed(const Duration(seconds: 2)).then((_) {
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                  });
                }
              });
            }
          });
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
