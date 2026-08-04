import 'package:app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';

class AppSnackBar {
  static void _show(
    BuildContext context,
    String message, {
    required Color backgroundColor,
    required List<List<dynamic>> icon,
    Color? iconColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Center(
              child: HugeIcon(
                icon: icon,
                size: 16,
                strokeWidth: 3,
                color: iconColor ?? Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        elevation: 0,
      ),
    );
  }

  static void success(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      backgroundColor: AppTheme.success,
      icon: HugeIcons.strokeRoundedCheckmarkSquare04,
      duration: duration,
    );
  }

  static void error(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      backgroundColor: AppTheme.error,
      icon: HugeIcons.strokeRoundedAlertSquare,
      duration: duration,
    );
  }

  static void warning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      backgroundColor: AppTheme.warning,
      icon: HugeIcons.strokeRoundedAlertDiamond,
      duration: duration,
    );
  }

  static void info(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      backgroundColor: AppTheme.secondary,
      icon: HugeIcons.strokeRoundedInformationSquare,
      duration: duration,
    );
  }
}
