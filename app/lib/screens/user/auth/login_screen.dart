import 'package:app/core/routes/app_routes.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_buttons.dart';
import 'package:app/widgets/app_textfields.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });
  }

  String? _validateEmailOrPhone(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Please enter your email or phone';
    }

    final input = v.trim();

    if (input.startsWith('9') && RegExp(r'^[0-9]+$').hasMatch(input)) {
      if (!RegExp(r'^9[0-9]{9}$').hasMatch(input)) {
        return 'Enter a valid phone number';
      }
    } else {
      if (input.length > 100) {
        return 'Email must be less than 100 characters';
      }
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(input)) {
        return 'Enter a valid email address';
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: canPop
              ? IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                )
              : null,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login',
                    style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Welcome back! Login to continue',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  AppTextfields.withLabel(
                    controller: _emailOrPhoneController,
                    label: 'Email or Phone',
                    hint: 'Enter your email or phone',
                    icon: HugeIcons.strokeRoundedUser,
                    validator: _validateEmailOrPhone,
                  ),

                  const SizedBox(height: 20),

                  AppTextfields.withLabel(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    icon: HugeIcons.strokeRoundedLockPassword,
                    obscure: _obscurePassword,
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: HugeIcon(
                        icon: _obscurePassword
                            ? HugeIcons.strokeRoundedViewOffSlash
                            : HugeIcons.strokeRoundedView,
                        size: 22,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    onSuffixTap: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  _isLoading
                      ? AppButtons.loading(text: 'Logging In...')
                      : AppButtons.primary(onPressed: _login, text: 'Login'),

                  const SizedBox(height: 16),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        AppButtons.text(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.register,
                            );
                          },
                          text: 'Register',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
