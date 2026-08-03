import 'package:app/core/routes/app_routes.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/widgets/app_buttons.dart';
import 'package:app/widgets/app_textfields.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });
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
                    'Register',
                    style: GoogleFonts.montserrat(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Get started by creating your account',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  AppTextfields.withLabel(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'John Bahadur',
                    icon: HugeIcons.strokeRoundedUser,
                    validator: (v) {
                      if (v!.trim().isEmpty) {
                        return 'Please enter your full name';
                      }
                      if (v.length < 6) {
                        return "Name must be atleast 6 characters long";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  AppTextfields.withLabel(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'john.bahadur@example.com',
                    icon: HugeIcons.strokeRoundedMail01,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v!.trim().isEmpty) return 'Please enter your email';
                      if (v.length > 100) {
                        return 'Email must be less than 100 characters long';
                      }

                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(v.trim())) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  AppTextfields.withLabel(
                    controller: _phoneController,
                    label: 'Phone Number',
                    hint: '9847800000',
                    icon: HugeIcons.strokeRoundedCall02,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }

                      final phone = v.trim().replaceAll(RegExp(r'\s+'), '');
                      if (!RegExp(r'^9[0-9]{9}$').hasMatch(phone)) {
                        return 'Enter a valid phone number';
                      }

                      return null;
                    },
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
                        return 'Please enter a password';
                      }

                      final password = v.trim();
                      if (password.length < 8 || password.length > 50) {
                        return 'Password must be 8-50 characters';
                      }
                      final passwordRegex = RegExp(
                        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[@#!$_*]).{8,50}$',
                      );
                      if (!passwordRegex.hasMatch(password)) {
                        return 'Must include upper/lowercase, number, and symbols (@#!\$_*)';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  AppTextfields.withLabel(
                    controller: _confirmPasswordController,
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    icon: HugeIcons.strokeRoundedLockPassword,
                    obscure: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                      icon: HugeIcon(
                        icon: _obscureConfirmPassword
                            ? HugeIcons.strokeRoundedViewOffSlash
                            : HugeIcons.strokeRoundedView,
                        size: 22,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    onSuffixTap: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                    validator: (v) {
                      if (v!.trim().isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (v != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 32),

                  _isLoading
                      ? AppButtons.loading(text: 'Creating Account...')
                      : AppButtons.primary(
                          onPressed: _register,
                          text: 'Create Account',
                        ),

                  const SizedBox(height: 16),

                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
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
                              AppRoutes.login,
                            );
                          },
                          text: 'Login',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
