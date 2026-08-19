import 'package:app/core/model/user_model.dart';
import 'package:app/core/routes/app_routes.dart';
import 'package:app/core/services/auth_service.dart';
import 'package:app/core/storage/token_storage.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/providers/auth_provider.dart';
import 'package:app/providers/user_provider.dart';
import 'package:app/screens/skeleton/user/profile_skeleton.dart';
import 'package:app/widgets/app_buttons.dart';
import 'package:app/widgets/app_textfields.dart';
import 'package:app/widgets/confirm_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final auth = ref.watch(authServiceProvider);

    if (user == null) {
      return const ProfileSkeletonScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBg,
      body: RefreshIndicator(
        color: AppTheme.primary,
        backgroundColor: Colors.white,
        onRefresh: () async {
          await ref.read(userProvider.notifier).fetchProfile();
        },
        child: SafeArea(
          child: CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 16),
                    _profileCard(context, user),
                    const SizedBox(height: 28),
                    _sectionLabel('Account'),
                    _card([
                      _menuTile(
                        icon: HugeIcons.strokeRoundedUserEdit01,
                        title: 'Edit full name',
                        subtitle: user.fullname,
                        onTap: () =>
                            _openEditFullNameSheet(context, user.fullname),
                      ),
                      _divider(),
                      _menuTile(
                        icon: HugeIcons.strokeRoundedSquareLock02,
                        title: 'Change password',
                        subtitle: '',
                        onTap: () => _openChangePasswordSheet(context),
                      ),
                      _divider(),
                      _menuTile(
                        icon: HugeIcons.strokeRoundedReceiptText,
                        title: 'My complaints',
                        subtitle: '20 complaints',
                        isLast: true,
                      ),
                    ]),
                    const SizedBox(height: 30),
                    _dangerZone(context, auth),
                    const SizedBox(height: 8),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Profile card
  Widget _profileCard(BuildContext context, UserProfileData user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primary.withValues(alpha: 0.82)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            user.fullname,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.18)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _heroStat(
                  icon: HugeIcons.strokeRoundedCall,
                  label: 'Phone',
                  value: user.phone,
                ),
              ),
              Container(
                width: 1.5,
                height: 30,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _heroStat(
                  icon: HugeIcons.strokeRoundedReceiptText,
                  label: 'Complaints',
                  value: "23",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat({
    required List<List<dynamic>> icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          HugeIcon(
            icon: icon,
            size: 22,
            color: Colors.white.withValues(alpha: 0.85),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10.5,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, {bool isDanger = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.montserrat(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: isDanger ? AppTheme.error : AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.inputBorder, width: 1),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: AppTheme.inputBorder.withValues(alpha: 0.7),
    );
  }

  Widget _menuTile({
    required List<List<dynamic>> icon,
    required String title,
    String subtitle = '',
    Color? color,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    final effectiveColor = color ?? AppTheme.textPrimary;
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
        top: Radius.zero,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: icon,
                      size: 18,
                      color: effectiveColor,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: effectiveColor,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTap != null)
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    size: 18,
                    color: AppTheme.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dangerZone(BuildContext context, AuthService auth) {
    return _card([
      _menuTile(
        icon: HugeIcons.strokeRoundedSendToMobile02,
        title: 'Log out of all devices',
        subtitle: 'Ends every active session',
        color: AppTheme.error,
        onTap: () => _confirmLogout(context, auth, allDevices: true),
      ),
      _divider(),
      _menuTile(
        icon: HugeIcons.strokeRoundedLogout01,
        title: 'Logout',
        color: AppTheme.error,
        onTap: () => _confirmLogout(context, auth, allDevices: false),
        isLast: true,
      ),
    ]);
  }

  void _confirmLogout(
    BuildContext context,
    AuthService auth, {
    required bool allDevices,
  }) {
    AppConfirmDialog.show(
      context: context,
      title: allDevices ? 'Log out of all devices?' : 'Log out?',
      message: allDevices
          ? 'This will end every active session on all devices. '
                'You\'ll need to sign in again everywhere.'
          : 'You\'ll need to sign in again to access your account on this device.',
      confirmText: allDevices ? 'Yes, Log out everywhere' : 'Yes, Logout',
      cancelText: 'No, Keep me logged in',
      confirmBackgroundColor: AppTheme.error,
      confirmForegroundColor: AppTheme.onPrimary,
      onConfirm: () async {
        final refreshToken = await TokenStorage.getRefreshToken();

        if (allDevices) {
          await auth.logoutFromAllDevices();
        }

        if (refreshToken != null && refreshToken.isNotEmpty) {
          await auth.logout(refreshToken: refreshToken);
        }

        await TokenStorage.clearTokens();

        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      },
    );
  }

  void _openEditFullNameSheet(BuildContext context, String fullname) {
    final formKey = GlobalKey<FormState>();
    final fullnameController = TextEditingController(text: fullname);

    String error = "";
    bool isLoading = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SheetShell(
        title: 'Edit full name',
        child: StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This is the name shown on your profile and complaints.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Form(
                  key: formKey,
                  child: AppTextfields.input(
                    controller: fullnameController,
                    readOnly: isLoading,
                    hint: "Enter new full name",
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
                ),
                SizedBox(height: 6),
                if (error.isNotEmpty) ...[
                  Text(
                    error,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                AppButtons.primary(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    final newName = fullnameController.text.trim();
                    if (newName.isEmpty) return;

                    setSheetState(() => isLoading = true);

                    try {
                      await ref
                          .read(userProvider.notifier)
                          .updateFullname(newName);

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      setState(() {
                        error = e.toString();
                        isLoading = false;
                      });
                    }
                  },
                  isLoading: isLoading,
                  text: "Save changes",
                  fontSize: 15,
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }

  void _openChangePasswordSheet(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    String error = "";
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SheetShell(
        title: 'Change password',
        child: StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Use at least 8 characters with an uppercase letter, number and a symbol (@#!\$_*).',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Current Password",
                        style: GoogleFonts.montserrat(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AppTextfields.input(
                        controller: currentCtrl,
                        readOnly: isLoading,
                        obscure: obscureCurrentPassword,
                        hint: "Enter your password",
                        suffixIcon: IconButton(
                          onPressed: () => setSheetState(
                            () => obscureCurrentPassword =
                                !obscureCurrentPassword,
                          ),
                          icon: HugeIcon(
                            icon: obscureCurrentPassword
                                ? HugeIcons.strokeRoundedViewOffSlash
                                : HugeIcons.strokeRoundedView,
                            size: 22,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        onSuffixTap: () => setSheetState(
                          () =>
                              obscureCurrentPassword = !obscureCurrentPassword,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please enter your current password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Text(
                        "New Password",
                        style: GoogleFonts.montserrat(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AppTextfields.input(
                        controller: newCtrl,
                        readOnly: isLoading,
                        obscure: obscureNewPassword,
                        hint: "Enter new password",
                        suffixIcon: IconButton(
                          onPressed: () => setSheetState(
                            () => obscureNewPassword = !obscureNewPassword,
                          ),
                          icon: HugeIcon(
                            icon: obscureNewPassword
                                ? HugeIcons.strokeRoundedViewOffSlash
                                : HugeIcons.strokeRoundedView,
                            size: 22,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        onSuffixTap: () => setSheetState(
                          () => obscureNewPassword = !obscureNewPassword,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter a new password';
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
                      const SizedBox(height: 14),
                      Text(
                        "Confirm New Password",
                        style: GoogleFonts.montserrat(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AppTextfields.input(
                        controller: confirmCtrl,
                        readOnly: isLoading,
                        obscure: obscureConfirmPassword,
                        hint: "Enter confirm password",
                        suffixIcon: IconButton(
                          onPressed: () => setSheetState(
                            () => obscureConfirmPassword =
                                !obscureConfirmPassword,
                          ),
                          icon: HugeIcon(
                            icon: obscureConfirmPassword
                                ? HugeIcons.strokeRoundedViewOffSlash
                                : HugeIcons.strokeRoundedView,
                            size: 22,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        onSuffixTap: () => setSheetState(
                          () =>
                              obscureConfirmPassword = !obscureConfirmPassword,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (v != newCtrl.text) {
                            return 'Passwords do not match';
                          }
                          final passwordRegex = RegExp(
                            r'^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[@#!$_*]).{8,50}$',
                          );
                          if (!passwordRegex.hasMatch(confirmCtrl.text)) {
                            return 'Must include upper/lowercase, number, and symbols (@#!\$_*)';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                if (error.isNotEmpty) ...[
                  Text(
                    error,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                const SizedBox(height: 20),
                AppButtons.primary(
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;

                    setSheetState(() => isLoading = true);

                    try {
                      await ref
                          .read(userProvider.notifier)
                          .changePassword(
                            currentPassword: currentCtrl.text.trim(),
                            newPassword: newCtrl.text.trim(),
                          );

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      setSheetState(() {
                        error = e.toString();
                        isLoading = false;
                      });
                    }
                  },
                  isLoading: isLoading,
                  text: "Change password",
                  fontSize: 15,
                ),
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Bottom sheet
class _SheetShell extends StatelessWidget {
  final String title;
  final Widget child;

  const _SheetShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppTheme.inputBorder,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
